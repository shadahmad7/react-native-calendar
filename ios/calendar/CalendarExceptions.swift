// calendar/CalendarExceptions.swift

import Foundation

// MARK: - Base Exception Types

class Exception: Error {
    var reason: String { "An unknown error occurred" }
}

class GenericException<Param>: Exception {
    let param: Param
    init(_ param: Param) { self.param = param }
}

// MARK: - Calendar & Reminder Exceptions

final class MissionPermissionsException: GenericException<String> {
    override var reason: String { "\(param) permission is required to do this operation" }
}

final class DefaultCalendarNotFoundException: Exception {
    override var reason: String { "Could not find the default calendar" }
}

final class CalendarNotSavedException: GenericException<String> {
    override var reason: String { "Calendar \(param) is immutable and cannot be modified" }
}

final class EntityNotSupportedException: GenericException<String?> {
    override var reason: String { "Calendar entityType \(String(describing: param)) is not supported" }
}

final class CalendarIdNotFoundException: GenericException<String> {
    override var reason: String { "Calendar with id \(param) could not be found" }
}

final class EventNotFoundException: GenericException<String> {
    override var reason: String { "Event with id \(param) could not be found" }
}

final class InvalidCalendarTypeException: GenericException<(String, String)> {
    override var reason: String { "Calendar with id \(param.0) is not of type `\(param.1)`" }
}

final class MissingParameterException: Exception {
    override var reason: String { "`Calendar.getRemindersAsync` needs at least one calendar ID" }
}

final class ReminderNotFoundException: GenericException<String> {
    override var reason: String { "Reminder with id \(param) could not be found" }
}

final class InvalidCalendarEntityException: GenericException<String?> {
    override var reason: String { "Calendar entityType \(String(describing: param)) is not supported" }
}

final class InvalidTimeZoneException: GenericException<String> {
    override var reason: String { "Invalid time zone: \(param)" }
}

final class SourceNotFoundException: GenericException<String> {
    override var reason: String { "Source with id \(param) was not found" }
}

final class PermissionsManagerNotFoundException: Exception {
    override var reason: String { "Permissions module not found. Are you sure that modules are properly linked?" }
}

final class InvalidDateFormatException: Exception {
    override var reason: String { "JSON String could not be interpreted as a date. Expected format: YYYY-MM-DD'T'HH:mm:ss.sssZ" }
}

final class CalendarIdRequiredException: Exception {
    override var reason: String { "CalendarId is required" }
}

final class EventIdRequiredException: Exception {
    override var reason: String { "Event Id is required" }
}

final class InvalidStatusExceptions: GenericException<String> {
    override var reason: String { "`\(param)` is not a valid reminder status" }
}

final class MissingCalendarPListValueException: GenericException<String> {
    override var reason: String { "This app is missing \(param), so calendar methods will fail. Add this key to your bundle's Info.plist" }
}

final class MissingRemindersPListValueException: GenericException<String> {
    override var reason: String { "This app is missing \(param), so reminders methods will fail. Add this key to your bundle's Info.plist" }
}

final class EventDialogInProgressException: Exception {
    override var reason: String { "Different calendar dialog is already being presented. Await its result before presenting another." }
}
