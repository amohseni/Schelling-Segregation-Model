# Schelling Segregation Model

Kevin Zollman's `ComplexSegregation.nlogo` (built on Uri Wilensky's 1997 NetLogo Segregation model), plus a browser reimplementation that runs the same dynamics without NetLogo installed.

```
ComplexSegregation.nlogo   the original model, unmodified
index.html                 self-contained browser version (no build, no dependencies)
install-netlogo.sh         installs NetLogo Desktop on macOS
```

## Running it

**Live: <https://amohseni.github.io/Schelling-Segregation-Model/>** That URL is stable and always serves the newest version: a push to `main` republishes it within about a minute.

**Browser, locally.** Open `index.html`. Nothing to install. It has every slider, monitor, and plot the NetLogo interface has, plus a seed field, presets, and CSV export.

**NetLogo Desktop.** `./install-netlogo.sh`, then open `ComplexSegregation.nlogo`. Needed only if you want BehaviorSpace, the code tab, or to modify the model itself.

## The model

Each agent is red or green (or blue, with three kinds enabled) and sits alone on a patch of a square torus whose side is set by `lattice-size`. It counts the agents in its neighborhood and is **happy** when the same-color share falls inside `[minimum-wanted, maximum-wanted]`:

```
similar-nearby >= minimum-wanted * total-nearby / 100
similar-nearby <= maximum-wanted * total-nearby / 100
```

Each tick, every unhappy agent relocates to a uniformly random vacant patch; then everyone recomputes happiness. The run halts when nobody is unhappy.

| Parameter | Range | Default | Effect |
|---|---|---|---|
| `lattice-size` | 8-151 | 51 | side of the square torus; setup only |
| `kinds of agent` | 2 / 3 | 2 | two types, or three; setup only |
| `density` | 50-99 | 99 | occupancy; setup only |
| `Percent-red` | 0-100 | 50 | share of agents that start red; with three kinds the rest split evenly; setup only |
| `red/green/blue-minimum-wanted` | 0-100 | 31 | floor on same-color share |
| `red/green/blue-maximum-wanted` | 0-100 | 100 | ceiling on same-color share |
| `Neighborhood` | Moore / Radius | Radius | `neighbors` (8 patches) or `in-radius` |
| `Radius` | 0-25 | 2 | radius when `Neighborhood = Radius`; the disc is 5 patches at 1, 13 at 2 |
| `Probability-switch` | 0-0.1 | 0 | per-tick chance an agent changes type, uniformly among the others |
| `Random seed` | any integer | new each Setup | Setup randomizes it; Replay re-runs the value shown |

### A third kind of agent

The `kinds of agent` control adds a blue type with its own floor and ceiling. Nothing in the happiness rule changes: `similar-nearby` still counts agents of the asking agent's own color and `total-nearby` still counts all of them. What changes is the baseline, and it is worth keeping in mind when reading the monitor: three equal groups start at about 33% similar rather than 50%, so the same `% similar` number means something different. The tipping point survives the generalization. On a 51 x 51 Moore world at density 95, three equal groups go from 33.7% similar to 53% at a floor of 20, and to 72% at a floor of 30, converging in 11-15 and 20-23 ticks.

Three kinds also make visible something two kinds cannot. Set the groups to 60/20/20 and give every agent the same floor of 30 (the *Three-type model* preset). At rest the majority lives among 71% its own kind while the two minorities reach only 51% and 46%, and roughly 250 agents never stop moving. No agent's preference differs from any other's: group size alone decides who gets a neighborhood of their own kind. The aggregate `% similar` monitor averages this away, so read it off the lattice, where the majority forms one connected field and the minorities sit in islands.

Agent colors are validated, not chosen by eye. The default trio is red `#D73229`, green `#59B03C`, blue `#2E5FD0`. The colorblind-safe trio is Okabe-Ito vermillion `#D55E00`, bluish green `#009E73` and blue `#0072B2`: of every candidate tested it is the only one clearing all-pairs CVD separation, the normal-vision floor, and 3:1 contrast against **both** the light and the dark lattice background, with a worst case of ΔE 11.0 under deuteranopia. Hue identity is preserved across the two palettes, so red stays warm, green stays green, blue stays blue.

