import Foundation
import Testing

@testable import remindctl

@MainActor
struct AddCommandParsingTests {
  @Test("Date-only due input defaults to all-day")
  func dateOnlyDueDefaultsToAllDay() throws {
    let parsed = try CommandHelpers.parseAddDueDate("2026-03-06", forceAllDay: false)
    #expect(parsed.isAllDay == true)
  }

  @Test("Date-time due input remains timed")
  func dateTimeDueRemainsTimed() throws {
    let parsed = try CommandHelpers.parseAddDueDate("2026-03-06 15:00", forceAllDay: false)
    #expect(parsed.isAllDay == false)
  }

  @Test("--all-day forces all-day for due input")
  func allDayFlagForcesAllDay() throws {
    let parsed = try CommandHelpers.parseAddDueDate("2026-03-06 15:00", forceAllDay: true)
    #expect(parsed.isAllDay == true)
  }
}
