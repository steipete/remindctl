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
    until: String?
  ) throws -> ReminderRecurrence {
    if count != nil && until != nil {
      throw RemindCoreError.operationFailed("Use either --count or --until, not both")
    }

    let parsedFrequency = try parseFrequency(frequency)
    let parsedInterval = try interval.map(parseInterval) ?? 1

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
      end: end
    )
  }
}
