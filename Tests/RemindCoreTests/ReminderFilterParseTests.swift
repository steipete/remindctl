import Testing

@testable import RemindCore

@MainActor
struct ReminderFilterParseTests {
  @Test("Parse filter aliases")
  func parseAliases() {
    #expect(ReminderFiltering.parse("t") == .tomorrow)
    #expect(ReminderFiltering.parse("w") == .week)
    #expect(ReminderFiltering.parse("o") == .overdue)
    #expect(ReminderFiltering.parse("u") == .upcoming)
    #expect(ReminderFiltering.parse("open") == .open)
    #expect(ReminderFiltering.parse("done") == .completed)
    #expect(ReminderFiltering.parse("all") == .all)
  }

  @Test("Parse date filter")
  func parseDate() {
    let parsed = ReminderFiltering.parse("2026-01-03")
    #expect(parsed != nil)
  }
}
