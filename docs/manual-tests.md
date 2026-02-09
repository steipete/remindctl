# Manual tests

## Scope
Run on a local GUI session (not SSH-only) so the Reminders permission prompt can appear.

## Test data
- Use a dedicated list: `remindctl-manual-YYYYMMDD` (create if missing).
- Create 3 reminders with distinct states:
  - `remindctl test A` (due today, priority high)
  - `remindctl test B` (due tomorrow)
  - `remindctl test C` (no due date)

## Checklist
- authorize: `remindctl authorize`
- status: `remindctl status`
- list lists: `remindctl list`
- list list contents: `remindctl list "remindctl-manual-YYYYMMDD"`
- add reminders (3 variants)
- show filters: `today`, `tomorrow`, `week`, `overdue`, `upcoming`, `open`, `completed`, `all`
- edit: update title/notes/priority/due date
- complete: mark one reminder complete
- delete: remove reminders, then delete list

## Results
- Date:
- Machine:
- Permission state before/after:
- Notes:
