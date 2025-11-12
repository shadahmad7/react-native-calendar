// calendar/Conversions/Conversions.swift

import EventKit
import UIKit

let dateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.timeZone = TimeZone(identifier: "UTC")
  df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
  df.locale = Locale(identifier: "en_US_POSIX")
  return df
}()

func entity(type: EKEntityMask) -> String? {
  let allowsEvents = type.contains(.event)
  let allowsReminders = type.contains(.reminder)

  if allowsEvents && allowsReminders { return "both" }
  if allowsReminders { return "reminder" }
  if allowsEvents { return "event" }
  return nil
}

func calendarSupportedAvailabilities(fromMask types: EKCalendarEventAvailabilityMask) -> [String] {
  var availabilitiesStrings = [String]()
  if types.contains(.busy) { availabilitiesStrings.append("busy") }
  if types.contains(.free) { availabilitiesStrings.append("free") }
  if types.contains(.tentative) { availabilitiesStrings.append("tentative") }
  if types.contains(.unavailable) { availabilitiesStrings.append("unavailable") }
  return availabilitiesStrings
}

func serialize(ekSource: EKSource) -> [String: Any?] {
  [
    "id": ekSource.sourceIdentifier,
    "type": sourceToString(type: ekSource.sourceType),
    "name": ekSource.title
  ]
}

func serializeCalendars(calendars: [EKCalendar]) -> [[String: Any?]] {
  calendars.map { serializeCalendar(calendar: $0) }
}

func serializeCalendar(calendar: EKCalendar) -> [String: Any?] {
  [
    "id": calendar.calendarIdentifier,
    "title": calendar.title,
    "source": serialize(ekSource: calendar.source),
    "entityType": entity(type: calendar.allowedEntityTypes),
    "color": calendar.cgColor != nil ? hexString(from: calendar.cgColor!) : nil,
    "type": calendarTypeToString(type: calendar.type, source: calendar.source.sourceType),
    "allowsModifications": calendar.allowsContentModifications,
    "allowedAvailabilities": calendarSupportedAvailabilities(fromMask: calendar.supportedEventAvailabilities)
  ]
}

func hexString(from cgColor: CGColor) -> String {
  guard let components = cgColor.components else { return "#000000" }
  let r = Int((components[0] * 255.0).rounded())
  let g = Int((components[1] * 255.0).rounded())
  let b = Int((components[2] * 255.0).rounded())
  return String(format: "#%02X%02X%02X", r, g, b)
}

func serializeCalendar(events: [EKEvent]) -> [[String: Any?]] {
  events.map { serializeCalendar(event: $0) }
}

func serializeCalendar(event: EKEvent) -> [String: Any?] {
  var serializedCalendarEvent = serializeCalendar(item: event, with: dateFormatter)

  if let startDate = event.startDate {
    serializedCalendarEvent["startDate"] = dateFormatter.string(from: startDate)
  }
  if let endDate = event.endDate {
    serializedCalendarEvent["endDate"] = dateFormatter.string(from: endDate)
  }
  if let occurrenceDate = event.occurrenceDate {
    serializedCalendarEvent["originalStartDate"] = dateFormatter.string(from: occurrenceDate)
  }

  serializedCalendarEvent["isDetached"] = event.isDetached
  serializedCalendarEvent["allDay"] = event.isAllDay
  serializedCalendarEvent["availability"] = eventAvailabilityToString(event.availability)
  serializedCalendarEvent["status"] = eventStatusToString(event.status)
  if let organizer = event.organizer {
    serializedCalendarEvent["organizer"] = serialize(attendee: organizer)
  }
  return serializedCalendarEvent
}

