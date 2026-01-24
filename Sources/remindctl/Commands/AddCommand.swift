import Commander
import Foundation
import RemindCore

enum AddCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "add",
      abstract: "Add a reminder",
      discussion: "Provide a title as an argument or via --title.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "title", help: "Reminder title", isOptional: true)
          ],
          options: [
            .make(label: "title", names: [.long("title")], help: "Reminder title", parsing: .singleValue),
            .make(label: "list", names: [.short("l"), .long("list")], help: "List name", parsing: .singleValue),
            .make(label: "due", names: [.short("d"), .long("due")], help: "Due date", parsing: .singleValue),
            .make(label: "notes", names: [.short("n"), .long("notes")], help: "Notes", parsing: .singleValue),
            .make(label: "repeat", names: [.long("repeat")], help: "daily|weekly|monthly", parsing: .singleValue),
            .make(label: "interval", names: [.long("interval")], help: "Repeat interval", parsing: .singleValue),
            .make(label: "on", names: [.long("on")], help: "Weekdays (mon,tue,...)", parsing: .singleValue),
            .make(label: "monthDay", names: [.long("month-day")], help: "Days of month (1-31)", parsing: .singleValue),
            .make(label: "count", names: [.long("count")], help: "Repeat occurrence count", parsing: .singleValue),
            .make(label: "until", names: [.long("until")], help: "Repeat end date", parsing: .singleValue),
            .make(
              label: "priority",
              names: [.short("p"), .long("priority")],
              help: "none|low|medium|high",
              parsing: .singleValue
            ),
          ]
        )
      ),
      usageExamples: [
        "remindctl add \"Buy milk\"",
        "remindctl add --title \"Call mom\" --list Personal --due tomorrow",
        "remindctl add \"Review docs\" --priority high",
      ]
    ) { values, runtime in
      let titleOption = values.option("title")
      let titleArg = values.argument(0)
      if titleOption != nil && titleArg != nil {
        throw RemindCoreError.operationFailed("Provide title either as argument or via --title")
      }

      var title = titleOption ?? titleArg
      if title == nil {
        if runtime.noInput || !Console.isTTY {
          throw RemindCoreError.operationFailed("Missing title. Provide it as an argument or via --title.")
        }
        title = Console.readLine(prompt: "Title:")?.trimmingCharacters(in: .whitespacesAndNewlines)
        if title?.isEmpty == true { title = nil }
      }

      guard let title else {
        throw RemindCoreError.operationFailed("Missing title.")
      }

      let listName = values.option("list")
      let notes = values.option("notes")
      let dueValue = values.option("due")
      let repeatValue = values.option("repeat")
      let intervalValue = values.option("interval")
      let onValue = values.option("on")
      let monthDayValue = values.option("monthDay")
      let countValue = values.option("count")
      let untilValue = values.option("until")
      let priorityValue = values.option("priority")

      let hasRepeatModifiers = [intervalValue, onValue, monthDayValue, countValue, untilValue]
        .contains { $0 != nil }
      if repeatValue == nil && hasRepeatModifiers {
        throw RemindCoreError.operationFailed("Use --repeat with --interval, --on, --month-day, --count, or --until")
      }

      var dueDate = try dueValue.map(CommandHelpers.parseDueDate)
      let recurrence = try repeatValue.map {
        try RepeatParsing.parseRecurrence(
          .init(
            frequency: $0,
            interval: intervalValue,
            count: countValue,
            until: untilValue,
            on: onValue,
            monthDay: monthDayValue
          )
        )
      }

      if recurrence != nil && dueDate == nil {
        dueDate = Date()
      }
      let priority = try priorityValue.map(CommandHelpers.parsePriority) ?? .none

      let store = RemindersStore()
      try await store.requestAccess()

      let targetList: String?
      if let listName {
        targetList = listName
      } else {
        targetList = await store.defaultListName()
      }
      guard let targetList else {
        throw RemindCoreError.operationFailed("No default list found. Specify --list.")
      }

      let draft = ReminderDraft(
        title: title,
        notes: notes,
        dueDate: dueDate,
        priority: priority,
        recurrence: recurrence
      )
      let reminder = try await store.createReminder(draft, listName: targetList)
      OutputRenderer.printReminder(reminder, format: runtime.outputFormat)
    }
  }
}