## Which board is Schelling's

The *Schelling's original model* preset is **16 x 16 with about a fifth of the cells vacant**: the board Schelling describes first building and running by hand with coins, in his own retrospective account ("Some Fun, Thirty-Five Years Ago," *Handbook of Computational Economics* vol. 2, 2006). Three different boards get called his, and they denote different objects:

| Object | Board | Reachable here |
|---|---|---|
| The apparatus he built and ran by hand, c. 1969 | 16 x 16, ~1/5 blank | yes, the *Schelling's original model* preset |
| The figures printed in Schelling 1971 (JMS 1:143-186) | 13 x 16 | no; a square lattice cannot represent it |
| The figures in *Micromotives and Macrobehavior* (1978) | 8 x 8 | yes, the bottom of the slider |
| NetLogo's world | 51 x 51 | yes, the *Default settings* preset, where the page starts |

The agent and vacancy counts in Schelling's published figures are **not verified** and are not claimed anywhere in this project. There is no convention in the agent-based-modeling literature about a grid size inherited from Schelling: Mesa uses 20 x 20, NetLogo 51 x 51, and so on.

## The algorithm

Each cell of an `L x L` torus holds at most one agent. Every agent has a type and two thresholds, a floor and a ceiling, both percentages. Write `s` for the number of agents in an agent's neighborhood sharing its type and `n` for the number of agents in that neighborhood of any type. The agent is **content** when

```
floor/100 <= s/n <= ceiling/100
```

and discontent otherwise. An agent with no neighbors is content, the condition holding vacuously. The neighborhood is either the eight adjacent cells (Moore) or every cell within distance `r` (Radius), which includes the agent's own cell.

**Setup.** Each cell is occupied independently with probability `density`; each occupant is assigned a type at random in the stated proportions.

**Each tick.** (1) Every discontent agent, visited in random order, moves to a cell drawn uniformly from the currently vacant cells; the vacancy list updates as the pass proceeds, so an agent moving later cannot take a cell already claimed in the same tick. (2) Every agent recomputes `s`, `n`, and its contentment. (3) The run halts when no agent is discontent.

## Five properties that govern the behavior

Ordered by how much each determines what the model does, not by how surprising it is.

**1. Whether an equilibrium exists at all depends on the ceiling.** At `maximum-wanted` 100 an agent is discontent only for having too few of its own type nearby, and the system can always satisfy everyone by segregating further. Below 100 an agent is also discontent for having too many, and no arrangement need satisfy everyone at once. This is the substantive difference between Zollman's version and Wilensky's, and it separates the presets that converge from those that run indefinitely.

**2. Relocation is global, not local.** `move-to one-of patches with [not any? turtles-here]` sends a discontent agent to a uniformly random vacancy anywhere on the torus. Schelling's formulation moves agents to *nearby* vacancies, producing a gradient of escape and slow frontier migration. Here there is no gradient: clustering arises entirely from which agents stay put, and the resting state arrives in far fewer ticks than local search would take.

**3. Under `Radius`, each agent counts itself.** `turtles in-radius r` includes the asking turtle, so `s` is never below 1 and the reported `% similar` is raised by roughly `50/n` points: about 10 at radius 1, whose disc holds 5 cells, and about 4 at radius 2, whose disc holds 13. The floor is correspondingly easier to clear than its stated value suggests. Moore neighborhoods exclude the agent, so a threshold of 31 does not mean the same thing under the two settings. Measured at t = 0 with radius 2 over 8 seeds, the monitor reads **53.82%** while the same-type share among *other* agents is **49.91%**. The chance figure beside `% similar` accounts for this, which is why it, and not 50, is the number to compare against.

