// ReactNativeCalendar.swift

import Foundation
import React

@objc(ReactNativeCalendar)
@objcMembers
public class ReactNativeCalendar: NSObject, RCTBridgeModule {
  public static func moduleName() -> String! {
    return "ReactNativeCalendar"
  }

  public static func requiresMainQueueSetup() -> Bool {
    return false
  }

  private let manager = CalendarManager.shared

  // MARK: - Permissions

  @objc
  func requestCalendarPermission(_ resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) {
      manager.requestCalendarPermissionsAsync(resolve, rejecter: reject)
  }


  @objc
  func requestReminderPermission(_ resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {
    manager.requestRemindersPermissionsAsync(resolve, rejecter: reject)
  }

  // MARK: - Calendars

  @objc
  func getCalendarsAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
    manager.getCalendarsAsync(resolve, rejecter: reject)
  }

  @objc
  func getDefaultCalendarAsync(_ resolve: @escaping RCTPromiseResolveBlock,
                               rejecter reject: @escaping RCTPromiseRejectBlock) {
    manager.getDefaultCalendarAsync(resolve, rejecter: reject)
  }

  // MARK: - Events

  @objc
  func getEventsAsync(_ startDate: String,
                      endDate: String,
                      calendarIds: [String]?, // optional array
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {

      // ✅ Convert optional [String]? to NSArray? for Obj-C interop
      let calendarIdsNSArray: NSArray? = calendarIds?.map { $0 as NSString } as NSArray?

      // Call the manager method
      manager.getEventsAsync(
          startDate as NSString,
          endDate: endDate as NSString,
          calendarIds: calendarIdsNSArray,
          resolver: resolve,
          rejecter: reject
      )
  }


  @objc
  func saveEventAsync(_ event: NSDictionary,
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
    manager.saveEventAsync(event, resolver: resolve, rejecter: reject)
  }

  @objc
  func deleteEventAsync(_ eventId: String,
                        resolver resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
    manager.deleteEventAsync(eventId as NSString, resolver: resolve, rejecter: reject)
  }

  // MARK: - Reminders
  // TODO: Coming soon — reminder APIs not yet implemented
}
