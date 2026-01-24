import EventKit
import Foundation
import Testing

@testable import RemindCore

@MainActor
struct RecurrenceAdapterTests {
  @Test("Daily recurrence maps to EventKit and back")
  func dailyRoundTrip() {
    let recurrence = ReminderRecurrence(frequency: .daily, interval: 2, end: .count(5))
    let rule = RecurrenceAdapter.rule(from: recurrence)

    #expect(rule.frequency == .daily)
    #expect(rule.interval == 2)
    #expect(rule.recurrenceEnd?.occurrenceCount == 5)

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }

  @Test("Weekly recurrence maps end date")
  func weeklyEndDate() {
    let date = Date(timeIntervalSince1970: 1_700_000_000)
    let recurrence = ReminderRecurrence(frequency: .weekly, interval: 1, end: .until(date))
    let rule = RecurrenceAdapter.rule(from: recurrence)

    #expect(rule.frequency == .weekly)
    #expect(rule.recurrenceEnd?.endDate == date)

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }

  @Test("Weekly recurrence maps days of week")
  func weeklyDays() {
    let recurrence = ReminderRecurrence(
      frequency: .weekly,
      interval: 1,
      daysOfWeek: [.monday, .wednesday, .friday]
    )
    let rule = RecurrenceAdapter.rule(from: recurrence)
    let days = rule.daysOfTheWeek?.map(\.dayOfTheWeek)

    #expect(days == [.monday, .wednesday, .friday])

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }

  @Test("Monthly recurrence maps days of month")
  func monthlyDays() {
    let recurrence = ReminderRecurrence(
      frequency: .monthly,
      interval: 1,
      daysOfMonth: [1, 15, 31]
    )
    let rule = RecurrenceAdapter.rule(from: recurrence)
    let days = rule.daysOfTheMonth?.map { $0.intValue }

    #expect(days == [1, 15, 31])

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }

  @Test("Monthly recurrence maps set positions with weekdays")
  func monthlySetPositions() {
    let recurrence = ReminderRecurrence(
      frequency: .monthly,
      interval: 1,
      daysOfWeek: [.monday],
      setPositions: [2]
    )
    let rule = RecurrenceAdapter.rule(from: recurrence)
    let positions = rule.setPositions?.map { $0.intValue }
    let days = rule.daysOfTheWeek?.map(\.dayOfTheWeek)

    #expect(positions == [2])
    #expect(days == [.monday])

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }

  @Test("Yearly recurrence maps months and weeks")
  func yearlyMonthsWeeks() {
    let recurrence = ReminderRecurrence(
      frequency: .yearly,
      interval: 1,
      monthsOfYear: [1, 12],
      weeksOfYear: [1, 52]
    )
    let rule = RecurrenceAdapter.rule(from: recurrence)
    let months = rule.monthsOfTheYear?.map { $0.intValue }
    let weeks = rule.weeksOfTheYear?.map { $0.intValue }

    #expect(months == [1, 12])
    #expect(weeks == [1, 52])

    let roundTrip = RecurrenceAdapter.recurrence(from: rule)
    #expect(roundTrip == recurrence)
  }
}
