import EventKit
import Foundation

enum RecurrenceAdapter {
  static func rule(from recurrence: ReminderRecurrence) -> EKRecurrenceRule {
    let frequency = eventKitFrequency(from: recurrence.frequency)
    let interval = max(recurrence.interval, 1)
    let end = recurrence.end.map(recurrenceEnd(from:))
    let daysOfWeek = recurrence.daysOfWeek?
      .sorted { $0.displayOrder < $1.displayOrder }
      .compactMap(eventKitDayOfWeek(from:))
    let daysOfMonth = recurrence.daysOfMonth?.sorted().map { NSNumber(value: $0) }
    let setPositions = recurrence.setPositions?.sorted().map { NSNumber(value: $0) }
    let monthsOfYear = recurrence.monthsOfYear?.sorted().map { NSNumber(value: $0) }
    let weeksOfYear = recurrence.weeksOfYear?.sorted().map { NSNumber(value: $0) }
    return EKRecurrenceRule(
      recurrenceWith: frequency,
      interval: interval,
      daysOfTheWeek: daysOfWeek,
      daysOfTheMonth: daysOfMonth,
      monthsOfTheYear: monthsOfYear,
      weeksOfTheYear: weeksOfYear,
      daysOfTheYear: nil,
      setPositions: setPositions,
      end: end
    )
  }

  static func recurrence(from rule: EKRecurrenceRule) -> ReminderRecurrence? {
    guard let frequency = reminderFrequency(from: rule.frequency) else {
      return nil
    }
    let interval = max(rule.interval, 1)
    let end = rule.recurrenceEnd.flatMap(reminderEnd(from:))
    let daysOfWeek = rule.daysOfTheWeek?
      .compactMap(reminderDayOfWeek(from:))
      .sorted { $0.displayOrder < $1.displayOrder }
    let daysOfMonth = rule.daysOfTheMonth?.map { $0.intValue }.sorted()
    let setPositions = rule.setPositions?.map { $0.intValue }.sorted()
    let monthsOfYear = rule.monthsOfTheYear?.map { $0.intValue }.sorted()
    let weeksOfYear = rule.weeksOfTheYear?.map { $0.intValue }.sorted()
    return ReminderRecurrence(
      frequency: frequency,
      interval: interval,
      daysOfWeek: daysOfWeek,
      daysOfMonth: daysOfMonth,
      setPositions: setPositions,
      monthsOfYear: monthsOfYear,
      weeksOfYear: weeksOfYear,
      end: end
    )
  }

  private static func eventKitFrequency(from frequency: ReminderRecurrenceFrequency) -> EKRecurrenceFrequency {
    switch frequency {
    case .daily:
      return .daily
    case .weekly:
      return .weekly
    case .monthly:
      return .monthly
    case .yearly:
      return .yearly
    }
  }

  private static func reminderFrequency(from frequency: EKRecurrenceFrequency) -> ReminderRecurrenceFrequency? {
    switch frequency {
    case .daily:
      return .daily
    case .weekly:
      return .weekly
    case .monthly:
      return .monthly
    case .yearly:
      return .yearly
    default:
      return nil
    }
  }

  private static func eventKitDayOfWeek(from day: ReminderWeekday) -> EKRecurrenceDayOfWeek {
    EKRecurrenceDayOfWeek(dayOfTheWeek: eventKitWeekday(from: day), weekNumber: 0)
  }

  private static func reminderDayOfWeek(from day: EKRecurrenceDayOfWeek) -> ReminderWeekday? {
    reminderWeekday(from: day.dayOfTheWeek)
  }

  private static func eventKitWeekday(from day: ReminderWeekday) -> EKWeekday {
    switch day {
    case .sunday:
      return .sunday
    case .monday:
      return .monday
    case .tuesday:
      return .tuesday
    case .wednesday:
      return .wednesday
    case .thursday:
      return .thursday
    case .friday:
      return .friday
    case .saturday:
      return .saturday
    }
  }

  private static func reminderWeekday(from day: EKWeekday) -> ReminderWeekday? {
    switch day {
    case .sunday:
      return .sunday
    case .monday:
      return .monday
    case .tuesday:
      return .tuesday
    case .wednesday:
      return .wednesday
    case .thursday:
      return .thursday
    case .friday:
      return .friday
    case .saturday:
      return .saturday
    @unknown default:
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
