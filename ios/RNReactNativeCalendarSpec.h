// RNReactNativeCalendarSpec.h

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@protocol NativeReactNativeCalendarSpec <NSObject>

- (void)requestCalendarPermission:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject;

- (void)requestReminderPermission:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject;

- (void)getCalendarsAsync:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject;

- (void)getDefaultCalendarAsync:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject;

- (void)getEventsAsync:(NSString *)startDate
               endDate:(NSString *)endDate
               calendarIds:(NSArray<NSString *> * _Nullable)calendarIds
              resolver:(RCTPromiseResolveBlock)resolve
              rejecter:(RCTPromiseRejectBlock)reject;

- (void)getEventByIdAsync:(NSString *)eventId
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject;

- (void)saveEventAsync:(NSDictionary *)event
              resolver:(RCTPromiseResolveBlock)resolve
              rejecter:(RCTPromiseRejectBlock)reject;

- (void)deleteEventAsync:(NSString *)eventId
                resolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject;

- (void)getRemindersAsync:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject;

- (void)saveReminderAsync:(NSDictionary *)reminder
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject;

- (void)deleteReminderAsync:(NSString *)reminderId
                   resolver:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject;

@end

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewManager.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(ReactNativeCalendar, ReactNativeCalendar, NSObject)

RCT_EXTERN_METHOD(requestCalendarPermission:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestReminderPermission:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCalendarsAsync:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getDefaultCalendarAsync:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getEventsAsync:(NSString *)startDate
                  endDate:(NSString *)endDate
                  calendarIds:(NSArray<NSString *> * _Nullable)calendarIds
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getEventByIdAsync:(NSString *)eventId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(saveEventAsync:(NSDictionary *)event
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(deleteEventAsync:(NSString *)eventId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getRemindersAsync:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(saveReminderAsync:(NSDictionary *)reminder
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(deleteReminderAsync:(NSString *)reminderId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
#endif


