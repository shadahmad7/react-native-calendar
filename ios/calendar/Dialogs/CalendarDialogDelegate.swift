// calendar/Dialogs/CalendarDialogDelegate.swift

import EventKitUI

class CalendarDialogDelegate: NSObject, EKEventEditViewDelegate, EKEventViewDelegate {

    private let resolve: RCTPromiseResolveBlock
    private let reject: RCTPromiseRejectBlock
    private let onComplete: () -> Void

    init(resolve: @escaping RCTPromiseResolveBlock,
         reject: @escaping RCTPromiseRejectBlock,
         onComplete: @escaping () -> Void) {
        self.resolve = resolve
        self.reject = reject
        self.onComplete = onComplete
    }

    // MARK: - EKEventEditViewDelegate
    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {
        guard let event = controller.event else {
            resolve(["action": ResponseAction.canceled.rawValue])
            controller.dismiss(animated: true, completion: onComplete)
            return
        }

        let response: [String: Any]
        switch action {
        case .canceled:
            response = ["action": ResponseAction.canceled.rawValue]

        case .deleted:
            response = ["action": ResponseAction.deleted.rawValue]

        case .saved:
            response = [
                "action": ResponseAction.saved.rawValue,
                "id": event.calendarItemIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": event.startDate?.description ?? "",
                "endDate": event.endDate?.description ?? "",
                "status": eventStatusToString(event.status),
                "availability": eventAvailabilityToString(event.availability)
            ]

        @unknown default:
            response = ["action": "unknown"]
        }

        resolve(response)
        controller.dismiss(animated: true, completion: onComplete)
    }

    // MARK: - EKEventViewDelegate
    func eventViewController(_ controller: EKEventViewController,
                             didCompleteWith action: EKEventViewAction) {

        let response: [String: Any]

        switch action {
        case .responded:
            response = ["action": ResponseAction.responded.rawValue]
        case .deleted:
            response = ["action": ResponseAction.deleted.rawValue]
        case .done:
            fallthrough
        @unknown default:
            response = ["action": ResponseAction.done.rawValue]
        }

        resolve(response)
        controller.dismiss(animated: true, completion: onComplete)
    }
}
