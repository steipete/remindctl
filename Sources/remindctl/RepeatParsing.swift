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
    let setpos: String?
    let month: String?
    let week: String?
  }

  static func parseFrequency(_ value: String) throws -> ReminderRecurrenceFrequency {
    switch value.lowercased() {
    case "daily":
      return .daily
    case "weekly":
      return .weekly
    case "monthly":
      return .monthly
    case "yearly":
      return .yearly
    default:
      throw RemindCoreError.operationFailed("Invalid repeat frequency: \"\(value)\" (use daily|weekly|monthly|yearly)")
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
    let setPositions = try input.setpos.map { try parseSetPositions($0) }
    let monthsOfYear = try input.month.map { try parseMonths($0) }
    let weeksOfYear = try input.week.map { try parseWeeks($0) }
    if daysOfWeek != nil {
      switch parsedFrequency {
      case .weekly:
        break
      case .monthly:
        if setPositions == nil {
          throw RemindCoreError.operationFailed("--on requires --setpos for monthly repeats")
        }
      default:
        throw RemindCoreError.operationFailed("--on is only supported with weekly repeats")
      }
    }
    if daysOfMonth != nil && parsedFrequency != .monthly {
      throw RemindCoreError.operationFailed("--month-day is only supported with monthly repeats")
    }
    if setPositions != nil && parsedFrequency != .monthly {
      throw RemindCoreError.operationFailed("--setpos is only supported with monthly repeats")
    }
    if setPositions != nil && daysOfWeek == nil {
      throw RemindCoreError.operationFailed("--setpos requires --on")
    }
    if monthsOfYear != nil && parsedFrequency != .yearly {
      throw RemindCoreError.operationFailed("--month is only supported with yearly repeats")
    }
    if weeksOfYear != nil && parsedFrequency != .yearly {
      throw RemindCoreError.operationFailed("--week is only supported with yearly repeats")
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
      setPositions: setPositions,
      monthsOfYear: monthsOfYear,
      weeksOfYear: weeksOfYear,
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

  private static func parseSetPositions(_ value: String) throws -> [Int] {
    let tokens = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !tokens.isEmpty else {
      throw RemindCoreError.operationFailed("Invalid set positions: \"\(value)\"")
    }

    var positions: [Int] = []
    var seen = Set<Int>()
    for token in tokens where !token.isEmpty {
      guard let position = Int(token), isValidSetPosition(position) else {
        throw RemindCoreError.operationFailed("Invalid set position: \"\(token)\"")
      }
      if seen.insert(position).inserted {
        positions.append(position)
      }
    }
    return positions
  }

  private static func isValidSetPosition(_ value: Int) -> Bool {
    value == -1 || (1...4).contains(value)
  }

  private static func parseMonths(_ value: String) throws -> [Int] {
    let tokens = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !tokens.isEmpty else {
      throw RemindCoreError.operationFailed("Invalid months: \"\(value)\"")
    }

    var months: [Int] = []
    var seen = Set<Int>()
    for token in tokens where !token.isEmpty {
      guard let month = parseMonth(String(token)) else {
        throw RemindCoreError.operationFailed("Invalid month: \"\(token)\"")
      }
      if seen.insert(month).inserted {
        months.append(month)
      }
    }
    return months
  }

  private static func parseMonth(_ value: String) -> Int? {
    if let month = Int(value), (1...12).contains(month) {
      return month
    }

    switch value.lowercased() {
    case "jan", "january":
      return 1
    case "feb", "february":
      return 2
    case "mar", "march":
      return 3
    case "apr", "april":
      return 4
    case "may":
      return 5
    case "jun", "june":
      return 6
    case "jul", "july":
      return 7
    case "aug", "august":
      return 8
    case "sep", "sept", "september":
      return 9
    case "oct", "october":
      return 10
    case "nov", "november":
      return 11
    case "dec", "december":
      return 12
    default:
      return nil
    }
  }

  private static func parseWeeks(_ value: String) throws -> [Int] {
    let tokens = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !tokens.isEmpty else {
      throw RemindCoreError.operationFailed("Invalid weeks: \"\(value)\"")
    }

    var weeks: [Int] = []
    var seen = Set<Int>()
    for token in tokens where !token.isEmpty {
      guard let week = Int(token), (1...53).contains(week) else {
        throw RemindCoreError.operationFailed("Invalid week: \"\(token)\"")
      }
      if seen.insert(week).inserted {
        weeks.append(week)
      }
    }
    return weeks
  }
}
