# Coordinator status

Orca's status comes from Claude Code's hooks: `Stop` means "done". An orchestration coordinator
ends its turn every time it hands work to workers, so Orca shows it as done while its Run is still
going. This plugin adds the Run back in and shows what each coordinator is really doing:

| State | When |
| --- | --- |
| Needs you | a pending gate, a live worker waiting on a person, or the coordinator itself asking |
| Working | the coordinator's turn is running |
| Waiting on workers | its turn ended, a task is dispatched (Orca says "done" here) |
| Stalled | its turn ended 90 s+ ago, tasks are open, nothing is running |
| Done | every task in its Runs is settled |

- **Status bar:** one item across all coordinators (`4 need you · 1 worker running`). Pressing it
  jumps to the one that needs you most.
- **Panel** ("Coordinators"): each coordinator with its project, what waits on you (click to jump)
  and task progress. With coordinators in more than one project, a "Projects" filter shows one checkbox
  per Orca repo. It remembers the projects you hide, so a project's first coordinator always shows.
  The status bar still counts every project.
- **Answering gates:** each pending gate shows its options, "Already handled" (for a gate you
  answered in chat) and a free-text answer, each behind a confirm press. Sending runs
  `gate-resolve --from <coordinator>` (as Orca's Orchestra panel does), then posts a `status`
  message to the Run's inbox, which Orca delivers as a wake with the question and answer.
  Resolving alone does not wake the coordinator. It re-reads the gate first and refuses one
  already answered. Works for any coordinator agent, since nothing relies on it remembering to
  resolve its own gates.
- **Notifications:** a new gate or waiting worker, a stall, a coordinator whose Runs all finished.

Only coordinators whose terminal is still open count. A Run's coordinator is the terminal bound to it
now (`run-current`), so a revived session that took over an old Run with `run-use` shows with it,
however old. Other settled Runs drop out 12 hours after they were created.
Run state is read through the bundled `orca orchestration` CLI every 10 s and shortly after any
agent status change (the approach follows matteoeusebi/orca-pulse, MIT). The rules are in
`src/model.ts`.

## Develop

```sh
orca plugin test .         # model, worker and panel tests
orca plugin check .        # renders the panel with the worker against this machine's real Runs
orca plugin dev load .     # loads this folder into Orca; saves reload it
orca plugin logs local.coordinator-status
```