**4. Neighborhood size is a fraction of the world, and the fraction matters.** The radius-2 disc holds 13 cells at every lattice size, so it is 0.5% of a 51 x 51 torus and 5% of a 16 x 16 one. A smaller world gives each agent a neighborhood covering more of the population and a smaller pool of destinations, making small worlds noisier and quicker to settle.

**5. Type switching is order dependent.** When `probability-switch` exceeds zero, an agent may change type inside the same pass that counts neighbors, so agents visited later see the switches made by those visited earlier and not the reverse. This is a property of the original NetLogo source, reproduced rather than corrected.

## Known failure modes in the original .nlogo

These are in the NetLogo source as written, not artifacts of the port. The browser version handles each gracefully and says so on screen.

- **No vacant patch.** `move-to one-of patches with [...]` receives `nobody` and NetLogo raises a runtime error. Reachable when `density = 99` happens to fill every patch, and certain at 100%.
- **Division by zero in `update-globals`.** `percent-similar` divides by `sum [total-nearby]`, which is 0 if no agent has a neighbor. Reachable with `Moore-Neighborhood` at low density; also at `Radius = 0` under Moore.
- **`Radius` up to 100 on a 51-wide torus.** Anything above 25 is the whole world; the slider's top half is inert.
- **Order dependence when `Probability-switch > 0`.** Color flips happen inside the same `ask` that counts neighbors, so an agent sees earlier-asked agents already flipped and later-asked agents not yet flipped. The port reproduces this rather than fixing it.

`index.html` reimplements the NetLogo procedures directly: sequential `ask` in randomized order, torus-wrapped shortest distance, `in-radius` including self, a fresh vacancy draw per mover, and the setup-time call to `update-variables`. Verified in headless Chromium:

## Reading the interface

**`% similar` has a chance line under it.** The number on its own cannot be judged, because what counts as no segregation at all moves with the setup: two equal groups mix to 50%, three equal groups to 33%, and the 60/20/20 population to 44%. The tile therefore shows the figure that random placement of this same population would give, and the *Percent similar* plot draws it as a dashed reference line. It is computed rather than guessed: the sum of squared group shares, with the guaranteed self-match under `Radius` separated out because that part is certain rather than chance. Across every preset it lands on the measured t = 0 value.

**A per-group row sits under the monitors.** The aggregate averages the groups together, which hides the result the three-type preset exists to show. The row breaks it out, one figure per group in that group's color.

**The starting point stays on screen.** A thumbnail of the lattice at t = 0 sits beside the live one, so the before and after are visible together rather than one of them being a memory.

**Each plot carries a ghost of the previous run.** Click the three thresholds in order and each new curve is drawn over a faint trace of the one before, on a shared vertical scale.

**Preset descriptions appear on click**, in a caption under the buttons, rather than only in hover text that touch devices never show.

**Setup draws a new random seed** each time it is pressed, so repeated presses explore rather than repeat. **Replay** re-runs the seed currently shown, which is what makes a particular run reproducible; pressing Enter in the seed field does the same.

## Presets

Every preset was run to its resting state over three seeds; the chip tooltips quote what was measured, not what the parameters suggest. The middle three are the same world at three thresholds, and are meant to be clicked in order.

| Preset | Setting | What happens |
|---|---|---|
| Schelling's original model | 16 x 16, density 80, Moore, floor 30 | converges t = 7-12, `% similar` 47.5 -> 67-72 |
| Default settings | 51 x 51, density 99, radius 2, floor 31 (where the page starts) | converges t = 18-25, `% similar` 53.9 -> 69.5-70.8 |
| Wants >= 20% alike | floor 20, Moore | 104 of 2480 unhappy at t = 0; converges t = 6-8, 50.3 -> 56. Below the tipping point |
| Wants >= 30% alike | floor 30, Moore | 399 unhappy; converges t = 15-21, 50.3 -> 74-76. The headline result |
| Wants >= 50% alike | floor 50, Moore | 988 unhappy; converges t = 22-27, 50.3 -> 87 |
| Wants a balanced mix | floor 40, ceiling 60, radius 3 | never settles; `% similar` stalls at 50, 268-331 unhappy |
| Integrationists | ceiling 45, no floor, radius 3 | never settles; 1735-1817 of 2480 unhappy, `% similar` near 55 |
| One picky group, one easygoing | red floor 55, green floor 20, Moore | never settles; 544-578 unhappy, `% similar` near 57 |
| Three-type model | three kinds 60/20/20, all floor 30, Moore | never settles; majority rests at 71% own-kind, minorities at 51% and 46%; ~250 unhappy |
| Random type switching | floor 40, `probability-switch` 0.05 | never settles; `% similar` climbs to 83-84 as clusters keep re-forming |

