import Foundation
import Testing

@testable import RemindCore
@testable import remindctl

@MainActor
struct RecurrenceFormattingTests {
  @Test("Formats simple daily recurrence")
  func dailySummary() {
    let recurrence = ReminderRecurrence(frequency: .daily)
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: false)
    #expect(summary == "repeat=daily")
  }

  @Test("Formats weekly recurrence with interval and count")
  func weeklySummary() {
    let recurrence = ReminderRecurrence(frequency: .weekly, interval: 2, end: .count(4))
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: false)
    #expect(summary == "repeat=weekly interval=2 count=4")
  }

  @Test("Formats weekly recurrence with days")
  func weeklyDaysSummary() {
    let recurrence = ReminderRecurrence(
      frequency: .weekly,
      interval: 1,
      daysOfWeek: [.monday, .wednesday, .friday]
    )
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: false)
    #expect(summary == "repeat=weekly on=mon,wed,fri")
  }

  @Test("Formats monthly recurrence with month days")
  func monthlyDaysSummary() {
    let recurrence = ReminderRecurrence(
      frequency: .monthly,
      interval: 1,
      daysOfMonth: [1, 15, 31]
    )
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: false)
    #expect(summary == "repeat=monthly month-day=1,15,31")
  }

  @Test("Formats monthly recurrence with set positions")
  func monthlySetposSummary() {
    let recurrence = ReminderRecurrence(
      frequency: .monthly,
      interval: 1,
      daysOfWeek: [.monday],
      setPositions: [2]
    )
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: false)
    #expect(summary == "repeat=monthly on=mon setpos=2")
  }

  @Test("Formats ISO until date for plain output")
  func untilSummaryISO() {
    let date = Date(timeIntervalSince1970: 0)
    let recurrence = ReminderRecurrence(frequency: .daily, end: .until(date))
    let summary = RecurrenceFormatting.summary(for: recurrence, useISO: true)
    #expect(summary.contains("repeat=daily"))
    #expect(summary.contains("until=1970-01-01T00:00:00.000Z"))
  }
}
