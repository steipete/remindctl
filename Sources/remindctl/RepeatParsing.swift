import Foundation
import RemindCore

enum RepeatParsing {
  static func parseFrequency(_ value: String) throws -> ReminderRecurrenceFrequency {
    switch value.lowercased() {
    case "daily":
      return .daily
    case "weekly":
      return .weekly
    default:
      throw RemindCoreError.operationFailed("Invalid repeat frequency: \"\(value)\" (use daily|weekly)")
    }
  }

  static func parseInterval(_ value: String) throws -> Int {
    guard let interval = Int(value), interval > 0 else {
      throw RemindCoreError.operationFailed("Invalid interval: \"\(value)\" (use a positive integer)")
    }
    return interval
  }

  static func parseCount(_ value: String) throws -> Int {
    guard let count = Int(value), count > 0 else {
      throw RemindCoreError.operationFailed("Invalid count: \"\(value)\" (use a positive integer)")
    }
    return count
  }

  static func parseRecurrence(
    frequency: String,
    interval: String?,
    count: String?,
    until: String?,
    on: String?
  ) throws -> ReminderRecurrence {
    if count != nil && until != nil {
      throw RemindCoreError.operationFailed("Use either --count or --until, not both")
    }

    let parsedFrequency = try parseFrequency(frequency)
    let parsedInterval = try interval.map(parseInterval) ?? 1
    let daysOfWeek = try on.map { try parseWeekdays($0) }
    if daysOfWeek != nil && parsedFrequency != .weekly {
      throw RemindCoreError.operationFailed("--on is only supported with weekly repeats")
    }

    let end: ReminderRecurrenceEnd?
    if let count {
      end = .count(try parseCount(count))
    } else if let until {
      guard let parsedUntil = DateParsing.parseUserDate(until) else {
        throw RemindCoreError.invalidDate(until)
      }
      end = .until(parsedUntil)
    } else {
      end = nil
    }

    return ReminderRecurrence(
      frequency: parsedFrequency,
      interval: parsedInterval,
      daysOfWeek: daysOfWeek,
      end: end
    )
  }

  private static func parseWeekdays(_ value: String) throws -> [ReminderWeekday] {
    let tokens = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !tokens.isEmpty else {
      throw RemindCoreError.operationFailed("Invalid weekdays: \"\(value)\"")
    }

    var weekdays: [ReminderWeekday] = []
    var seen = Set<ReminderWeekday>()
    for token in tokens where !token.isEmpty {
      guard let day = parseWeekday(String(token)) else {
        throw RemindCoreError.operationFailed("Invalid weekday: \"\(token)\"")
      }
      if seen.insert(day).inserted {
        weekdays.append(day)
      }
    }
    return weekdays
  }

  private static func parseWeekday(_ value: String) -> ReminderWeekday? {
    switch value.lowercased() {
    case "mon", "monday":
      return .monday
    case "tue", "tues", "tuesday":
      return .tuesday
    case "wed", "weds", "wednesday":
      return .wednesday
    case "thu", "thur", "thurs", "thursday":
      return .thursday
    case "fri", "friday":
      return .friday
    case "sat", "saturday":
      return .saturday
    case "sun", "sunday":
      return .sunday
    default:
      return nil
    }
  }
}
