// calendar/Requesters/RemindersPermissionsRequester.swift

import EventKit
import Foundation

public class RemindersPermissionRequester: NSObject {
    private let eventStore: EKEventStore

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    // Check current reminders permission status
    public func getPermissions() -> String {
        let descriptionKey: String
        if #available(iOS 17.0, *) {
            descriptionKey = "NSRemindersFullAccessUsageDescription"
        } else {
            descriptionKey = "NSRemindersUsageDescription"
        }

        guard Bundle.main.object(forInfoDictionaryKey: descriptionKey) != nil else {
            fatalError("Missing \(descriptionKey) in Info.plist")
        }

        if #available(iOS 17.0, *) {
            let status = EKEventStore.authorizationStatus(for: .reminder)
            switch status {
            case .notDetermined: return "undetermined"
            case .restricted, .denied, .writeOnly: return "denied"
            case .fullAccess: return "granted"
            @unknown default: return "undetermined"
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .reminder)
            switch status {
            case .notDetermined: return "undetermined"
            case .restricted, .denied: return "denied"
            case .authorized: return "granted"
            @unknown default: return "undetermined"
            }
        }
    }

    // Request reminders permissions
    public func requestPermissions(completion: @escaping (String) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { _, error in
                if let error = error {
                    print("Reminders permission error: \(error.localizedDescription)")
                    completion("denied")
                } else {
                    completion(self.getPermissions())
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { _, error in
                if let error = error {
                    print("Reminders permission error: \(error.localizedDescription)")
                    completion("denied")
                } else {
                    completion(self.getPermissions())
                }
            }
        }
    }
}
