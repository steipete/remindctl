import Foundation
import Testing

@testable import RemindCore

@MainActor
struct ReminderItemCodingTests {
  @Test("JSON includes EventKit metadata")
  func jsonIncludesEventKitMetadata() throws {
    let item = ReminderItem(
      id: "abc",
      title: "Created",
      notes: nil,
      url: URL(string: "https://example.com"),
      isCompleted: false,
      completionDate: nil,
      creationDate: Date(timeIntervalSince1970: 1_700_000_000),
      lastModifiedDate: Date(timeIntervalSince1970: 1_700_000_100),
      priority: .none,
      dueDate: nil,
      alarmDate: Date(timeIntervalSince1970: 1_700_000_300),
      recurrenceRule: RecurrenceRule(frequency: .weekly, interval: 2),
      locationTrigger: LocationTrigger(
        address: "1 Apple Park Way",
        latitude: 37.3349,
        longitude: -122.0090,
        radius: 100,
        proximity: .arriving
      ),
      listID: "list",
      listName: "Inbox"
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(item)
    let json = try #require(String(data: data, encoding: .utf8))
    #expect(json.contains(#""creationDate""#))
    #expect(json.contains(#""lastModifiedDate""#))
    #expect(json.contains(#""url":"https:\/\/example.com""#))
    #expect(json.contains(#""alarmDate""#))
    #expect(json.contains(#""recurrenceRule""#))
    #expect(json.contains(#""locationTrigger""#))
  }
}
