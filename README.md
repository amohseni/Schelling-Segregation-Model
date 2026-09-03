# Schelling Segregation Model

Kevin Zollman's `ComplexSegregation.nlogo` (built on Uri Wilensky's 1997 NetLogo Segregation model), plus a browser reimplementation that runs the same dynamics without NetLogo installed.

```
ComplexSegregation.nlogo   the original model, unmodified
index.html                 self-contained browser version (no build, no dependencies)
install-netlogo.sh         installs NetLogo Desktop on macOS
```

## Running it

**Browser.** Open `index.html`. Nothing to install. It has every slider, monitor, and plot the NetLogo interface has, plus a seed field, presets, and CSV export.

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
| `lattice-size` | 8-151 | 16 | side of the square torus; setup only |
| `kinds of agent` | 2 / 3 | 2 | two types, or three; setup only |
| `density` | 50-99 | 80 | occupancy; setup only |
| `Percent-red` | 0-100 | 50 | share of agents that start red; with three kinds the rest split evenly; setup only |
| `red/green/blue-minimum-wanted` | 0-100 | 31 | floor on same-color share |
| `red/green/blue-maximum-wanted` | 0-100 | 100 | ceiling on same-color share |
| `Neighborhood` | Moore / Radius | Radius | `neighbors` (8 patches) or `in-radius` |
| `Radius` | 0-25 | 1 | radius when `Neighborhood = Radius`; the disc is 5 patches at 1, 13 at 2 |
| `Probability-switch` | 0-0.1 | 0 | per-tick chance an agent changes type, uniformly among the others |

### A third kind of agent

The `kinds of agent` control adds a blue type with its own floor and ceiling. Nothing in the happiness rule changes: `similar-nearby` still counts agents of the asking agent's own color and `total-nearby` still counts all of them. What changes is the baseline, and it is worth keeping in mind when reading the monitor: three equal groups start at about 33% similar rather than 50%, so the same `% similar` number means something different. The tipping point survives the generalization. On a 51 x 51 Moore world at density 95, three equal groups go from 33.7% similar to 53% at a floor of 20, and to 72% at a floor of 30, converging in 11-15 and 20-23 ticks.

Three kinds also make visible something two kinds cannot. Set the groups to 60/20/20 and give every agent the same floor of 30 (the *Three-type model* preset). At rest the majority lives among 71% its own kind while the two minorities reach only 51% and 46%, and roughly 250 agents never stop moving. No agent's preference differs from any other's: group size alone decides who gets a neighborhood of their own kind. The aggregate `% similar` monitor averages this away, so read it off the lattice, where the majority forms one connected field and the minorities sit in islands.

Agent colors are validated, not chosen by eye. The default trio is red `#D73229`, green `#59B03C`, blue `#2E5FD0`. The colorblind-safe trio is Okabe-Ito vermillion `#D55E00`, bluish green `#009E73` and blue `#0072B2`: of every candidate tested it is the only one clearing all-pairs CVD separation, the normal-vision floor, and 3:1 contrast against **both** the light and the dark lattice background, with a worst case of ΔE 11.0 under deuteranopia. Hue identity is preserved across the two palettes, so red stays warm, green stays green, blue stays blue.

## Which board is Schelling's

The default is **16 x 16 with about a fifth of the cells vacant**: the board Schelling describes first building and running by hand with coins, in his own retrospective account ("Some Fun, Thirty-Five Years Ago," *Handbook of Computational Economics* vol. 2, 2006). Three different boards get called his, and they denote different objects:

| Object | Board | Reachable here |
|---|---|---|
| The apparatus he built and ran by hand, c. 1969 | 16 x 16, ~1/5 blank | yes, the default and the *Classic Schelling* preset |
| The figures printed in Schelling 1971 (JMS 1:143-186) | 13 x 16 | no; a square lattice cannot represent it |
| The figures in *Micromotives and Macrobehavior* (1978) | 8 x 8 | yes, the bottom of the slider |
| NetLogo's world | 51 x 51 | yes, the *As shipped* preset |

The two article attributions come from Hegselmann's history of the model (*JASSS* 15(4):9, 2012; 20(3):15, 2017) rather than from a reading of the originals, which this environment's proxy could not reach. The agent and vacancy counts in Schelling's published figures are **not verified** and are not claimed anywhere in this project. There is no convention in the agent-based-modeling literature about a grid size inherited from Schelling: Mesa uses 20 x 20, NetLogo 51 x 51, and so on.

