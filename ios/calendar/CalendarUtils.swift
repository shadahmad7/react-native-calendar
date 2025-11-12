// calendar/CalendarUtils.swift

import EventKit
import CoreLocation

// MARK: - Utilities Namespace

struct CalendarUtils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

// MARK: - Date Parsing

func parse(date: Any?) -> Date? {
    guard let date = date else { return nil }

    if let timestamp = date as? Double {
        return Date(timeIntervalSince1970: timestamp / 1000.0)
    }

    if let dateString = date as? String {
        return CalendarUtils.dateFormatter.date(from: dateString)
    }

    return nil
}

func parse(date: String?) -> Date? {
    guard let date = date, !date.isEmpty else { return nil }

    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let parsed = isoFormatter.date(from: date) {
        return parsed
    }

    // fallback without fractional seconds
    let fallbackFormatter = ISO8601DateFormatter()
    fallbackFormatter.formatOptions = [.withInternetDateTime]
    return fallbackFormatter.date(from: date)
}

// MARK: - Recurrence Rule

func createRecurrenceRule(rule: RecurrenceRule) -> EKRecurrenceRule? {
    guard ["daily", "weekly", "monthly", "yearly"].contains(rule.frequency) else { return nil }
    let endDate = parse(date: rule.endDate)

    let daysOfTheWeek = rule.daysOfTheWeek?.map { day in
        EKRecurrenceDayOfWeek(day.dayOfTheWeek.toEKType(), weekNumber: day.weekNumber)
    }

    let daysOfTheMonth = rule.daysOfTheMonth?.map { NSNumber(value: $0) }
    let monthsOfTheYear = rule.monthsOfTheYear?.map { NSNumber(value: $0.rawValue) }
    let weeksOfTheYear = rule.weeksOfTheYear?.map { NSNumber(value: $0) }
    let daysOfTheYear = rule.daysOfTheYear?.map { NSNumber(value: $0) }
    let setPositions = rule.setPositions?.map { NSNumber(value: $0) }

    var recurrenceEnd: EKRecurrenceEnd?
    if let endDate {
        recurrenceEnd = EKRecurrenceEnd(end: endDate)
    } else if let occurrence = rule.occurrence, occurrence > 0 {
        recurrenceEnd = EKRecurrenceEnd(occurrenceCount: occurrence)
    }

    let recurrenceInterval = (rule.interval ?? 1) > 0 ? rule.interval! : 1

    return EKRecurrenceRule(
        recurrenceWith: recurrenceFrequencyToString(name: rule.frequency),
        interval: recurrenceInterval,
        daysOfTheWeek: daysOfTheWeek,
        daysOfTheMonth: daysOfTheMonth,
        monthsOfTheYear: monthsOfTheYear,
        weeksOfTheYear: weeksOfTheYear,
        daysOfTheYear: daysOfTheYear,
        setPositions: setPositions,
        end: recurrenceEnd
    )
}

// MARK: - Alarms

func createCalendarEventAlarms(alarms: [Alarm]) -> [EKAlarm] {
    alarms.compactMap { alarm in
        guard alarm.absoluteDate != nil || alarm.relativeOffset != nil || alarm.structuredLocation != nil else { return nil }
        return createCalendarEventAlarm(alarm: alarm)
    }
}

func createCalendarEventAlarm(alarm: Alarm) -> EKAlarm? {
    let date = parse(date: alarm.absoluteDate)
    let relativeOffset = alarm.relativeOffset

    let calendarEventAlarm: EKAlarm
    if let date {
        calendarEventAlarm = EKAlarm(absoluteDate: date)
    } else if let relativeOffset {
        calendarEventAlarm = EKAlarm(relativeOffset: TimeInterval(60 * relativeOffset))
    } else {
        calendarEventAlarm = EKAlarm()
    }

    // Location-based alarm
    if let locationOptions = alarm.structuredLocation, let geo = locationOptions.coords {
        let geoLocation = CLLocation(latitude: geo.latitude, longitude: geo.longitude)
        let structuredLocation = EKStructuredLocation(title: locationOptions.title)
        structuredLocation.geoLocation = geoLocation
        structuredLocation.radius = locationOptions.radius ?? 0.0

        calendarEventAlarm.structuredLocation = structuredLocation

        if let proximity = locationOptions.proximity {
            switch proximity {
            case "enter": calendarEventAlarm.proximity = .enter
            case "leave": calendarEventAlarm.proximity = .leave
            default: calendarEventAlarm.proximity = .none
            }
        } else {
            calendarEventAlarm.proximity = .none
        }
    }

    return calendarEventAlarm
}

// MARK: - Date Components

func createDateComponents(for date: Date, allDay: Bool = false) -> DateComponents {
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = allDay
        ? [.year, .month, .day]
        : [.year, .month, .day, .hour, .minute, .second]

    return calendar.dateComponents(components, from: date)
}

// MARK: - Availability

func getAvailability(availability: String) -> EKEventAvailability {
    switch availability {
    case "busy": return .busy
    case "free": return .free
    case "tentative": return .tentative
    case "unavailable": return .unavailable
    default: return .notSupported
    }
}
