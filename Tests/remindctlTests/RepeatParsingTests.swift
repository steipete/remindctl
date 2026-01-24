import Testing
@testable import RemindCore
@testable import remindctl

@MainActor
struct RepeatParsingTests {
  @Test("Parses daily recurrence with defaults")
  func dailyDefaults() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "daily",
        interval: nil,
        count: nil,
        until: nil,
        on: nil,
        monthDay: nil,
        setpos: nil
      )
    )
    #expect(recurrence.frequency == .daily)
    #expect(recurrence.interval == 1)
    #expect(recurrence.end == nil)
  }

  @Test("Parses weekly recurrence with interval and count")
  func weeklyCount() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "weekly",
        interval: "2",
        count: "5",
        until: nil,
        on: nil,
        monthDay: nil,
        setpos: nil
      )
    )
    #expect(recurrence.frequency == .weekly)
    #expect(recurrence.interval == 2)
    #expect(recurrence.end == .count(5))
  }

  @Test("Parses recurrence with until date")
  func untilDate() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "daily",
        interval: nil,
        count: nil,
        until: "2026-01-03T12:34:56Z",
        on: nil,
        monthDay: nil,
        setpos: nil
      )
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
        .init(
          frequency: "yearly",
          interval: nil,
          count: nil,
          until: nil,
          on: nil,
          monthDay: nil,
          setpos: nil
        )
      )
    }
  }

  @Test("Rejects count with until")
  func countAndUntil() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "daily",
          interval: nil,
          count: "2",
          until: "tomorrow",
          on: nil,
          monthDay: nil,
          setpos: nil
        )
      )
    }
  }

  @Test("Parses weekly days")
  func weeklyDays() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "weekly",
        interval: nil,
        count: nil,
        until: nil,
        on: "mon,wed,fri",
        monthDay: nil,
        setpos: nil
      )
    )
    #expect(recurrence.daysOfWeek == [.monday, .wednesday, .friday])
  }

  @Test("Rejects --on for non-weekly")
  func onNonWeekly() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "daily",
          interval: nil,
          count: nil,
          until: nil,
          on: "mon",
          monthDay: nil,
          setpos: nil
        )
      )
    }
  }

  @Test("Rejects monthly --on without --setpos")
  func monthlyOnWithoutSetpos() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "monthly",
          interval: nil,
          count: nil,
          until: nil,
          on: "mon",
          monthDay: nil,
          setpos: nil
        )
      )
    }
  }

  @Test("Parses monthly month days")
  func monthlyDays() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "monthly",
        interval: nil,
        count: nil,
        until: nil,
        on: nil,
        monthDay: "1,15,31",
        setpos: nil
      )
    )
    #expect(recurrence.daysOfMonth == [1, 15, 31])
  }

  @Test("Rejects --month-day for non-monthly")
  func monthDayNonMonthly() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "weekly",
          interval: nil,
          count: nil,
          until: nil,
          on: nil,
          monthDay: "1",
          setpos: nil
        )
      )
    }
  }

  @Test("Parses set positions for monthly weekday rules")
  func setPositionsMonthly() throws {
    let recurrence = try RepeatParsing.parseRecurrence(
      .init(
        frequency: "monthly",
        interval: nil,
        count: nil,
        until: nil,
        on: "mon",
        monthDay: nil,
        setpos: "2"
      )
    )
    #expect(recurrence.setPositions == [2])
  }

  @Test("Rejects --setpos without --on")
  func setposRequiresOn() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "monthly",
          interval: nil,
          count: nil,
          until: nil,
          on: nil,
          monthDay: nil,
          setpos: "2"
        )
      )
    }
  }

  @Test("Rejects --setpos for non-monthly")
  func setposNonMonthly() {
    #expect(throws: RemindCoreError.self) {
      _ = try RepeatParsing.parseRecurrence(
        .init(
          frequency: "weekly",
          interval: nil,
          count: nil,
          until: nil,
          on: "mon",
          monthDay: nil,
          setpos: "2"
        )
      )
    }
  }
}
