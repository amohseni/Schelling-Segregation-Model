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

Each agent is red or green and sits alone on a patch of a 51 x 51 torus. It counts the agents in its neighborhood and is **happy** when the same-color share falls inside `[minimum-wanted, maximum-wanted]`:

```
similar-nearby >= minimum-wanted * total-nearby / 100
similar-nearby <= maximum-wanted * total-nearby / 100
```

Each tick, every unhappy agent relocates to a uniformly random vacant patch; then everyone recomputes happiness. The run halts when nobody is unhappy.

| Parameter | Range | Default | Effect |
|---|---|---|---|
| `density` | 50-99 | 99 | occupancy; setup only |
| `Percent-red` | 0-100 | 50 | share of agents that start red; setup only |
| `red/green-minimum-wanted` | 0-100 | 31 | floor on same-color share |
| `red/green-maximum-wanted` | 0-100 | 100 | ceiling on same-color share |
| `Neighborhood` | Moore / Radius | Radius | `neighbors` (8 patches) or `in-radius` |
| `Radius` | 0-100 | 2 | radius when `Neighborhood = Radius` |
| `Probability-switch` | 0-0.1 | 0 | per-tick chance an agent flips color |

## Three properties of this model that are easy to miss

**1. Under `Radius`, every agent counts itself.** `turtles in-radius r` includes the asking turtle, so `similar-nearby` is always at least 1. This inflates the `% similar` monitor by `50/n` points, where `n` is the neighborhood size. Measured at t = 0 with radius 2 (n = 13, mean of 8 seeds): the monitor reads **53.82%**, while the same-color share among *other* agents is **49.91%**. Moore neighborhoods exclude the agent itself, so the two neighborhood settings are not on a common scale, and a threshold of 31 means something different under each.

**2. Relocation is global, not local.** `move-to one-of patches with [not any? turtles-here]` teleports an unhappy agent anywhere on the torus. Classic Schelling moves agents to *nearby* vacancies. Here there is no escape gradient, so clustering comes entirely from who stays put, and convergence is much faster than the local-search version.

**3. The maximum-wanted ceiling is the model's real addition.** Wilensky's original has a floor only, so no agent is ever too segregated. With a ceiling below 100, an agent can be unhappy for being *too* surrounded by its own kind, and the system need never settle.

## Known failure modes in the original .nlogo

These are in the NetLogo source as written, not artifacts of the port. The browser version handles each gracefully and says so on screen.

- **No vacant patch.** `move-to one-of patches with [...]` receives `nobody` and NetLogo raises a runtime error. Reachable when `density = 99` happens to fill every patch, and certain at 100%.
- **Division by zero in `update-globals`.** `percent-similar` divides by `sum [total-nearby]`, which is 0 if no agent has a neighbor. Reachable with `Moore-Neighborhood` at low density; also at `Radius = 0` under Moore.
- **`Radius` up to 100 on a 51-wide torus.** Anything above 25 is the whole world; the slider's top half is inert.
- **Order dependence when `Probability-switch > 0`.** Color flips happen inside the same `ask` that counts neighbors, so an agent sees earlier-asked agents already flipped and later-asked agents not yet flipped. The port reproduces this rather than fixing it.

## Fidelity of the browser port

`index.html` reimplements the NetLogo procedures directly: sequential `ask` in randomized order, torus-wrapped shortest distance, `in-radius` including self, a fresh vacancy draw per mover, and the setup-time call to `update-variables`. Verified in headless Chromium:

| Check | Result |
|---|---|
| Agents and vacancies conserved over 200 ticks | 2576 agents, 25 vacancies, unchanged |
| Defaults (radius 2, min 31, density 99) | converges t = 25, `% similar` 53.9 -> 70.8 |
| Classic Schelling (Moore, min 30, density 95) | converges t = 21, `% similar` 74.1 |
| Tolerance ceiling (min 40, max 60, radius 3) | no convergence in 400 ticks, 222-402 unhappy |
| `Radius = 0` (self only) | 1 neighbor, `% similar` 100, all happy |
| Isolated agents under Moore (`total-nearby = 0`) | happy, matching `0 >= 0 and 0 <= 0` |
| Same seed, two runs | bit-identical |

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