Those three rows are the tipping-point lesson in one screen. At a floor of 20 the preference is too weak to move almost anyone and the world stays mixed. At 30, a population in which every individual is content to be outnumbered more than two to one nonetheless sorts itself to three-quarters similar. At 50 it reaches 87%. The only thing that differs across the three is one number, and no value of it is one most people would call bigotry.

## Fidelity of the browser port

| Check | Result |
|---|---|
| Agents + vacancies = cells, at sizes 8/13/16/51/101/151 | exact at every size |
| Every preset, three seeds | matches the table above, unchanged after adding the third type |
| Three kinds: agents conserved, no type outside 1-3 under `Probability-switch` | holds over 200 ticks |
| Switching kinds and clicking a preset | preset restores two kinds; no blue agents remain |
| `Radius = 0` (self only) | 1 neighbor, `% similar` 100, all happy |
| Isolated agents under Moore (`total-nearby = 0`) | happy, matching `0 >= 0 and 0 <= 0` |
| Density 99 on a 16 x 16 board | no vacancies, halts at t = 0 with the gridlock message |
| Same seed, two runs, non-default size | bit-identical |
| Setup pressed four times | four different seeds |
| Replay after a run | same seed, bit-identical lattice |
| Chance baseline vs measured `% similar` at t = 0 | agrees on every preset (50.0/50.3, 53.9/53.9, 51.8/51.8, 44.4/45.6, 54.0/54.3) |
| `Step` advances the tick and repaints the lattice | canvas pixels change, not only the plots |
| Legend keys hide with the `hidden` attribute | blue key absent with two kinds, present with three, in the standalone file |

The port uses a seeded PRNG (mulberry32), so a given seed reproduces a run exactly. NetLogo's own PRNG differs, so seeds do not transfer between the two.

One deliberate departure: dragging a live slider recomputes happiness without advancing the tick counter and without applying `Probability-switch`, so that moving a slider cannot itself flip anyone's color.

## Where this lives

This folder is mirrored as a standalone public repository at
<https://github.com/amohseni/Schelling-Segregation-Model>, which is the copy to
share. That repository holds only these files: no other part of `for-claude` is
in its history.

To move later changes from here to there, copy the current files onto that
repository's own history. Do not re-run `git subtree split`: it rewrites the
history each time and the push is rejected as a non-fast-forward.

```bash
git fetch https://github.com/amohseni/Schelling-Segregation-Model main
git checkout -B pub FETCH_HEAD
for f in .gitignore ComplexSegregation.nlogo README.md index.html install-netlogo.sh; do
  git show <this-branch>:schelling-segregation-model/$f > $f
done
git add -A && git commit
git push https://github.com/amohseni/Schelling-Segregation-Model pub:main
```

Simpler from the Mac clone: copy the five files into
`~/Documents/GitHub/Schelling-Segregation-Model`, then commit and push there.
Drop the "Where this lives" section from that copy; it belongs only here.

## Credits

Adapted from a model by Uri Wilensky (1997) and Kevin Zollman (2018). Wilensky wrote the NetLogo Segregation model; Zollman extended it into `ComplexSegregation.nlogo` by adding the `maximum-wanted` ceiling. Released under CC BY-NC-SA 3.0. See the model's Info tab for the full notice. Schelling, T. (1978). *Micromotives and Macrobehavior*. Norton.