func serializeCalendar(item: EKCalendarItem, with formatter: DateFormatter) -> [String: Any?] {
  var serializedItem = [String: Any?]()

  serializedItem["id"] = item.calendarItemIdentifier
  serializedItem["calendarId"] = item.calendar.calendarIdentifier
  serializedItem["title"] = item.title
  serializedItem["location"] = item.location
  if let creationDate = item.creationDate {
    serializedItem["creationDate"] = formatter.string(from: creationDate)
  }
  if let lastModifiedDate = item.lastModifiedDate {
    serializedItem["lastModifiedDate"] = formatter.string(from: lastModifiedDate)
  }
  serializedItem["timeZone"] = item.timeZone?.localizedName(for: .shortStandard, locale: .current)
  serializedItem["url"] = item.url?.absoluteString.removingPercentEncoding
  serializedItem["notes"] = item.notes
  if let alarms = item.alarms {
    serializedItem["alarms"] = serialize(alarms: alarms, with: formatter)
  }

  if let rule = item.recurrenceRules?.first {
    var recurrenceRule: [String: Any?] = ["frequency": recurrenceToString(frequency: rule.frequency)]
    recurrenceRule["interval"] = rule.interval
    if let endDate = rule.recurrenceEnd?.endDate {
      recurrenceRule["endDate"] = formatter.string(from: endDate)
    }
    recurrenceRule["occurrence"] = rule.recurrenceEnd?.occurrenceCount

    if let daysOfTheWeek = rule.daysOfTheWeek {
      recurrenceRule["daysOfTheWeek"] = daysOfTheWeek.map { ["dayOfTheWeek": $0.dayOfTheWeek.rawValue, "weekNumber": $0.weekNumber] }
    }
    recurrenceRule["daysOfTheMonth"] = rule.daysOfTheMonth
    recurrenceRule["daysOfTheYear"] = rule.daysOfTheYear
    recurrenceRule["monthsOfTheYear"] = rule.monthsOfTheYear
    recurrenceRule["setPositions"] = rule.setPositions
    serializedItem["recurrenceRule"] = recurrenceRule
  }

  return serializedItem
}

func serialize(reminders: [EKReminder]) -> [[String: Any?]] {
  reminders.map { serialize($0) }
}

func serialize(_ reminder: EKReminder) -> [String: Any?] {
  let currentCalendar = Calendar.current
  var serializedReminder = serializeCalendar(item: reminder, with: dateFormatter)

  if let startDateComponents = reminder.startDateComponents, let startDate = currentCalendar.date(from: startDateComponents) {
    serializedReminder["startDate"] = dateFormatter.string(from: startDate)
  }
  if let dueDateComponents = reminder.dueDateComponents, let dueDate = currentCalendar.date(from: dueDateComponents) {
    serializedReminder["dueDate"] = dateFormatter.string(from: dueDate)
  }

  serializedReminder["completed"] = reminder.isCompleted
  if let completionDate = reminder.completionDate {
    serializedReminder["completionDate"] = dateFormatter.string(from: completionDate)
  }

  return serializedReminder
}

func serialize(attendees: [EKParticipant]) -> [[String: Any?]] {
  attendees.map { serialize(attendee: $0) }
}

func serialize(attendee: EKParticipant) -> [String: Any?] {
  [
    "isCurrentUser": attendee.isCurrentUser,
    "name": attendee.name,
    "role": participantToString(role: attendee.participantRole),
    "status": participantStatusToString(status: attendee.participantStatus),
    "type": participantTypeToString(type: attendee.participantType),
    "url": attendee.url.absoluteString.removingPercentEncoding
  ]
}

func serialize(alarms: [EKAlarm], with formatter: DateFormatter) -> [[String: Any?]] {
  alarms.map { alarm in
    var serializedAlarm = [String: Any?]()
    if let absoluteDate = alarm.absoluteDate {
      serializedAlarm["absoluteDate"] = formatter.string(from: absoluteDate)
    }
    serializedAlarm["relativeOffset"] = alarm.relativeOffset / 60.0

    if let structuredLocation = alarm.structuredLocation {
      var proximity: String?
      switch alarm.proximity {
      case .enter: proximity = "enter"
      case .leave: proximity = "leave"
      default: proximity = "None"
      }
      serializedAlarm["structuredLocation"] = [
        "title": structuredLocation.title,
        "proximity": proximity,
        "radius": structuredLocation.radius,
        "coord": [
          "latitude": structuredLocation.geoLocation?.coordinate.latitude,
          "longitude": structuredLocation.geoLocation?.coordinate.longitude
        ]
      ]
    }

    return serializedAlarm
  }
}
