import Testing
@testable import RemindCore
@testable import remindctl

@MainActor
struct RepeatParsingTests {
  @Test("Parses daily recurrence with defaults")
  func dailyDefaults() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      frequency: "daily",
      interval: nil,
      count: nil,
      until: nil,
      on: nil
    )
    #expect(recurrence.frequency == .daily)
    #expect(recurrence.interval == 1)
    #expect(recurrence.end == nil)
  }

  @Test("Parses weekly recurrence with interval and count")
  func weeklyCount() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      frequency: "weekly",
      interval: "2",
      count: "5",
      until: nil,
      on: nil
    )
    #expect(recurrence.frequency == .weekly)
    #expect(recurrence.interval == 2)
    #expect(recurrence.end == .count(5))
  }

  @Test("Parses recurrence with until date")
  func untilDate() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      frequency: "daily",
      interval: nil,
      count: nil,
      until: "2026-01-03T12:34:56Z",
      on: nil
    )
    guard case .until = recurrence.end else {
      #expect(Bool(false))
      return
    }
  }

  @Test("Rejects invalid frequency")
  func invalidFrequency() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        frequency: "monthly",
        interval: nil,
        count: nil,
        until: nil,
        on: nil
      )
    }
  }

  @Test("Rejects count with until")
  func countAndUntil() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        frequency: "daily",
        interval: nil,
        count: "2",
        until: "tomorrow",
        on: nil
      )
    }
  }

  @Test("Parses weekly days")
  func weeklyDays() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      frequency: "weekly",
      interval: nil,
      count: nil,
      until: nil,
      on: "mon,wed,fri"
    )
    #expect(recurrence.daysOfWeek == [.monday, .wednesday, .friday])
  }

  @Test("Rejects --on for non-weekly")
  func onNonWeekly() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        frequency: "daily",
        interval: nil,
        count: nil,
        until: nil,
        on: "mon"
      )
    }
  }
}
