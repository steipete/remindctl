# Review notes: subtasks support

- Added `--parent`/`--under` options to `remindctl add` and `remindctl edit` to attach or re-parent reminders.
- Reminders are validated to stay in the same list as their parent; `edit` will auto-move lists if needed.
- EventKit parent support is attempted via dynamic selectors (`setParent:` / `setParentReminder:`). If unavailable, remindctl stores fallback metadata in notes (`remindctl-parent: <id>`).
- Added help/usage examples plus README and manual test updates; new test checks that help includes the parent options.

Things to review:
- Confirm the dynamic parent selector names are correct for any EventKit version that supports subtasks.
- Verify the fallback notes behavior is acceptable for your workflow.
