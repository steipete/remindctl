import Foundation

public enum DateParsing {
  public static func parseUserDate(
    _ input: String,
    now: Date = Date(),
    calendar: Calendar = .current
  ) -> Date? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let lower = trimmed.lowercased()

    if let relative = parseRelativeDate(lower, now: now, calendar: calendar) {
      return relative
    }

    let iso =
      isoFormatter(withFraction: true).date(from: trimmed)
      ?? isoFormatter(withFraction: false).date(from: trimmed)
    if let iso {
      return iso
    }

    for formatter in dateFormatters() {
      if let date = formatter.date(from: trimmed) {
        return date
      }
    }

    return nil
  }

  public static func formatDisplay(_ date: Date, calendar: Calendar = .current) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.timeZone = calendar.timeZone
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }

  public static func formatDisplayAllDay(_ date: Date, calendar: Calendar = .current) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.timeZone = calendar.timeZone
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }

  private static func parseRelativeDate(_ input: String, now: Date, calendar: Calendar) -> Date? {
    switch input {
    case "today":
      return calendar.startOfDay(for: now)
    case "tomorrow":
      return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
    case "yesterday":
      return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
    case "now":
      return now
    default:
      return nil
    }
  }

  private static func isoFormatter(withFraction: Bool) -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions =
      withFraction
      ? [.withInternetDateTime, .withFractionalSeconds]
      : [.withInternetDateTime]
    return formatter
  }

  private static func dateFormatters() -> [DateFormatter] {
    let formats = [
      "yyyy-MM-dd",
      "yyyy-MM-dd HH:mm",
      "yyyy-MM-dd HH:mm:ss",
      "MM/dd/yyyy",
      "MM/dd/yyyy HH:mm",
      "dd-MM-yy",
      "dd-MM-yyyy",
    ]
    return formats.map { format in
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone.current
      formatter.dateFormat = format
      return formatter
    }
  }
}
