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

        let formatter = ISO8601DateFormatter()

        if let startStr = details["startDate"] as? String,
           let startDate = formatter.date(from: startStr) {
            event.startDate = startDate
        }

        if let endStr = details["endDate"] as? String,
           let endDate = formatter.date(from: endStr) {
            event.endDate = endDate
        }

        if let allDay = details["allDay"] as? Bool {
            event.isAllDay = allDay
        }

        event.calendar = eventStoreInstance.defaultCalendarForNewEvents
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
