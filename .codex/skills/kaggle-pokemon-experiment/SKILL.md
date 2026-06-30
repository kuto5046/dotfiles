---
name: kaggle-pokemon-experiment
description: Use this skill in the kaggle-pokemon repository when creating a new experiments/expNNN submission from a previous experiment, improving Pokemon TCG AI Battle deck.csv and main.py by local simulator matches against agents/, verifying per-agent win rates, building/submitting with uv, and registering improved experiments under agents/ with a symlink plus a Markdown registry so links can be restored if environments change.
---

# Kaggle Pokemon Experiment

## Purpose

Use this for iterative Pokemon TCG AI Battle experiment work in `kaggle-pokemon`: copy a prior experiment, tune `deck.csv` and `main.py` against checked-in agents, keep only verified improvements, build/submit, and register improved experiments in `agents/`.

Always follow the repository `AGENTS.md`: speak Japanese, use `experiments/expNNN`, and keep experiment-specific changes inside the new experiment unless explicitly asked otherwise.

## Core Workflow

1. Inspect current state.
   - Run `git status --short` and avoid touching unrelated dirty files.
   - Find the latest relevant experiment and read `README.md`, `main.py`, `deck.csv`, `submit.py`, and any local evaluation scripts.
   - Inspect `agents/` and `agents/REGISTRY.md` if it exists.

2. Create the next experiment.
   - Copy the requested base experiment, usually `cp -R experiments/exp020 experiments/exp021`.
   - Remove copied `submission.tar.gz` and stale temporary/cache directories.
   - Update `README.md`, submit messages, evaluator labels, and paths to the new exp number.
   - Make all deck/strategy/search changes inside the new experiment.

3. Establish a baseline.
   - Evaluate the new experiment against every checked-in agent under `agents/*/main.py`.
   - Prefer per-opponent runs, not only mixed random runs. A mixed run can hide a losing matchup.
   - Use at least 100-200 games per opponent for early decisions; use 300+ for final evidence when practical.
   - Record summaries as JSON in the experiment directory, but clean up intermediate probes before finishing.

4. Improve by controlled candidates.
   - Change one axis at a time when possible: deck counts, target scoring, attachment priority, setup choice, draw/deck-out guard, gust/retreat/evolution logic.
   - For deck candidates, compare on the same opponent/seat schedule to reduce noise.
   - For strategy candidates, use temporary candidate directories that copy `main.py` and `deck.csv`, then evaluate them without mutating the final files until a candidate wins.
   - Optimize for minimum per-opponent win rate, not just overall mixed win rate.
   - Treat short-run improvements as hypotheses. Hold out another seed before adopting.

5. Adopt only proven improvements.
   - A candidate is adoptable only if it beats the current submission on relevant holdout seeds and does not create a losing matchup.
   - For the user's “完全に勝ち越す” standard, verify every existing agent individually has wins > losses. Use a mixed run only as extra evidence.
   - If a candidate improves one opponent but causes another to lose, keep searching or revert that candidate.

6. Build and submit when requested.
   - Build with `uv run experiments/expNNN/submit.py`.
   - Submit with `uv run experiments/expNNN/submit.py --submit --message "expNNN ..."`.
   - Report the important command result, especially Kaggle's success/failure line.

## Agent Registration

When an experiment is verified as improved and suitable to keep as a local benchmark:

1. Add a symlink in `agents/` pointing to the experiment directory.
   - Prefer a relative symlink, for example:
     `ln -s ../experiments/exp021 agents/exp021-gust-bench-prize-deck38`
   - Do not overwrite existing agent directories or links.

2. Maintain `agents/REGISTRY.md` as the durable registry because symlinks may break across environments.
   - If missing, create it.
   - Record each managed agent with: name, target experiment path, symlink path, status, date, validation evidence, deck/strategy notes, and restore command.
   - Keep existing entries; append or update only the relevant entry.

3. If symlinks are broken in a new environment, read `agents/REGISTRY.md` and recreate them from the stored `target` and `restore` command.

Recommended entry shape:

```markdown
## exp021-gust-bench-prize-deck38

- status: verified local benchmark
- target: `experiments/exp021`
- symlink: `agents/exp021-gust-bench-prize-deck38 -> ../experiments/exp021`
- restore: `ln -s ../experiments/exp021 agents/exp021-gust-bench-prize-deck38`
- validation: wins against every checked-in agent; include game counts and win rates
- notes: short deck/strategy summary
```

## Evaluation Discipline

- Use current worktree files as authoritative; previous chat summaries are not proof.
- Prefer `rg`, `find`, `sed`, and small Python scripts for repeatable summaries.
- Do not claim completion from a single random mixed evaluation. Check per-opponent results.
- Keep generated archives out of commits; `experiments/*/submission.tar.gz` should remain ignored.
- Before final response, state: adopted changes, verification results, build/submit status, and any remaining risk.
