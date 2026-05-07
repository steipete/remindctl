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

  static func parseTags(_ rawValues: [String]) throws -> [String] {
    var tags: [String] = []
    var seen: Set<String> = []

    for raw in rawValues {
      for candidate in raw.split(separator: ",", omittingEmptySubsequences: false) {
        var tag = String(candidate).trimmingCharacters(in: .whitespacesAndNewlines)
        if tag.hasPrefix("#") {
          tag.removeFirst()
        }
        guard !tag.isEmpty else {
          throw RemindCoreError.operationFailed("Tag cannot be empty")
        }
        guard tag.range(of: #"^[A-Za-z0-9][A-Za-z0-9_-]*$"#, options: .regularExpression) != nil else {
          throw RemindCoreError.operationFailed("Invalid tag: \"\(tag)\"")
        }
        let key = tag.lowercased()
        if seen.insert(key).inserted {
          tags.append(tag)
        }
      }
    }

    return tags
  }

  static func parseTitleTags(_ rawTitle: String) -> (baseTitle: String, tags: [String]) {
    let pattern = #"(?:^|\s)#([A-Za-z0-9][A-Za-z0-9_-]*)$"#
    var title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    var extracted: [String] = []

    while !title.isEmpty,
      let range = title.range(of: pattern, options: .regularExpression)
    {
      let match = String(title[range])
      let tag =
        match
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .dropFirst()
      extracted.append(String(tag))
      title.removeSubrange(range)
      title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return (baseTitle: title, tags: extracted.reversed())
  }

  static func composeTitle(baseTitle: String, tags: [String]) -> String {
    let normalized = tags.map { "#\($0)" }.joined(separator: " ")
    guard !normalized.isEmpty else { return baseTitle }
    guard !baseTitle.isEmpty else { return normalized }
    return "\(baseTitle) \(normalized)"
  }

  static func mergeTags(existing: [String], add: [String], remove: [String], clear: Bool) -> [String] {
    var current = clear ? [] : existing

    if !remove.isEmpty {
      let removeSet = Set(remove.map { $0.lowercased() })
      current.removeAll { removeSet.contains($0.lowercased()) }
    }

    var seen = Set(current.map { $0.lowercased() })
    for tag in add {
      let key = tag.lowercased()
      if seen.insert(key).inserted {
        current.append(tag)
      }
    }

    return current
  }
}
