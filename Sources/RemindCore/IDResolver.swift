import Foundation

public enum IDResolver {
  public static let minimumPrefixLength = 4

  public static func resolve(
    _ inputs: [String],
    from reminders: [ReminderItem],
    numericFrom numericReminders: [ReminderItem]? = nil
  ) throws -> [ReminderItem] {
    let sorted = ReminderFiltering.sort(reminders)
    let numericSorted = ReminderFiltering.sort(numericReminders ?? reminders)
    var resolved: [ReminderItem] = []
    for input in inputs {
      let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
      if let index = Int(trimmed) {
        let idx = index - 1
        guard idx >= 0 && idx < numericSorted.count else {
          throw RemindCoreError.invalidIdentifier(trimmed)
        }
        resolved.append(numericSorted[idx])
        continue
      }

      if trimmed.count < minimumPrefixLength {
        throw RemindCoreError.invalidIdentifier(trimmed)
      }

      let matches = sorted.filter { $0.id.lowercased().hasPrefix(trimmed.lowercased()) }
      if matches.isEmpty {
        throw RemindCoreError.reminderNotFound(trimmed)
      }
      if matches.count > 1 {
        throw RemindCoreError.ambiguousIdentifier(trimmed, matches: matches.map { $0.id })
      }
      if let match = matches.first {
        resolved.append(match)
      }
    }
    return resolved
  }
}
