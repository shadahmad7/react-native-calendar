package com.shadahmad7.reactnativecalendar.utils

import android.database.Cursor
import android.os.Bundle
import android.provider.CalendarContract
import com.facebook.react.bridge.WritableNativeMap
import java.text.SimpleDateFormat
import java.util.Locale // ✅ Missing import for Locale
import com.shadahmad7.reactnativecalendar.CalendarEventBuilder // ✅ Missing import for CalendarEventBuilder

object CalendarUtils {

    val findCalendarsQueryParameters = arrayOf(
        CalendarContract.Calendars._ID,
        CalendarContract.Calendars.NAME,
        CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
        CalendarContract.Calendars.ACCOUNT_NAME,
        CalendarContract.Calendars.ACCOUNT_TYPE,
        CalendarContract.Calendars.CALENDAR_COLOR,
        CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
        CalendarContract.Calendars.OWNER_ACCOUNT,
        CalendarContract.Calendars.CALENDAR_TIME_ZONE,
        CalendarContract.Calendars.VISIBLE,
        CalendarContract.Calendars.SYNC_EVENTS,
        CalendarContract.Calendars.ALLOWED_AVAILABILITY,
        CalendarContract.Calendars.ALLOWED_REMINDERS,
        CalendarContract.Calendars.ALLOWED_ATTENDEE_TYPES,
        CalendarContract.Calendars.IS_PRIMARY
    )

    // ------------------- Serialization -------------------
    fun serializeEventCalendars(cursor: Cursor): List<Bundle> {
        val results = mutableListOf<Bundle>()
        while (cursor.moveToNext()) {
            results.add(serializeEventCalendar(cursor))
        }
        return results
    }

    fun serializeEventCalendar(cursor: Cursor): Bundle {
        val calendar = Bundle().apply {
            putString("id", optStringFromCursor(cursor, CalendarContract.Calendars._ID))
            putString("title", optStringFromCursor(cursor, CalendarContract.Calendars.CALENDAR_DISPLAY_NAME))
            putBoolean("isPrimary", optIntFromCursor(cursor, CalendarContract.Calendars.IS_PRIMARY) == 1)
            putString("name", optStringFromCursor(cursor, CalendarContract.Calendars.NAME))
            putString(
                "color",
                String.format("#%06X", 0xFFFFFF and optIntFromCursor(cursor, CalendarContract.Calendars.CALENDAR_COLOR))
            )
            putString("ownerAccount", optStringFromCursor(cursor, CalendarContract.Calendars.OWNER_ACCOUNT))
            putString("timeZone", optStringFromCursor(cursor, CalendarContract.Calendars.CALENDAR_TIME_ZONE))

            val accessLevel = optIntFromCursor(cursor, CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)
            putString("accessLevel", calAccessStringMatchingConstant(accessLevel))
            putBoolean(
                "allowsModifications",
                accessLevel == CalendarContract.Calendars.CAL_ACCESS_ROOT ||
                        accessLevel == CalendarContract.Calendars.CAL_ACCESS_OWNER ||
                        accessLevel == CalendarContract.Calendars.CAL_ACCESS_EDITOR ||
                        accessLevel == CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR
            )
        }

        val source = Bundle().apply {
            putString("name", optStringFromCursor(cursor, CalendarContract.Calendars.ACCOUNT_NAME))
            val type = optStringFromCursor(cursor, CalendarContract.Calendars.ACCOUNT_TYPE)
            putString("type", type)
            putBoolean("isLocalAccount", type == CalendarContract.ACCOUNT_TYPE_LOCAL)
        }
        calendar.putBundle("source", source)
        return calendar
    }

    // ------------------- Events Serialization -------------------
    fun serializeEvents(cursor: Cursor): List<Bundle> {
        val results = mutableListOf<Bundle>()
        while (cursor.moveToNext()) {
            results.add(serializeEvent(cursor))
        }
        return results
    }

    fun serializeEvent(cursor: Cursor): Bundle {
        val event = Bundle().apply {
            putString("id", optStringFromCursor(cursor, CalendarContract.Events._ID))
            putString("title", optStringFromCursor(cursor, CalendarContract.Events.TITLE))
            putString("notes", optStringFromCursor(cursor, CalendarContract.Events.DESCRIPTION))
            putString("location", optStringFromCursor(cursor, CalendarContract.Events.EVENT_LOCATION))
            putBoolean("allDay", optIntFromCursor(cursor, CalendarContract.Events.ALL_DAY) == 1)
            putString("timeZone", optStringFromCursor(cursor, CalendarContract.Events.EVENT_TIMEZONE))
            putString("endTimeZone", optStringFromCursor(cursor, CalendarContract.Events.EVENT_END_TIMEZONE))
            putString("calendarId", optStringFromCursor(cursor, CalendarContract.Events.CALENDAR_ID))
            putLong("startDate", cursor.getLong(cursor.getColumnIndex(CalendarContract.Events.DTSTART)))
            putLong("endDate", cursor.getLong(cursor.getColumnIndex(CalendarContract.Events.DTEND)))
        }
        return event
    }

    // ------------------- Helpers -------------------
    fun optStringFromCursor(cursor: Cursor, columnName: String): String? {
        val index = cursor.getColumnIndex(columnName)
        return if (index == -1) null else cursor.getString(index)
    }

    fun optIntFromCursor(cursor: Cursor, columnName: String): Int {
        val index = cursor.getColumnIndex(columnName)
        return if (index == -1) 0 else cursor.getInt(index)
    }

    fun calAccessStringMatchingConstant(accessLevel: Int): String {
        return when (accessLevel) {
            CalendarContract.Calendars.CAL_ACCESS_OWNER -> "owner"
            CalendarContract.Calendars.CAL_ACCESS_EDITOR -> "editor"
            CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR -> "contributor"
            CalendarContract.Calendars.CAL_ACCESS_FREEBUSY -> "freeBusy"
            CalendarContract.Calendars.CAL_ACCESS_READ -> "read"
            CalendarContract.Calendars.CAL_ACCESS_ROOT -> "root"
            else -> "unknown"
        }
    }

    fun calAccessConstantMatchingString(str: String): Int {
        return when (str.lowercase(Locale.getDefault())) {
            "owner" -> CalendarContract.Calendars.CAL_ACCESS_OWNER
            "editor" -> CalendarContract.Calendars.CAL_ACCESS_EDITOR
            "contributor" -> CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR
            "freebusy" -> CalendarContract.Calendars.CAL_ACCESS_FREEBUSY
            "read" -> CalendarContract.Calendars.CAL_ACCESS_READ
            "root" -> CalendarContract.Calendars.CAL_ACCESS_ROOT
            else -> CalendarContract.Calendars.CAL_ACCESS_NONE
        }
    }

    fun setDateInBuilder(builder: CalendarEventBuilder, field: String, date: Any, sdf: SimpleDateFormat) {
        when (date) {
            is String -> {
                val parsed = sdf.parse(date)
                if (parsed != null) builder.put(field, parsed.time)
            }
            is Number -> builder.put(field, date.toLong())
        }
    }
}
