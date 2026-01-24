import Foundation
import RemindCore

enum RecurrenceFormatting {
  static func summary(for recurrence: ReminderRecurrence, useISO: Bool) -> String {
    var parts: [String] = ["repeat=\(recurrence.frequency.rawValue)"]

    if recurrence.interval != 1 {
      parts.append("interval=\(recurrence.interval)")
    }

    if let daysOfWeek = recurrence.daysOfWeek, !daysOfWeek.isEmpty {
      let days = daysOfWeek.map(\.rawValue).joined(separator: ",")
      parts.append("on=\(days)")
    }

    if let daysOfMonth = recurrence.daysOfMonth, !daysOfMonth.isEmpty {
      let days = daysOfMonth.map(String.init).joined(separator: ",")
      parts.append("month-day=\(days)")
    }

    if let setPositions = recurrence.setPositions, !setPositions.isEmpty {
      let positions = setPositions.map(String.init).joined(separator: ",")
      parts.append("setpos=\(positions)")
    }

    if let end = recurrence.end {
      switch end {
      case .count(let count):
        parts.append("count=\(count)")
      case .until(let date):
        let formatted = useISO ? isoFormatter().string(from: date) : DateParsing.formatDisplay(date)
        parts.append("until=\(formatted)")
      }
    }

    return parts.joined(separator: " ")
  }

  private static func isoFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }
}
