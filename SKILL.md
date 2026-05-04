---
name: apple-reminders
description: Use remindctl to inspect and manage Apple Reminders on macOS, including show/list/add/edit/complete/delete/status/authorize workflows.
---

# Apple Reminders

Use `remindctl` for Apple Reminders on macOS. The tool talks to the system Reminders store, so changes sync through iCloud to the user's Apple devices.

## Prerequisites

- macOS with Reminders.app
- `remindctl` installed and available on `PATH`
- Reminders permission when prompted
- Use `remindctl status` to check permission state
- Use `remindctl authorize` to request access

## Use This Skill When

- The user wants to manage Apple Reminders from the terminal
- The user asks for reminders, reminder lists, due dates, completion, deletion, or permission status
- The user wants reminders that appear on iPhone, iPad, or Mac via Apple Reminders

## Do Not Use This Skill When

- The user wants a non-Reminders agent alert, cron job, or timed chatbot reminder
- The user wants calendar events instead of reminders

## Current Command Model

- `remindctl` defaults to `show`
- `show` accepts filters: `today`, `tomorrow`, `week`, `overdue`, `upcoming`, `open`, `completed`, `all`, or a date string
- `list` shows all lists with no arguments, or reminders in one or more named lists
- `add` creates a reminder
- `edit` updates a reminder by index or ID prefix
- `complete` marks reminders complete
- `delete` removes reminders
- `status` reports Reminders authorization without prompting
- `authorize` requests permission when possible

## Helpful Aliases

- `lists` and `ls` map to `list`
- `rm` maps to `delete`
- `done` maps to `complete`

## Output And Flags

- `--json` and `-j` emit JSON
- `--plain` emits stable tab-separated output
- `--quiet` emits minimal output
- `--no-color` disables colored output
- `--no-input` disables interactive prompts

Prefer `--json` when another step needs machine-readable data.

## Reading Reminder Data

- Use `remindctl today --json` or `remindctl show --json` to inspect reminders
- Use `remindctl list --json` to inspect lists
- Use `remindctl status --json` to inspect authorization state
- Reminder IDs and display indexes come from `show` output; `complete`, `delete`, and `edit` accept either an index or an ID prefix

## Creating Reminders

`add` accepts the title as a positional argument or via `--title`, but not both.

Important options:

- `--list <name>` choose the target list
- `--due <date>` set the due date
- `--alarm <date>` set the alarm date
- `--notes <text>` add notes
- `--repeat <rule>` set recurrence
- `--priority <none|low|medium|high>` set priority
- `--location <address>` create a location trigger
- `--radius <meters>` adjust geofence radius
- `--leaving` trigger on leaving instead of arriving

If no list is provided, `remindctl` uses the Reminders app's default list. Do not assume the default is a specific list name.

## Editing Reminders

`edit` can update:

- `--title`
- `--list`
- `--due` or `--clear-due`
- `--alarm` or `--clear-alarm`
- `--notes`
- `--repeat` or `--no-repeat`
- `--priority`
- `--complete` or `--incomplete`

Reject conflicting combinations such as `--due` with `--clear-due`, `--alarm` with `--clear-alarm`, `--repeat` with `--no-repeat`, or `--complete` with `--incomplete`.

Use `edit --list <new-list>` to move a reminder between lists. Do not tell the user to delete and recreate the reminder for a move; the command already supports moving it directly.

## Dates

Accepted date inputs:

- `today`, `tomorrow`, `yesterday`
- `YYYY-MM-DD`
- `YYYY-MM-DD HH:mm`
- ISO 8601 with or without timezone

Rules:

- Date-only inputs create all-day reminders
- Date-time inputs create timed reminders
- Timed due reminders get a notification alarm at the due time unless `--alarm` overrides it

If the user provides only a calendar date, prefer a date-only value instead of inventing a time.

## Lists

- `remindctl list` prints all lists with reminder and overdue counts
- `remindctl list <name>` prints reminders in that list
- `remindctl list <name> --create` creates the list if missing
- `remindctl list <name> --delete` deletes the list
- `remindctl list <name> --rename <new-name>` renames the list
- `remindctl list <name> --force` skips confirmation for destructive list deletion

## Completion And Deletion

- `complete` and `delete` require one or more IDs or indexes
- `delete` prompts for confirmation unless `--force` or `--no-input` suppresses it
- `complete` supports `--dry-run`
- `delete` supports `--dry-run`

## Permissions

Use `remindctl status` first when permission state matters.

- `status` never prompts
- `authorize` triggers the system prompt when the state is `notDetermined`
- If access is denied, direct the user to `System Settings > Privacy & Security > Reminders`
- If the prompt does not appear, the current workaround is to run:

```bash
osascript -e 'tell application "Reminders" to get name of reminders'
```

## Response Discipline

- Confirm the reminder title, list, and due date before creating it if any of them are ambiguous
- Use the exact command syntax shown by the current implementation
- Do not reuse stale guidance about deleting and recreating reminders to move them between lists
- Do not assume a fixed default list name
