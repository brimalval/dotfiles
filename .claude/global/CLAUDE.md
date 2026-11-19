# Orca orchestration: when you are a coordinator

These rules apply when you start Orca workers (the `orchestration` skill). They don't apply when you are a worker.

- **One coordinator, one objective.** An objective is a ticket, a feature or a set of PRs. Give each one its own Run (`run-create --objective`). Don't add unrelated follow-ups to an older Run: tell the user it belongs in a new coordinator.
- **Plan the chain before starting workers.** If the steps are known (for example build → review → fix → push), create them all as Tasks first, linking each to the step it waits on with `task-create --deps '["<task_id>"]'`. On each wake, start what `task-list --ready` shows. Findings that arrive later become new Tasks, with `--deps` on the Task they follow.
- **The user's approvals are gates, not tasks.** Pushing, opening or merging a PR, real or production data, anything outward-facing: put a `gate-create --task <id> --question "..."` on the Task it blocks. Don't create a new Task after the user says go.
- **Run independent work in parallel.** Start Tasks with no shared dependency together, each in its own worktree. If two Tasks share a branch, database or files, write that down as a dependency. Don't run them one after another out of habit.
