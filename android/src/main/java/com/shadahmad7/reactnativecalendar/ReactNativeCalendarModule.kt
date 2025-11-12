package com.shadahmad7.reactnativecalendar

import com.facebook.react.bridge.*
import android.os.Bundle
import android.util.Log

class ReactNativeCalendarModule(reactContext: ReactApplicationContext) :
    NativeReactNativeCalendarSpec(reactContext) {

    private val calendarModule = CalendarModule(reactContext)

    // ------------------- Permissions -------------------
    @ReactMethod
    override fun requestCalendarPermission(promise: Promise) {
        calendarModule.requestCalendarPermissionsAsync(promise)
    }

    @ReactMethod
    override fun requestReminderPermission(promise: Promise) {
        // Placeholder: Reminders not implemented yet
        promise.resolve(Arguments.createMap().apply { putBoolean("granted", false) })
    }

    // ------------------- Calendars -------------------
    @ReactMethod
    override fun getCalendarsAsync(promise: Promise) {
        try {
            val calendars = calendarModule.getCalendars()
            val writableList = Arguments.createArray()
            calendars.forEach { writableList.pushMap(mapBundleToWritableMap(it)) }
            promise.resolve(writableList)
        } catch (e: Exception) {
            promise.reject("GET_CALENDARS_ERROR", e)
        }
    }

    @ReactMethod
    override fun getDefaultCalendarAsync(promise: Promise) {
        Log.d("Calendar", "getDefaultCalendarAsync() called")

        try {
            Log.d("Calendar", "Fetching calendars via calendarModule.getCalendars()")
            val calendars = calendarModule.getCalendars()

            Log.d("Calendar", "Calendars fetched: count=${calendars.size}")

            if (calendars.isNotEmpty()) {
                val firstCalendar = calendars.first()
                Log.d("Calendar", "First calendar details: ${firstCalendar}")

                val mapped = mapBundleToWritableMap(firstCalendar)
                Log.d("Calendar", "Mapped first calendar to WritableMap: ${mapped}")

                promise.resolve(mapped)
                Log.d("Calendar", "Promise resolved successfully with default calendar")
            } else {
                Log.w("Calendar", "No calendars found — rejecting promise")
                promise.reject("NO_DEFAULT_CALENDAR", "No calendars found")
            }

        } catch (e: Exception) {
            Log.e("Calendar", "Error in getDefaultCalendarAsync", e)
            promise.reject("GET_DEFAULT_CALENDAR_ERROR", e)
        }
    }


    // ------------------- Events -------------------
    @ReactMethod
    override fun getEventsAsync(
        startDate: String,
        endDate: String,
        calendarIds: ReadableArray?,
        promise: Promise
    ) {
        try {
            // Convert ReadableArray to List<String> or null
            val ids: List<String>? = calendarIds?.toArrayList()?.map { it.toString() }

            val events = calendarModule.getEvents(startDate, endDate, null)
            val writableList = Arguments.createArray()
            events.forEach { writableList.pushMap(mapBundleToWritableMap(it)) }
            promise.resolve(writableList)
        } catch (e: Exception) {
            promise.reject("GET_EVENTS_ERROR", e)
        }
    }

    @ReactMethod
    override fun getEventByIdAsync(eventId: String, startDate: String?, promise: Promise) {
        try {
            val event = calendarModule.getEventById(eventId, startDate)
            promise.resolve(mapBundleToWritableMap(event))
        } catch (e: Exception) {
            promise.reject("GET_EVENT_BY_ID_ERROR", e)
        }
    }

    @ReactMethod
    override fun saveEventAsync(details: ReadableMap, promise: Promise) {
        try {
            val map = readableMapToMap(details)
            val result = calendarModule.saveEvent(map.filterValues { it != null } as Map<String, Any>)
            val writableMap = Arguments.createMap().apply {
                putString("action", "saved")
                putString("eventId", result.toString())
                putString("title", map["title"]?.toString())
                putString("startDate", map["startDate"]?.toString())
                putString("endDate", map["endDate"]?.toString())
            }
            promise.resolve(writableMap)
        } catch (e: Exception) {
            promise.reject("SAVE_EVENT_ERROR", e)
        }
    }

    @ReactMethod
    override fun deleteEventAsync(eventId: String, promise: Promise) {
        try {
            calendarModule.deleteEvent(eventId)
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("DELETE_EVENT_ERROR", e)
        }
    }

    // ------------------- Reminders (Coming Soon) -------------------
    @ReactMethod
    override fun getRemindersAsync(promise: Promise) {
        promise.resolve(Arguments.createArray()) // placeholder empty array
    }

    @ReactMethod
    override fun getReminderByIdAsync(reminderId: String, promise: Promise) {
        promise.resolve(Arguments.createMap()) // placeholder empty map
    }

    @ReactMethod
    override fun saveReminderAsync(reminder: ReadableMap, promise: Promise) {
        promise.resolve("placeholder-reminder-id") // fake ID for now
    }

    @ReactMethod
    override fun deleteReminderAsync(reminderId: String, promise: Promise) {
        promise.resolve(null) // nothing to delete
    }

    // ------------------- Helpers -------------------
    private fun mapBundleToWritableMap(bundle: Bundle): WritableMap {
        val map: WritableMap = Arguments.createMap()
        for (key in bundle.keySet()) {
            when (val value = bundle.get(key)) {
                is String -> map.putString(key, value)
                is Int -> map.putInt(key, value)
                is Boolean -> map.putBoolean(key, value)
                is Double -> map.putDouble(key, value)
                is Bundle -> map.putMap(key, mapBundleToWritableMap(value))
                else -> map.putString(key, value?.toString())
            }
        }
        return map
    }

    private fun readableMapToMap(readableMap: ReadableMap): Map<String, Any?> {
        val iterator = readableMap.keySetIterator()
        val map = mutableMapOf<String, Any?>()
        while (iterator.hasNextKey()) {
            val key = iterator.nextKey()
            when (readableMap.getType(key)) {
                ReadableType.Null -> map[key] = null
                ReadableType.Boolean -> map[key] = readableMap.getBoolean(key)
                ReadableType.Number -> map[key] = readableMap.getDouble(key)
                ReadableType.String -> map[key] = readableMap.getString(key)
                ReadableType.Map -> map[key] = readableMapToMap(readableMap.getMap(key)!!)
                ReadableType.Array -> map[key] = readableArrayToList(readableMap.getArray(key)!!)
            }
        }
        return map
    }

    private fun readableArrayToList(readableArray: ReadableArray): List<Any?> {
        val list = mutableListOf<Any?>()
        for (i in 0 until readableArray.size()) {
            when (readableArray.getType(i)) {
                ReadableType.Null -> list.add(null)
                ReadableType.Boolean -> list.add(readableArray.getBoolean(i))
                ReadableType.Number -> list.add(readableArray.getDouble(i))
                ReadableType.String -> list.add(readableArray.getString(i))
                ReadableType.Map -> list.add(readableMapToMap(readableArray.getMap(i)!!))
                ReadableType.Array -> list.add(readableArrayToList(readableArray.getArray(i)!!))
            }
        }
        return list
    }


    companion object {
        const val NAME = "ReactNativeCalendar"
    }

    override fun getName(): String = NAME
}
