// calendar/Requesters/CalendarPermissionsRequester.swift

import EventKit
import Foundation

public class CalendarPermissionsRequester: NSObject {
    private let eventStore: EKEventStore

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    // Check current calendar permission status
    public func getPermissions() -> String {
        let descriptionKey: String
        if #available(iOS 17.0, *) {
            descriptionKey = "NSCalendarsFullAccessUsageDescription"
        } else {
            descriptionKey = "NSCalendarsUsageDescription"
        }

        guard Bundle.main.object(forInfoDictionaryKey: descriptionKey) != nil else {
            fatalError("Missing \(descriptionKey) in Info.plist")
        }

        if #available(iOS 17.0, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined: return "undetermined"
            case .restricted, .denied, .writeOnly: return "denied"
            case .fullAccess: return "granted"
            @unknown default: return "undetermined"
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined: return "undetermined"
            case .restricted, .denied: return "denied"
            case .authorized: return "granted"
            @unknown default: return "undetermined"
            }
        }
    }

    // Request calendar permissions
    public func requestPermissions(completion: @escaping (String) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { _, error in
                if let error = error {
                    print("Calendar permission error: \(error.localizedDescription)")
                    completion("denied")
                } else {
                    completion(self.getPermissions())
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { _, error in
                if let error = error {
                    print("Calendar permission error: \(error.localizedDescription)")
                    completion("denied")
                } else {
                    completion(self.getPermissions())
                }
            }
        }
    }
}
