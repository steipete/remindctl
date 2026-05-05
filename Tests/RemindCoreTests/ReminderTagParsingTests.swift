import Testing

@testable import RemindCore

@MainActor
struct ReminderTagParsingTests {
  @Test("Trailing hashtags are exposed as tags")
  func trailingHashtagsAreTags() {
    let reminder = ReminderItem(
      id: "abc",
      title: "Buy milk #shopping #urgent",
      notes: nil,
      isCompleted: false,
      completionDate: nil,
      priority: .none,
      dueDate: nil,
      listID: "list",
      listName: "Inbox"
    )

    #expect(reminder.titleWithoutTags == "Buy milk")
    #expect(reminder.tags == ["shopping", "urgent"])
  }

  @Test("Only trailing hashtags are parsed as tags")
  func onlyTrailingHashtagsAreTags() {
    let reminder = ReminderItem(
      id: "abc",
      title: "Discuss #hash syntax with team #work",
      notes: nil,
      isCompleted: false,
      completionDate: nil,
      priority: .none,
      dueDate: nil,
      listID: "list",
      listName: "Inbox"
    )

    #expect(reminder.titleWithoutTags == "Discuss #hash syntax with team")
    #expect(reminder.tags == ["work"])
  }
}
