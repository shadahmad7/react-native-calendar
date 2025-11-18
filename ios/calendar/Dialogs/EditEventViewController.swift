// calendar/Dialogs/EditEventViewController.swift

import EventKitUI
import React

class EditEventViewController: EKEventEditViewController, EKEventEditViewDelegate {

    private let resolve: RCTPromiseResolveBlock
    private let reject: RCTPromiseRejectBlock
    private let onDismiss: () -> Void

    private let passedEvent: [String: Any]
    private let eventStoreInstance = EKEventStore()

    init(eventDetails: [String: Any],
         resolve: @escaping RCTPromiseResolveBlock,
         reject: @escaping RCTPromiseRejectBlock,
         onDismiss: @escaping () -> Void) {
        self.passedEvent = eventDetails
        self.resolve = resolve
        self.reject = reject
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        self.eventStore = eventStoreInstance
        self.event = makeEvent(from: eventDetails)
        self.editViewDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Create EKEvent from dictionary
    private func makeEvent(from details: [String: Any]) -> EKEvent {
        let event = EKEvent(eventStore: eventStoreInstance)

        event.title = details["title"] as? String
        event.location = details["location"] as? String
        event.notes = details["notes"] as? String

        // Use the same ISO formatter we produced in CalendarManager
        if let startStr = details["startDate"] as? String,
        let startDate = parseISO(startStr) {
            event.startDate = startDate
        } else {
            // If no valid start string, we intentionally leave event.startDate nil.
            // However, because saveEventAsync guarantees startDate and endDate,
            // and we strictly converted to ISO there, this should not happen.
        }

        if let endStr = details["endDate"] as? String,
        let endDate = parseISO(endStr) {
            event.endDate = endDate
        } else {
            // same note as above
        }

        if let allDay = details["allDay"] as? Bool {
            event.isAllDay = allDay
        }

        // safe fallback for calendar — prefer default, otherwise first available
        event.calendar = eventStoreInstance.defaultCalendarForNewEvents
            ?? eventStoreInstance.calendars(for: .event).first

        return event
    }

    // MARK: - Delegate
    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {

        guard let event = controller.event else {
            resolve(["action": ResponseAction.canceled.rawValue])
            controller.dismiss(animated: true, completion: onDismiss)
            return
        }

        let response: [String: Any]

        switch action {
        case .canceled:
            response = ["action": ResponseAction.canceled.rawValue]

        case .saved:
            response = [
                "action": ResponseAction.saved.rawValue,
                "eventId": event.eventIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": event.startDate?.description ?? "",
                "location": event.location ?? "",      
                "url": event.url ?? "",      
                "allDay": event.isAllDay,  
                "endDate": event.endDate?.description ?? "",
                "status": eventStatusToString(event.status),
                "availability": eventAvailabilityToString(event.availability)
            ]

        case .deleted:
            response = ["action": ResponseAction.deleted.rawValue]

        @unknown default:
            response = ["action": "unknown"]
        }

        resolve(response)
        controller.dismiss(animated: true, completion: onDismiss)
    }
}
