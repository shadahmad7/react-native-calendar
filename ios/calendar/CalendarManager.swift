// calendar/CalendarManager.swift


import Foundation
import EventKit
import EventKitUI
import CoreLocation
import React
import UIKit

@objc(CalendarManager)
public class CalendarManager: NSObject {
  static let shared = CalendarManager()

  private static let sharedEventStore = EKEventStore()
  private var eventStore: EKEventStore { CalendarManager.sharedEventStore }
  private var calendarDialogDelegate: CalendarDialogDelegate?

  // MARK: - React Native Export
  @objc
  public static func requiresMainQueueSetup() -> Bool {
    return false
  }

  @objc
  public func constantsToExport() -> [AnyHashable : Any]! {
    return ["version": "1.0.0"]
  }

  // MARK: - Permissions
  @objc
    func requestCalendarPermissionsAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        let requester = CalendarPermissionsRequester(eventStore: eventStore)
        requester.requestPermissions { status in
            if status == "granted" {
                resolve(["granted": true])
            } else {
                let exception = MissionPermissionsException("Calendar")
                reject("PERMISSION_DENIED", exception.reason, nil)
            }
        }
    }

    @objc
    func requestRemindersPermissionsAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        let requester = RemindersPermissionRequester(eventStore: eventStore)
        requester.requestPermissions { status in
            if status == "granted" {
                resolve(["granted": true])
            } else {
                let exception = MissionPermissionsException("Reminders")
                reject("PERMISSION_DENIED", exception.reason, nil)
            }
        }
    }



  // MARK: - Calendars

  @objc
  func getCalendarsAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
    let eventCalendars = eventStore.calendars(for: .event)
    let reminderCalendars = eventStore.calendars(for: .reminder)
    let allCalendars = eventStore.calendars(for: .event) + eventStore.calendars(for: .reminder)
    let result = serializeCalendars(calendars: allCalendars)
    resolve(result)

  }

  @objc
  func getDefaultCalendarAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                               rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard let calendar = eventStore.defaultCalendarForNewEvents else {
      let exception = DefaultCalendarNotFoundException()
      reject("NO_DEFAULT_CALENDAR", exception.reason, nil)
      return
    } 
    resolve([
      "id": calendar.calendarIdentifier,
      "title": calendar.title,
      "type": calendar.type.rawValue
    ])
  }

  // MARK: - Events

  @objc
  func getEventsAsync(_ startDate: NSString,
                      endDate: NSString,
                      calendarIds: NSArray?,
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {

      // Parse dates using CalendarUtils
      guard let start = parse(date: startDate as String),
            let end = parse(date: endDate as String) else {
          reject("INVALID_DATE", InvalidDateFormatException().reason, nil)
          return
      }

      var calendars: [EKCalendar] = []
      if let ids = calendarIds as? [String] {
          calendars = ids.compactMap {
              guard let cal = eventStore.calendar(withIdentifier: $0) else {
                  let exception = CalendarIdNotFoundException($0)
                  reject("CALENDAR_NOT_FOUND", exception.reason, nil)
                  return nil
              }
              return cal
          }
      }

      if calendars.isEmpty {
          calendars = eventStore.calendars(for: .event)
          guard !calendars.isEmpty else {
              reject("NO_CALENDARS", DefaultCalendarNotFoundException().reason, nil)
              return
          }
      }

      let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
      let fetchedEvents = eventStore.events(matching: predicate)

      let events = fetchedEvents.map { serializeCalendar(event: $0) }
      resolve(events)

  }




  @objc
  func saveEventAsync(_ event: NSDictionary,
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {

      DispatchQueue.main.async {
          guard let topVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
              reject("NO_VIEW_CONTROLLER", DefaultCalendarNotFoundException().reason, nil)
              return
          }

          let eventDetails = event as? [String: Any] ?? [:]

          // Required title
          guard let title = eventDetails["title"] as? String, !title.isEmpty else {
              reject("MISSING_TITLE", MissingParameterException().reason, nil)
              return
          }

          // Optional startDate and endDate
          let startDate = parse(date: eventDetails["startDate"]) ?? Date()
          let endDate = parse(date: eventDetails["endDate"]) ?? Date().addingTimeInterval(3600)

          // Overwrite eventDetails with parsed dates
          var finalEventDetails = eventDetails
          finalEventDetails["startDate"] = CalendarUtils.dateFormatter.string(from: startDate)
          finalEventDetails["endDate"] = CalendarUtils.dateFormatter.string(from: endDate)

          let vc = EditEventViewController(
              eventDetails: finalEventDetails,
              resolve: resolve,
              reject: reject,
              onDismiss: {
                  print("Event dialog dismissed")
              }
          )

          vc.modalPresentationStyle = .formSheet
          topVC.present(vc, animated: true) {
              print("Event dialog presented successfully")
          }
      }
  }


  @objc
  func deleteEventAsync(_ eventId: NSString,
                        resolver resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {

      print("🗑️ deleteEventAsync called with id: \(eventId)")

      var ekEvent: EKEvent? = nil

      // First, try calendarItemIdentifier
      if let item = eventStore.calendarItem(withIdentifier: eventId as String) as? EKEvent {
          ekEvent = item
      } else {
          // Fallback
          ekEvent = eventStore.event(withIdentifier: eventId as String)
      }

      guard let event = ekEvent else {
          reject("EVENT_NOT_FOUND", EventNotFoundException(eventId as String).reason, nil)
          return
      }

      do {
          try eventStore.remove(event, span: .thisEvent, commit: true)
          resolve([
              "status": "deleted",
              "eventId": event.eventIdentifier ?? eventId as String
          ])
      } catch {
          reject("DELETE_EVENT_FAILED", CalendarNotSavedException(event.title ?? "unknown").reason, error)
      }
  }


  // MARK: - Reminders
  // TODO: Coming soon — reminder APIs not yet implemented
}
