import Foundation
import RemindCore

enum RepeatParsing {
  struct RepeatInput {
    let frequency: String
    let interval: String?
    let count: String?
    let until: String?
    let on: String?
    let monthDay: String?
  }

  static func parseFrequency(_ value: String) throws -> ReminderRecurrenceFrequency {
    switch value.lowercased() {
    case "daily":
      return .daily
    case "weekly":
      return .weekly
    case "monthly":
      return .monthly
    default:
      throw RemindCoreError.operationFailed("Invalid repeat frequency: \"\(value)\" (use daily|weekly|monthly)")
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

  static func parseRecurrence(_ input: RepeatInput) throws -> ReminderRecurrence {
    if input.count != nil && input.until != nil {
      throw RemindCoreError.operationFailed("Use either --count or --until, not both")
    }

    let parsedFrequency = try parseFrequency(input.frequency)
    let parsedInterval = try input.interval.map(parseInterval) ?? 1
    let daysOfWeek = try input.on.map { try parseWeekdays($0) }
    let daysOfMonth = try input.monthDay.map { try parseMonthDays($0) }
    if daysOfWeek != nil && parsedFrequency != .weekly {
      throw RemindCoreError.operationFailed("--on is only supported with weekly repeats")
    }
    if daysOfMonth != nil && parsedFrequency != .monthly {
      throw RemindCoreError.operationFailed("--month-day is only supported with monthly repeats")
    }

    let end: ReminderRecurrenceEnd?
    if let count = input.count {
      end = .count(try parseCount(count))
    } else if let until = input.until {
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
      daysOfMonth: daysOfMonth,
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

  private static func parseMonthDays(_ value: String) throws -> [Int] {
    let tokens = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !tokens.isEmpty else {
      throw RemindCoreError.operationFailed("Invalid month days: \"\(value)\"")
    }

    var days: [Int] = []
    var seen = Set<Int>()
    for token in tokens where !token.isEmpty {
      guard let day = Int(token), (1...31).contains(day) else {
        throw RemindCoreError.operationFailed("Invalid month day: \"\(token)\"")
      }
      if seen.insert(day).inserted {
        days.append(day)
      }
    }
    return days
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
