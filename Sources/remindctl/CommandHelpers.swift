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

  static func parseDueDate(_ value: String) throws -> Date {
    guard let date = DateParsing.parseUserDate(value) else {
      throw RemindCoreError.invalidDate(value)
    }
    return date
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
      let tag = match
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
