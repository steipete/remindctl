import Foundation
import RemindCore

enum OutputFormat {
  case standard
  case plain
  case json
  case quiet
}

struct ListSummary: Codable, Sendable, Equatable {
  let id: String
  let title: String
  let reminderCount: Int
  let overdueCount: Int
}

struct AuthorizationSummary: Codable, Sendable, Equatable {
  let status: String
  let authorized: Bool
}

struct TagSummary: Codable, Sendable, Equatable {
  let tag: String
  let count: Int
}

struct ReminderOutput: Codable, Sendable, Equatable {
  let id: String
  let title: String
  let titleWithoutTags: String
  let tags: [String]
  let notes: String?
  let url: URL?
  let isCompleted: Bool
  let completionDate: Date?
  let creationDate: Date?
  let lastModifiedDate: Date?
  let priority: ReminderPriority
  let dueDate: Date?
  let dueDateIsAllDay: Bool
  let alarmDate: Date?
  let recurrenceRule: RecurrenceRule?
  let locationTrigger: LocationTrigger?
  let listID: String
  let listName: String

  init(reminder: ReminderItem) {
    id = reminder.id
    title = reminder.title
    titleWithoutTags = reminder.titleWithoutTags
    tags = reminder.tags
    notes = reminder.notes
    url = reminder.url
    isCompleted = reminder.isCompleted
    completionDate = reminder.completionDate
    creationDate = reminder.creationDate
    lastModifiedDate = reminder.lastModifiedDate
    priority = reminder.priority
    dueDate = reminder.dueDate
    dueDateIsAllDay = reminder.dueDateIsAllDay
    alarmDate = reminder.alarmDate
    recurrenceRule = reminder.recurrenceRule
    locationTrigger = reminder.locationTrigger
    listID = reminder.listID
    listName = reminder.listName
  }
}

enum OutputRenderer {
  static func printReminders(_ reminders: [ReminderItem], format: OutputFormat) {
    switch format {
    case .standard:
      printRemindersStandard(reminders)
    case .plain:
      printRemindersPlain(reminders)
    case .json:
      printJSON(reminders.map(ReminderOutput.init))
    case .quiet:
      Swift.print(reminders.count)
    }
  }

  static func printLists(_ summaries: [ListSummary], format: OutputFormat) {
    switch format {
    case .standard:
      printListsStandard(summaries)
    case .plain:
      printListsPlain(summaries)
    case .json:
      printJSON(summaries)
    case .quiet:
      Swift.print(summaries.count)
    }
  }

  static func printReminder(_ reminder: ReminderItem, format: OutputFormat) {
    switch format {
    case .standard:
      let due =
        reminder.dueDate.map {
          DateParsing.formatDisplay($0, isDateOnly: reminder.dueDateIsAllDay)
        } ?? "no due date"
      let recurrence = recurrenceSuffix(for: reminder)
      Swift.print("✓ \(displayTitle(for: reminder)) [\(reminder.listName)] — \(due)\(recurrence)")
    case .plain:
      Swift.print(plainLine(for: reminder))
    case .json:
      printJSON(ReminderOutput(reminder: reminder))
    case .quiet:
      break
    }
  }

  static func printTagSummaries(_ summaries: [TagSummary], format: OutputFormat) {
    switch format {
    case .standard:
      guard !summaries.isEmpty else {
        Swift.print("No tags found")
        return
      }
      for summary in summaries.sorted(by: { $0.tag.localizedCaseInsensitiveCompare($1.tag) == .orderedAscending }) {
        Swift.print("#\(summary.tag)\t\(summary.count)")
      }
    case .plain:
      for summary in summaries.sorted(by: { $0.tag.localizedCaseInsensitiveCompare($1.tag) == .orderedAscending }) {
        Swift.print("\(summary.tag)\t\(summary.count)")
      }
    case .json:
      printJSON(summaries)
    case .quiet:
      Swift.print(summaries.count)
    }
  }

