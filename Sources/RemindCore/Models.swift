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

public enum ReminderRecurrenceFrequency: String, Codable, CaseIterable, Sendable {
  case daily
  case weekly
  case monthly
}

public enum ReminderWeekday: String, Codable, CaseIterable, Sendable {
  case monday = "mon"
  case tuesday = "tue"
  case wednesday = "wed"
  case thursday = "thu"
  case friday = "fri"
  case saturday = "sat"
  case sunday = "sun"

  public var displayOrder: Int {
    switch self {
    case .monday:
      return 1
    case .tuesday:
      return 2
    case .wednesday:
      return 3
    case .thursday:
      return 4
    case .friday:
      return 5
    case .saturday:
      return 6
    case .sunday:
      return 7
    }
  }
}

public enum ReminderRecurrenceEnd: Codable, Sendable, Equatable {
  case count(Int)
  case until(Date)
}

public struct ReminderRecurrence: Codable, Sendable, Equatable {
  public let frequency: ReminderRecurrenceFrequency
  public let interval: Int
  public let daysOfWeek: [ReminderWeekday]?
  public let daysOfMonth: [Int]?
  public let setPositions: [Int]?
  public let end: ReminderRecurrenceEnd?

  public init(
    frequency: ReminderRecurrenceFrequency,
    interval: Int = 1,
    daysOfWeek: [ReminderWeekday]? = nil,
    daysOfMonth: [Int]? = nil,
    setPositions: [Int]? = nil,
    end: ReminderRecurrenceEnd? = nil
  ) {
    self.frequency = frequency
    self.interval = interval
    self.daysOfWeek = daysOfWeek
    self.daysOfMonth = daysOfMonth
    self.setPositions = setPositions
    self.end = end
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
  public let recurrence: ReminderRecurrence?
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
    recurrence: ReminderRecurrence? = nil,
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
    self.recurrence = recurrence
    self.listID = listID
    self.listName = listName
  }
}

public struct ReminderDraft: Sendable {
  public let title: String
  public let notes: String?
  public let dueDate: Date?
  public let priority: ReminderPriority
  public let recurrence: ReminderRecurrence?

  public init(
    title: String,
    notes: String?,
    dueDate: Date?,
    priority: ReminderPriority,
    recurrence: ReminderRecurrence? = nil
  ) {
    self.title = title
    self.notes = notes
    self.dueDate = dueDate
    self.priority = priority
    self.recurrence = recurrence
  }
}

public struct ReminderUpdate: Sendable {
  public let title: String?
  public let notes: String?
  public let dueDate: Date??
  public let priority: ReminderPriority?
  public let recurrence: ReminderRecurrence??
  public let listName: String?
  public let isCompleted: Bool?

  public init(
    title: String? = nil,
    notes: String? = nil,
    dueDate: Date?? = nil,
    priority: ReminderPriority? = nil,
    recurrence: ReminderRecurrence?? = nil,
    listName: String? = nil,
    isCompleted: Bool? = nil
  ) {
    self.title = title
    self.notes = notes
    self.dueDate = dueDate
    self.priority = priority
    self.recurrence = recurrence
    self.listName = listName
    self.isCompleted = isCompleted
  }
}
