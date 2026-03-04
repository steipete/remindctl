import Foundation
import RemindCore

enum CommandHelpers {
  struct ParsedDueDate {
    let date: Date
    let isAllDay: Bool
  }

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

  static func parseDueDate(_ value: String) throws -> Date {
    guard let date = DateParsing.parseUserDate(value) else {
      throw RemindCoreError.invalidDate(value)
    }
    return date
  }

  static func parseAddDueDate(_ value: String, forceAllDay: Bool) throws -> ParsedDueDate {
    let date = try parseDueDate(value)
    let isAllDay = forceAllDay || isDateOnlyInput(value)
    return ParsedDueDate(date: date, isAllDay: isAllDay)
  }

  private static func isDateOnlyInput(_ value: String) -> Bool {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    let patterns = [
      #"^\d{4}-\d{2}-\d{2}$"#,
      #"^\d{1,2}/\d{1,2}/\d{4}$"#,
      #"^\d{1,2}-\d{1,2}-(\d{2}|\d{4})$"#,
    ]
    return patterns.contains { pattern in
      trimmed.range(of: pattern, options: .regularExpression) != nil
    }
  }
}
