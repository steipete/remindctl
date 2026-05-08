import Foundation
import RemindCore

enum CommandHelpers {
  static func parsePriority(_ value: String) throws -> ReminderPriority {
    switch value.lowercased() {
    case "none":
      return .none
    case "low":
      return .low
    case "medium", "med":
      return .medium
    case "high":
      return .high
    default:
      throw RemindCoreError.operationFailed("Invalid priority: \"\(value)\" (use none|low|medium|high)")
    }
  }

  static func parseDueDate(_ value: String) throws -> ParsedUserDate {
    guard let parsed = DateParsing.parseUserDateWithMetadata(value) else {
      throw RemindCoreError.invalidDate(value)
    }
    return parsed
  }

  static func parseRecurrence(_ value: String) throws -> RecurrenceRule {
    let normalized = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    switch normalized {
    case "daily":
      return RecurrenceRule(frequency: .daily)
    case "weekly":
      return RecurrenceRule(frequency: .weekly)
    case "biweekly":
      return RecurrenceRule(frequency: .weekly, interval: 2)
    case "monthly":
      return RecurrenceRule(frequency: .monthly)
    case "yearly", "annually":
      return RecurrenceRule(frequency: .yearly)
    default:
      return try parseCustomRecurrence(normalized, original: value)
    }
  }

  static func resolveShowIdentifiers(_ inputs: [String], from reminders: [ReminderItem]) throws -> [ReminderItem] {
    let defaultShowReminders = ReminderFiltering.apply(reminders, filter: .today)
    return try IDResolver.resolve(inputs, from: reminders, numericFrom: defaultShowReminders)
  }

  private static func parseCustomRecurrence(_ normalized: String, original: String) throws -> RecurrenceRule {
    let parts = normalized.split(separator: " ")
    guard parts.count == 3, parts[0] == "every", let interval = Int(parts[1]), interval > 0 else {
      throw invalidRecurrence(original)
    }

    let frequency: RecurrenceFrequency
    switch parts[2] {
    case "day", "days":
      frequency = .daily
    case "week", "weeks":
      frequency = .weekly
    case "month", "months":
      frequency = .monthly
    case "year", "years":
      frequency = .yearly
    default:
      throw invalidRecurrence(original)
    }
    return RecurrenceRule(frequency: frequency, interval: interval)
  }

  private static func invalidRecurrence(_ value: String) -> RemindCoreError {
    RemindCoreError.operationFailed(
      """
      Invalid repeat value: "\(value)" \
      (use daily|weekly|biweekly|monthly|yearly or "every N days/weeks/months/years")
      """
    )
  }
}
