/**
 * React Native Calendar Module
 * -----------------------------------
 * This module provides a unified interface for accessing device calendars and reminders.
 * It wraps the native iOS and Android implementations, exposing functions for:
 *   - Requesting calendar/reminder permissions
 *   - Fetching calendars and events
 *   - Creating, updating, and deleting events and reminders
 * 
 * Platform Support:
 *   - Android: Calendar & Events fully supported; Reminders not supported natively
 *   - iOS: Calendar & Events & Reminders fully supported
 *
 * All functions are async and return Promises. The default export provides
 * direct access to the full native module if needed.
 */

import NativeReactNativeCalendar from './specs/NativeReactNativeCalendar';

//
// 🔹 Permissions
// These functions request access permissions from the OS.
// - requestCalendarPermission: Ask user for calendar access
// - requestReminderPermission: Ask user for reminder access (iOS only)
//
export const requestCalendarPermission =
  NativeReactNativeCalendar.requestCalendarPermission;
export const requestReminderPermission =
  NativeReactNativeCalendar.requestReminderPermission;

//
// 🔹 Calendars
// Functions to retrieve calendar information.
// - getCalendars: Fetch all available calendars on the device
// - getDefaultCalendar: Fetch the default calendar (usually used for new events)
//
export const getCalendars = NativeReactNativeCalendar.getCalendarsAsync;

export const getDefaultCalendar =
  NativeReactNativeCalendar.getDefaultCalendarAsync;

//
// 🔹 Events
// Functions to manage calendar events.
// - getEvents: Fetch events from specified calendar(s)
// - getEventById: Fetch a single event by its ID
// - saveEvent: Create or update an event
// - deleteEvent: Delete an event
//
export const getEvents = NativeReactNativeCalendar.getEventsAsync;
export const getEventById = NativeReactNativeCalendar.getEventByIdAsync;
export const saveEvent = NativeReactNativeCalendar.saveEventAsync;
export const deleteEvent = NativeReactNativeCalendar.deleteEventAsync;

//
// 🔹 Reminders (iOS only)
// Functions to manage reminders on iOS devices.
// - getReminders: Fetch all reminders
// - getReminderById: Fetch a reminder by ID
// - saveReminder: Create or update a reminder
// - deleteReminder: Delete a reminder
//
export const getReminders = NativeReactNativeCalendar.getRemindersAsync;

export const getReminderById =
  NativeReactNativeCalendar.getReminderByIdAsync;

export const saveReminder = NativeReactNativeCalendar.saveReminderAsync;

export const deleteReminder =
  NativeReactNativeCalendar.deleteReminderAsync;

//
// 🔹 Default Export (Full Native Module)
// Provides direct access to all native methods in case advanced functionality is needed.
//
export default NativeReactNativeCalendar;

// Type exports
export type {
  CalendarEvent,
  CalendarInfo,
  CalendarPermissionResult,
  CalendarReminder,
  SaveEventResult,
} from './specs/NativeReactNativeCalendar';