## Four properties of this model that are easy to miss

**1. Under `Radius`, every agent counts itself.** `turtles in-radius r` includes the asking turtle, so `similar-nearby` is always at least 1. This inflates the `% similar` monitor by `50/n` points, where `n` is the neighborhood size: the disc holds 5 patches at radius 1 and 13 at radius 2, so the bias is 10 points at the default radius and about 4 at radius 2. Measured at t = 0 with radius 2 (mean of 8 seeds): the monitor reads **53.82%**, while the same-color share among *other* agents is **49.91%**. Moore neighborhoods exclude the agent itself, so the two neighborhood settings are not on a common scale, and a threshold of 31 means something different under each.

**2. Relocation is global, not local.** `move-to one-of patches with [not any? turtles-here]` teleports an unhappy agent anywhere on the torus. Classic Schelling moves agents to *nearby* vacancies. Here there is no escape gradient, so clustering comes entirely from who stays put, and convergence is much faster than the local-search version.

**3. Lattice size is a modeling choice, not a display choice.** The radius-2 disc is 13 patches at every world size, so it is 0.5% of a 51 x 51 torus and 5% of a 16 x 16 one. Shrinking the lattice enlarges each agent's neighborhood as a share of the world and shrinks the pool of relocation targets, so small worlds are noisier and settle in fewer ticks.

**4. The maximum-wanted ceiling is the model's real addition.** Wilensky's original has a floor only, so no agent is ever too segregated. With a ceiling below 100, an agent can be unhappy for being *too* surrounded by its own kind, and the system need never settle.

## Known failure modes in the original .nlogo

These are in the NetLogo source as written, not artifacts of the port. The browser version handles each gracefully and says so on screen.

- **No vacant patch.** `move-to one-of patches with [...]` receives `nobody` and NetLogo raises a runtime error. Reachable when `density = 99` happens to fill every patch, and certain at 100%.
- **Division by zero in `update-globals`.** `percent-similar` divides by `sum [total-nearby]`, which is 0 if no agent has a neighbor. Reachable with `Moore-Neighborhood` at low density; also at `Radius = 0` under Moore.
- **`Radius` up to 100 on a 51-wide torus.** Anything above 25 is the whole world; the slider's top half is inert.
- **Order dependence when `Probability-switch > 0`.** Color flips happen inside the same `ask` that counts neighbors, so an agent sees earlier-asked agents already flipped and later-asked agents not yet flipped. The port reproduces this rather than fixing it.

`index.html` reimplements the NetLogo procedures directly: sequential `ask` in randomized order, torus-wrapped shortest distance, `in-radius` including self, a fresh vacancy draw per mover, and the setup-time call to `update-variables`. Verified in headless Chromium:

## Presets

Every preset was run to its resting state over three seeds; the chip tooltips quote what was measured, not what the parameters suggest. The middle three are the same world at three thresholds, and are meant to be clicked in order.

| Preset | Setting | What happens |
|---|---|---|
| Schelling's original model | 16 x 16, density 80, Moore, floor 30 | converges t = 7-12, `% similar` 47.5 -> 67-72 |
| NetLogo defaults | 51 x 51, density 99, radius 2, floor 31 | converges t = 18-25, `% similar` 53.9 -> 69.5-70.8 |
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
| `Step` advances the tick and repaints the lattice | canvas pixels change, not only the plots |
| Legend keys hide with the `hidden` attribute | blue key absent with two kinds, present with three, in the standalone file |

The port uses a seeded PRNG (mulberry32), so a given seed reproduces a run exactly. NetLogo's own PRNG differs, so seeds do not transfer between the two.

One deliberate departure: dragging a live slider recomputes happiness without advancing the tick counter and without applying `Probability-switch`, so that moving a slider cannot itself flip anyone's color.

## Making this its own repository

This folder is self-contained. To split it out:

```bash
git subtree split --prefix=schelling-segregation-model -b schelling-only
mkdir ../schelling-segregation-model && cd ../schelling-segregation-model
git init && git pull ../for-claude schelling-only
```

## Credits

Model by Uri Wilensky (1997) and Kevin Zollman (2018), CC BY-NC-SA 3.0. See the model's Info tab for the full notice. Schelling, T. (1978). *Micromotives and Macrobehavior*. Norton.
