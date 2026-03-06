import Commander
import Foundation
import RemindCore

enum TagsCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "tags",
      abstract: "List tags or reminders for a tag",
      discussion: "Without an argument, prints all tags with counts. With a tag, shows reminders that match it.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "tag", help: "Tag name", isOptional: true)
          ]
        )
      ),
      usageExamples: [
        "remindctl tags",
        "remindctl tags shopping",
      ]
    ) { values, runtime in
      let requestedTag = values.argument(0)

      let store = RemindersStore()
      try await store.requestAccess()
      let reminders = try await store.reminders(in: nil)

      if let requestedTag {
        let parsed = try CommandHelpers.parseTags([requestedTag])
        guard let filterTag = parsed.first, parsed.count == 1 else {
          throw RemindCoreError.operationFailed("Provide a single tag")
        }
        let key = filterTag.lowercased()
        let matching = reminders.filter { reminder in
          reminder.tags.contains { $0.lowercased() == key }
        }
        OutputRenderer.printReminders(matching, format: runtime.outputFormat)
        return
      }

      var byKey: [String: TagSummary] = [:]
      for reminder in reminders {
        for tag in reminder.tags {
          let key = tag.lowercased()
          let existing = byKey[key]
          byKey[key] = TagSummary(tag: existing?.tag ?? tag, count: (existing?.count ?? 0) + 1)
        }
      }

      OutputRenderer.printTagSummaries(Array(byKey.values), format: runtime.outputFormat)
    }
  }
}
