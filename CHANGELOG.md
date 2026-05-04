# Changelog

## 0.2.0 - 2026-05-04
- Accept local ISO 8601 due dates without a timezone suffix
- Preserve date-only due inputs as all-day reminders instead of midnight reminders
- Allow `list` to show reminders from multiple list names in one command

## 0.1.1 - 2026-01-11
- Fix Swift 6 strict concurrency crash when fetching reminders

## 0.1.0 - 2026-01-03
- Reminders CLI with Commander-based command router
- Show reminders with filters (today/tomorrow/week/overdue/upcoming/completed/all/date)
- Manage lists (list, create, rename, delete)
- Add, edit, complete, and delete reminders
- Authorization status and permission prompt command
- JSON and plain output modes for scripting
- Flexible date parsing (relative, ISO 8601, and common formats)
- GitHub Actions CI with lint, tests, and coverage gate
