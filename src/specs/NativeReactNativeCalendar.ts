/**
 * NativeReactNativeCalendar Module
 * --------------------------------------
 * This file defines the TypeScript interface (Spec) for the native calendar module
 * and exposes the TurboModule for React Native usage.
 *
 * Purpose:
 *   - Provide strongly-typed access to native calendar and reminder APIs.
 *   - Expose async methods for permissions, calendars, events, and reminders.
 *
 * Platform Support:
 *   - Android: Calendar & Events fully supported; Reminder APIs not fully implemented
 *   - iOS: Calendar, Events, and Reminders fully supported
 *
 * Notes:
 *   - All dates should be ISO 8601 strings.
 *   - Reminders are iOS-only at this stage; on Android they may throw errors or return empty arrays.
 */

import { TurboModule, TurboModuleRegistry } from 'react-native';

//
// 🔹 Type Definitions
// Define the shapes of data returned or passed to the native module
//
export interface CalendarPermissionResult {
  /** true if permission granted */
  granted: boolean;

  /** "granted" | "denied" | "undetermined" */
  status: "granted" | "denied" | "undetermined";
}

export interface CalendarEvent {
  /** Event identifier (optional for new events) */
  id?: string;

  /** Event title (required) */
  title: string;

  /** Optional notes or description */
  notes?: string;

  /** ISO 8601 start date/time (required) */
  startDate: string;

  /** ISO 8601 end date/time (required) */
  endDate: string;

  /** Optional location for the event (e.g., "Conference Room") */
  location?: string;

  /** Optional url for the event (e.g., "http://example.com") */
  url?: string;

  /** Optional flag to indicate if this is an all-day event */
  allDay?: boolean;
}


export interface SaveEventResult {
  /** What happened to the event */
  action: 'saved' | 'canceled' | 'deleted';
  /** ID of the saved/deleted event */
  eventId?: string;
  /** Optional event metadata returned after save */
  title?: string;
  startDate?: string;
  endDate?: string;
}

export interface CalendarInfo {
  /** Calendar identifier */
  id: string;
  /** Calendar name/title */
  title: string;
  /** Calendar type (optional) */
  type?: string;
}

export interface CalendarReminder {
  /** Reminder ID (optional for new reminders) */
  id?: string;
  /** Reminder title */
  title: string;
  /** ISO 8601 due date */
  dueDate?: string;
}

//
// 🔹 Native Module Spec
// Defines the interface of the native TurboModule with all exposed methods
//
export interface Spec extends TurboModule {
  // === Permissions ===
  /** Request calendar access from the user */
  requestCalendarPermission(): Promise<CalendarPermissionResult>;
  /** Request reminder access from the user (iOS only) */
  requestReminderPermission(): Promise<CalendarPermissionResult>;

  // === Calendars ===
  /** Fetch all calendars on the device */
  getCalendarsAsync(): Promise<CalendarInfo[]>;
  /** Fetch the default calendar (used for new events) */
  getDefaultCalendarAsync(): Promise<CalendarInfo>;

  // === Events ===
  /** Fetch events between startDate and endDate optionally filtered by calendarIds */
  getEventsAsync(
    startDate: string,
    endDate: string,
    calendarIds?: string[],
  ): Promise<CalendarEvent[]>;

  /** Fetch a single event by ID (optionally with startDate for recurrence) */
  getEventByIdAsync(
    eventId: string,
    startDate?: string,
  ): Promise<CalendarEvent>;

  /** Create or update an event */
  saveEventAsync(event: CalendarEvent): Promise<SaveEventResult>;

  /** Delete an event by ID */
  deleteEventAsync(eventId: string): Promise<void>;

  // === Reminders ===
  // Reminder APIs are primarily iOS-only
  getRemindersAsync(): Promise<CalendarReminder[]>;
  getReminderByIdAsync(reminderId: string): Promise<CalendarReminder>;
  saveReminderAsync(reminder: CalendarReminder): Promise<string>;
  deleteReminderAsync(reminderId: string): Promise<void>;
}

//
// 🔹 Export Enforced TurboModule
// This enforces type-safe access to the native module in JS/TS
//
export default TurboModuleRegistry.getEnforcing<Spec>(
  'ReactNativeCalendar',
);
