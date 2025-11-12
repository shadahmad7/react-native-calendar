// calendar/Records/CalendarRecords.swift

import Foundation

enum CalendarEntity: String {
    case event
    case reminder
}

struct CalendarRecord {
    var id: String?
    var title: String
    var sourceId: String?
    var source: Source
    var type: String?
    var color: Int
    var entityType: CalendarEntity?
    var allowsModifications: Bool
    var allowedAvailabilities: [String]
}

struct Source {
    var id: String?
    var type: String
    var name: String
    var isLocalAccount: Bool?
}

struct Event {
    var id: String?
    var calendarId: String?
    var title: String
    var location: String?
    var creationDate: String? // Or use Double? if needed
    var lastModifiedDate: String?
    var timeZone: String?
    var url: String?
    var notes: String
    var alarms: [Alarm]
    var recurrenceRule: RecurrenceRule?
    var startDate: String?
    var endDate: String?
    var originalStartDate: String?
    var isDetached: Bool?
    var instanceStartDate: String?
    var allDay: Bool
    var availability: String
    var status: String
}

struct RecurringEventOptions {
    var futureEvents: Bool?
    var instanceStartDate: String?
}

struct Reminder {
    var id: String?
    var calendarId: String?
    var title: String?
    var location: String?
    var creationDate: String?
    var lastModifiedDate: String?
    var timeZone: String?
    var url: String?
    var notes: String?
    var alarms: [Alarm]?
    var recurrenceRule: RecurrenceRule?
    var allDay: Bool?
    var startDate: String?
    var dueDate: String?
    var completed: Bool?
    var completionDate: String?
}

struct OpenInCalendarOptions {
    var id: String
    var instanceStartDate: String?
    var allowsEditing: Bool = false
    var allowsCalendarPreview: Bool = false
}

enum ResponseAction: String {
    case done
    case canceled
    case deleted
    case responded
    case saved
}

struct DialogViewResponse {
    var action: ResponseAction = .done
}

struct DialogEditResponse {
    var action: ResponseAction = .canceled
    var id: String? = nil
}
