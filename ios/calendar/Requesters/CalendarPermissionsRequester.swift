// calendar/Requesters/CalendarPermissionsRequester.swift

import EventKit
import Foundation

public class CalendarPermissionsRequester: NSObject {
    private let eventStore: EKEventStore

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    // MARK: - Get Current Permission Status
    public func getPermissions() -> String {
        // Correct Info.plist Keys for each OS version
        let descriptionKey: String = {
            if #available(iOS 17.0, *) {
                return "NSCalendarsFullAccessUsageDescription"
            } else {
                return "NSCalendarsUsageDescription"
            }
        }()

        // DO NOT crash the app — return denied if missing
        if Bundle.main.object(forInfoDictionaryKey: descriptionKey) == nil {
            print("⚠️ Missing \(descriptionKey) in Info.plist")
            return "denied"
        }

        // Determine the status properly
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            switch status {
            case .notDetermined:
                return "undetermined"
            case .restricted, .denied, .writeOnly:
                return "denied"
            case .fullAccess:
                return "granted"
            @unknown default:
                return "undetermined"
            }
        } else {
            switch status {
            case .notDetermined:
                return "undetermined"
            case .restricted, .denied:
                return "denied"
            case .authorized:
                return "granted"
            @unknown default:
                return "undetermined"
            }
        }
    }

    // MARK: - Request Permissions
    public func requestPermissions(completion: @escaping (String) -> Void) {

        // If already determined, return immediately
        let currentStatus = getPermissions()
        if currentStatus != "undetermined" {
            completion(currentStatus)
            return
        }

        // iOS 17+ uses requestFullAccessToEvents
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    print("Calendar permission error: \(error.localizedDescription)")
                    completion("denied")
                    return
                }

                completion(granted ? "granted" : "denied")
            }

        // < iOS 17 uses requestAccess(to:)
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                if let error = error {
                    print("Calendar permission error: \(error.localizedDescription)")
                    completion("denied")
                    return
                }

                completion(granted ? "granted" : "denied")
            }
        }
    }
}
