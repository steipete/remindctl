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
}
