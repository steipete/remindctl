import EventKit
import Foundation

enum RecurrenceAdapter {
  static func rule(from recurrence: ReminderRecurrence) -> EKRecurrenceRule {
    let frequency = eventKitFrequency(from: recurrence.frequency)
    let interval = max(recurrence.interval, 1)
    let end = recurrence.end.map(recurrenceEnd(from:))
    return EKRecurrenceRule(recurrenceWith: frequency, interval: interval, end: end)
  }

  static func recurrence(from rule: EKRecurrenceRule) -> ReminderRecurrence? {
    guard let frequency = reminderFrequency(from: rule.frequency) else {
      return nil
    }
    let interval = max(rule.interval, 1)
    let end = rule.recurrenceEnd.flatMap(reminderEnd(from:))
    return ReminderRecurrence(frequency: frequency, interval: interval, end: end)
  }

  private static func eventKitFrequency(from frequency: ReminderRecurrenceFrequency) -> EKRecurrenceFrequency {
    switch frequency {
    case .daily:
      return .daily
    case .weekly:
      return .weekly
    }
  }

  private static func reminderFrequency(from frequency: EKRecurrenceFrequency) -> ReminderRecurrenceFrequency? {
    switch frequency {
    case .daily:
      return .daily
    case .weekly:
      return .weekly
    default:
      return nil
    }
  }

  private static func recurrenceEnd(from end: ReminderRecurrenceEnd) -> EKRecurrenceEnd {
    switch end {
    case .count(let count):
      return EKRecurrenceEnd(occurrenceCount: max(count, 1))
    case .until(let date):
      return EKRecurrenceEnd(end: date)
    }
  }

  private static func reminderEnd(from end: EKRecurrenceEnd) -> ReminderRecurrenceEnd? {
    if end.occurrenceCount > 0 {
      return .count(end.occurrenceCount)
    }
    if let endDate = end.endDate {
      return .until(endDate)
    }
    return nil
  }
}
