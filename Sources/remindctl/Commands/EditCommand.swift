import Commander
import Foundation
import RemindCore

enum EditCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "edit",
      abstract: "Edit a reminder",
      discussion: "Use an index or ID prefix from the show output.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "id", help: "Index or ID prefix", isOptional: false)
          ],
          options: [
            .make(label: "title", names: [.short("t"), .long("title")], help: "New title", parsing: .singleValue),
            .make(label: "list", names: [.short("l"), .long("list")], help: "Move to list", parsing: .singleValue),
            .make(label: "due", names: [.short("d"), .long("due")], help: "Set due date", parsing: .singleValue),
            .make(label: "notes", names: [.short("n"), .long("notes")], help: "Set notes", parsing: .singleValue),
            .make(
              label: "repeat",
              names: [.long("repeat")],
              help: "daily|weekly|monthly|yearly|none",
              parsing: .singleValue
            ),
            .make(label: "interval", names: [.long("interval")], help: "Repeat interval", parsing: .singleValue),
            .make(label: "on", names: [.long("on")], help: "Weekdays (mon,tue,...)", parsing: .singleValue),
            .make(
              label: "monthDay",
              names: [.long("month-day")],
              help: "Days of month (1-31)",
              parsing: .singleValue
            ),
            .make(
              label: "setpos",
              names: [.long("setpos")],
              help: "Week of month (-1,1-4)",
              parsing: .singleValue
            ),
            .make(
              label: "month",
              names: [.long("month")],
              help: "Months (1-12 or jan-dec)",
              parsing: .singleValue
            ),
            .make(
              label: "week",
              names: [.long("week")],
              help: "Weeks of year (1-53)",
              parsing: .singleValue
            ),
            .make(label: "count", names: [.long("count")], help: "Repeat occurrence count", parsing: .singleValue),
            .make(label: "until", names: [.long("until")], help: "Repeat end date", parsing: .singleValue),
            .make(
              label: "priority",
              names: [.short("p"), .long("priority")],
              help: "none|low|medium|high",
              parsing: .singleValue
            ),
          ],
          flags: [
            .make(label: "clearDue", names: [.long("clear-due")], help: "Clear due date"),
            .make(label: "complete", names: [.long("complete")], help: "Mark completed"),
            .make(label: "incomplete", names: [.long("incomplete")], help: "Mark incomplete"),
          ]
        )
      ),
      usageExamples: [
        "remindctl edit 1 --title \"New title\"",
        "remindctl edit 4A83 --due tomorrow",
        "remindctl edit 2 --priority high --notes \"Call before noon\"",
        "remindctl edit 3 --clear-due",
      ]
    ) { values, runtime in
      guard let input = values.argument(0) else {
        throw ParsedValuesError.missingArgument("id")
      }

      let store = RemindersStore()
      try await store.requestAccess()
      let reminders = try await store.reminders(in: nil)
      let resolved = try IDResolver.resolve([input], from: reminders)
      guard let reminder = resolved.first else {
        throw RemindCoreError.reminderNotFound(input)
      }

      let title = values.option("title")
      let listName = values.option("list")
      let notes = values.option("notes")
      let repeatValue = values.option("repeat")
      let intervalValue = values.option("interval")
      let onValue = values.option("on")
      let monthDayValue = values.option("monthDay")
      let setposValue = values.option("setpos")
      let monthValue = values.option("month")
      let weekValue = values.option("week")
      let countValue = values.option("count")
      let untilValue = values.option("until")

      var dueUpdate: Date??
      if let dueValue = values.option("due") {
        dueUpdate = try CommandHelpers.parseDueDate(dueValue)
      }
      if values.flag("clearDue") {
        if dueUpdate != nil {
          throw RemindCoreError.operationFailed("Use either --due or --clear-due, not both")
        }
        dueUpdate = .some(nil)
      }

      var priority: ReminderPriority?
      if let priorityValue = values.option("priority") {
        priority = try CommandHelpers.parsePriority(priorityValue)
      }

      let repeatInput = RepeatParsing.RepeatInput(
        frequency: repeatValue ?? "",
        interval: intervalValue,
        count: countValue,
        until: untilValue,
        on: onValue,
        monthDay: monthDayValue,
        setpos: setposValue,
        month: monthValue,
        week: weekValue
      )
      if repeatValue == nil && repeatInput.hasModifiers {
        throw RemindCoreError.operationFailed(
          "Use --repeat with --interval, --on, --month-day, --setpos, --month, --week, --count, or --until"
        )
      }

      let recurrenceUpdate: ReminderRecurrence?? = try {
        guard let repeatValue else { return nil }
        let input = RepeatParsing.RepeatInput(
          frequency: repeatValue,
          interval: intervalValue,
          count: countValue,
          until: untilValue,
          on: onValue,
          monthDay: monthDayValue,
          setpos: setposValue,
          month: monthValue,
          week: weekValue
        )
        let parsed = try RepeatParsing.parseRecurrenceOption(
          value: repeatValue,
          input: input,
          allowNone: true
        )
        if repeatValue.lowercased() == "none" {
          return .some(nil)
        }
        return parsed
      }()

      let completeFlag = values.flag("complete")
      let incompleteFlag = values.flag("incomplete")
      if completeFlag && incompleteFlag {
        throw RemindCoreError.operationFailed("Use either --complete or --incomplete, not both")
      }
      let isCompleted: Bool? = completeFlag ? true : (incompleteFlag ? false : nil)

      if recurrenceUpdate != nil && dueUpdate == nil && reminder.dueDate == nil {
        dueUpdate = .some(Date())
      }

      let hasChanges =
        title != nil
        || listName != nil
        || notes != nil
        || dueUpdate != nil
        || priority != nil
        || recurrenceUpdate != nil
        || isCompleted != nil

      if !hasChanges {
        throw RemindCoreError.operationFailed("No changes specified")
      }

      let update = ReminderUpdate(
        title: title,
        notes: notes,
        dueDate: dueUpdate,
        priority: priority,
        recurrence: recurrenceUpdate,
        listName: listName,
        isCompleted: isCompleted
      )

      let updated = try await store.updateReminder(id: reminder.id, update: update)
      OutputRenderer.printReminder(updated, format: runtime.outputFormat)
    }
  }
}