  static func printDeleteResult(_ count: Int, format: OutputFormat) {
    switch format {
    case .standard:
      Swift.print("Deleted \(count) reminder(s)")
    case .plain:
      Swift.print("\(count)")
    case .json:
      let payload = ["deleted": count]
      printJSON(payload)
    case .quiet:
      break
    }
  }

  static func printAuthorizationStatus(_ status: RemindersAuthorizationStatus, format: OutputFormat) {
    switch format {
    case .standard:
      Swift.print("Reminders access: \(status.displayName)")
    case .plain:
      Swift.print(status.rawValue)
    case .json:
      printJSON(AuthorizationSummary(status: status.rawValue, authorized: status.isAuthorized))
    case .quiet:
      Swift.print(status.isAuthorized ? "1" : "0")
    }
  }

  private static func printRemindersStandard(_ reminders: [ReminderItem]) {
    let sorted = ReminderFiltering.sort(reminders)
    guard !sorted.isEmpty else {
      Swift.print("No reminders found")
      return
    }
    for (index, reminder) in sorted.enumerated() {
      let status = reminder.isCompleted ? "x" : " "
      let due =
        reminder.dueDate.map {
          DateParsing.formatDisplay($0, isDateOnly: reminder.dueDateIsAllDay)
        } ?? "no due date"
      let priority = reminder.priority == .none ? "" : " priority=\(reminder.priority.rawValue)"
      let recurrence = recurrenceSuffix(for: reminder)
      Swift.print(
        "[\(index + 1)] [\(status)] \(displayTitle(for: reminder)) [\(reminder.listName)] — \(due)\(priority)\(recurrence)")
    }
  }

  private static func printRemindersPlain(_ reminders: [ReminderItem]) {
    let sorted = ReminderFiltering.sort(reminders)
    for reminder in sorted {
      Swift.print(plainLine(for: reminder))
    }
  }

  private static func plainLine(for reminder: ReminderItem) -> String {
    let due: String
    if let dueDate = reminder.dueDate {
      due =
        reminder.dueDateIsAllDay
        ? dateOnlyFormatter().string(from: dueDate)
        : isoFormatter().string(from: dueDate)
    } else {
      due = ""
    }
    return [
      reminder.id,
      reminder.listName,
      reminder.isCompleted ? "1" : "0",
      reminder.priority.rawValue,
      due,
      reminder.title,
    ].joined(separator: "\t")
  }

  private static func displayTitle(for reminder: ReminderItem) -> String {
    let tags = reminder.tags.map { "#\($0)" }.joined(separator: " ")
    if tags.isEmpty {
      return reminder.titleWithoutTags
    }
    if reminder.titleWithoutTags.isEmpty {
      return tags
    }
    return "\(reminder.titleWithoutTags) \(tags)"
  }

  private static func printListsStandard(_ summaries: [ListSummary]) {
    guard !summaries.isEmpty else {
      Swift.print("No reminder lists found")
      return
    }
    for summary in summaries.sorted(by: { $0.title < $1.title }) {
      let overdue = summary.overdueCount > 0 ? " (\(summary.overdueCount) overdue)" : ""
      Swift.print("\(summary.title) — \(summary.reminderCount) reminders\(overdue)")
    }
  }

  private static func printListsPlain(_ summaries: [ListSummary]) {
    for summary in summaries.sorted(by: { $0.title < $1.title }) {
      Swift.print("\(summary.title)\t\(summary.reminderCount)\t\(summary.overdueCount)")
    }
  }

  private static func printJSON<T: Encodable>(_ payload: T) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    do {
      let data = try encoder.encode(payload)
      if let json = String(data: data, encoding: .utf8) {
        Swift.print(json)
      }
    } catch {
      Swift.print("Failed to encode JSON: \(error)")
    }
  }

  private static func isoFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }

  private static func dateOnlyFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }

  private static func recurrenceSuffix(for reminder: ReminderItem) -> String {
    reminder.recurrenceRule.map { " repeat=\($0.displayString)" } ?? ""
  }
}
