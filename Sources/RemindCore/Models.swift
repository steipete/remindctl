import Foundation

public enum ReminderPriority: String, Codable, CaseIterable, Sendable {
  case none
  case low
  case medium
  case high

  public init(eventKitValue: Int) {
    switch eventKitValue {
    case 1...4:
      self = .high
    case 5:
      self = .medium
    case 6...9:
      self = .low
    default:
      self = .none
    }
  }

  public var eventKitValue: Int {
    switch self {
    case .none:
      return 0
    case .high:
      return 1
    case .medium:
      return 5
    case .low:
      return 9
    }
  }
}

public struct ReminderList: Identifiable, Codable, Sendable, Equatable {
  public let id: String
  public let title: String

  public init(id: String, title: String) {
    self.id = id
    self.title = title
  }
}

public struct ReminderItem: Identifiable, Codable, Sendable, Equatable {
  public let id: String
  public let title: String
  public let notes: String?
  public let isCompleted: Bool
  public let completionDate: Date?
  public let priority: ReminderPriority
  public let dueDate: Date?
  public let listID: String
  public let listName: String

  public init(
    id: String,
    title: String,
    notes: String?,
    isCompleted: Bool,
    completionDate: Date?,
    priority: ReminderPriority,
    dueDate: Date?,
    listID: String,
    listName: String
  ) {
    self.id = id
    self.title = title
    self.notes = notes
    self.isCompleted = isCompleted
    self.completionDate = completionDate
    self.priority = priority
    self.dueDate = dueDate
    self.listID = listID
    self.listName = listName
  }

  public var tags: [String] {
    Self.extractTrailingTags(from: title).tags
  }

  public var titleWithoutTags: String {
    Self.extractTrailingTags(from: title).title
  }

  private static let trailingTagPattern = try! NSRegularExpression(
    pattern: "(?:^|\\s)#([A-Za-z0-9][A-Za-z0-9_-]*)$"
  )

  private static func extractTrailingTags(from rawTitle: String) -> (title: String, tags: [String]) {
    var title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    var extracted: [String] = []

    while !title.isEmpty {
      let range = NSRange(title.startIndex..<title.endIndex, in: title)
      guard let match = trailingTagPattern.firstMatch(in: title, options: [], range: range),
        let fullRange = Range(match.range(at: 0), in: title),
        let tagRange = Range(match.range(at: 1), in: title)
      else {
        break
      }

      extracted.append(String(title[tagRange]))
      title.removeSubrange(fullRange)
      title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return (title: title, tags: extracted.reversed())
  }
}

public struct ReminderDraft: Sendable {
  public let title: String
  public let notes: String?
  public let dueDate: Date?
  public let priority: ReminderPriority

  public init(title: String, notes: String?, dueDate: Date?, priority: ReminderPriority) {
    self.title = title
    self.notes = notes
    self.dueDate = dueDate
    self.priority = priority
  }
}

public struct ReminderUpdate: Sendable {
  public let title: String?
  public let notes: String?
  public let dueDate: Date??
  public let priority: ReminderPriority?
  public let listName: String?
  public let isCompleted: Bool?

  public init(
    title: String? = nil,
    notes: String? = nil,
    dueDate: Date?? = nil,
    priority: ReminderPriority? = nil,
    listName: String? = nil,
    isCompleted: Bool? = nil
  ) {
    self.title = title
    self.notes = notes
    self.dueDate = dueDate
    self.priority = priority
    self.listName = listName
    self.isCompleted = isCompleted
  }
}
