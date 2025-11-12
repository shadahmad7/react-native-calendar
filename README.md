# @shadahmad7/react-native-calendar

React Native Calendar TurboModule for iOS and Android.

This library provides a fully native calendar module for React Native CLI apps, migrated from Expo Calendar. It allows direct access to device calendars, events, and reminders without requiring Expo. Supports creating, updating, deleting, and fetching events with proper timezone handling for both Android and iOS.

---

## Features

- Fully native calendar module
- iOS & Android support
- Handles timezones correctly
- Create, update, delete, and fetch events and reminders
- Migrated from Expo Calendar

---

## Installation

### Using npm

```bash
npm install @shadahmad7/react-native-calendar
```

### Using Yarn

```bash
yarn add @shadahmad7/react-native-calendar
```

---

## Usage

```ts
import Calendar from "@shadahmad7/react-native-calendar";

// Save a new event
const startDate = new Date();
const endDate = new Date(Date.now() + 60 * 60 * 1000); // +1 hour

const result = await Calendar.saveEvent({
  title: "Meeting",
  startDate: startDate.getTime().toString(),
  endDate: endDate.getTime().toString(),
  notes: "Team discussion",
  location: "Conference Room",
  allDay: false,
});
console.log(result);

// Fetch events
const events = await Calendar.getEventsAsync(
  new Date().toISOString(),
  new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
);
console.log(events);
```

---

## Permissions

### iOS

Add the following keys to your `Info.plist`:

```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>This app needs access to your calendar to view, create, and edit events.</string>
<key>NSCalendarsUsageDescription</key>
<string>This app needs access to your calendar to view, create, and edit events.</string>
<key>NSRemindersUsageDescription</key>
<string>This app may access reminders for scheduling and notifications.</string>
```

### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

---

## API

### Events

- `saveEvent(event: CalendarEvent)`: Create or update an event
- `deleteEvent(eventId: string)`: Delete an event
- `getEventsAsync(startDate: string, endDate: string, calendarIds?: string[])`: Fetch events
- `getEventByIdAsync(eventId: string)`: Fetch a single event

### Reminders (iOS only)

- `getRemindersAsync()`: Fetch reminders
- `saveReminderAsync(reminder: CalendarReminder)`: Save a reminder
- `deleteReminderAsync(reminderId: string)`: Delete a reminder

### Calendars

- `getCalendarsAsync()`: Get all calendars
- `getDefaultCalendarAsync()`: Get the default calendar

### Permissions

- `requestCalendarPermission()`: Request calendar permission
- `requestReminderPermission()`: Request reminder permission (iOS only)
