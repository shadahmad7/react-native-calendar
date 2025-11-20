package com.shadahmad7.reactnativecalendar

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.CalendarContract
import com.facebook.react.bridge.Promise
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.WritableNativeMap
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener
import androidx.core.app.ActivityCompat


import com.shadahmad7.reactnativecalendar.findCalendarsQueryParameters
import com.shadahmad7.reactnativecalendar.findEventsQueryParameters

import com.shadahmad7.reactnativecalendar.utils.CalendarUtils


import com.shadahmad7.reactnativecalendar.dialogs.CreateEventContract
import com.shadahmad7.reactnativecalendar.dialogs.CreateEventIntentResult
import com.shadahmad7.reactnativecalendar.dialogs.CreatedEventOptions
import com.shadahmad7.reactnativecalendar.dialogs.ViewEventIntentResult
import com.shadahmad7.reactnativecalendar.dialogs.ViewEventContract
import com.shadahmad7.reactnativecalendar.dialogs.ViewedEventOptions

class CalendarModule(private val context: Context) {

    private val contentResolver = context.contentResolver
    private val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").apply {
        timeZone = TimeZone.getTimeZone("GMT")
    }

    // ------------------- Permissions -------------------
    private var permissionPromise: Promise? = null

    private val permissionListener = PermissionListener { requestCode, permissions, grantResults ->
        if (requestCode != 1234) return@PermissionListener false

        var allGranted = true
        for (result in grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                allGranted = false
            }
        }

        val status = if (allGranted) "granted" else "denied"

        val map = Arguments.createMap()
        map.putBoolean("granted", allGranted)
        map.putString("status", status)

        permissionPromise?.resolve(map)
        permissionPromise = null

        true
    }

    fun requestCalendarPermissionsAsync(promise: Promise) {
        try {
            val readGranted = ContextCompat.checkSelfPermission(
                context, Manifest.permission.READ_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED

            val writeGranted = ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED

            // Already granted
            if (readGranted && writeGranted) {
                val map = Arguments.createMap()
                map.putBoolean("granted", true)
                map.putString("status", "granted")
                promise.resolve(map)
                return
            }

            val activity = (context as ReactApplicationContext).currentActivity
            if (activity == null) {
                promise.reject("NO_ACTIVITY", "Cannot request permissions without activity")
                return
            }

            // Save to resolve later
            permissionPromise = promise

            // Activity must implement PermissionAwareActivity
            (activity as PermissionAwareActivity).requestPermissions(
                arrayOf(
                    Manifest.permission.READ_CALENDAR,
                    Manifest.permission.WRITE_CALENDAR
                ),
                1234,
                permissionListener
            )

        } catch (e: Exception) {
            promise.reject("PERMISSION_REQUEST_ERROR", e)
        }
    }


    fun getCalendarPermissionsAsync(promise: Promise) {
        try {
            val readGranted = ContextCompat.checkSelfPermission(
                context, Manifest.permission.READ_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED

            val writeGranted = ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED

            val granted = readGranted && writeGranted

            val status = when {
                granted -> "granted"
                !readGranted || !writeGranted -> "denied"
                else -> "undetermined"
            }

            val map = Arguments.createMap()
            map.putBoolean("granted", granted)
            map.putString("status", status)

            promise.resolve(map)
        } catch (e: Exception) {
            promise.reject("PERMISSION_GET_ERROR", e)
        }
    }



    // ------------------- Calendars -------------------
    @Throws(SecurityException::class)
    fun getCalendars(): List<Bundle> {
        val uri = CalendarContract.Calendars.CONTENT_URI
        val cursor = contentResolver.query(uri, findCalendarsQueryParameters, null, null, null)
            ?: return emptyList()
        return cursor.use { CalendarUtils.serializeEventCalendars(it) }
    }

    @Throws(Exception::class, SecurityException::class)
    fun saveCalendar(details: Map<String, Any>): Int {
        val builder = CalendarEventBuilder(mapToReadableMap(details))

        builder
            .putEventString(CalendarContract.Calendars.NAME, "name")
            .putEventString(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, "title")
            .putEventBoolean(CalendarContract.Calendars.VISIBLE, "isVisible")
            .putEventBoolean(CalendarContract.Calendars.SYNC_EVENTS, "isSynced")

        if (details.containsKey("id")) {
            val calendarID = details["id"].toString().toInt()
            val updateUri = ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, calendarID.toLong())
            contentResolver.update(updateUri, builder.build(), null, null)
            return calendarID
        } else {
            builder.checkIfContainsRequiredKeys(
                "name", "title", "source", "color", "accessLevel", "ownerAccount"
            )
            val source = details["source"] as? Map<String, Any> ?: throw Exception("Missing source")
            val isLocalAccount = source["isLocalAccount"] as? Boolean ?: false
            val accountType = if (isLocalAccount) CalendarContract.ACCOUNT_TYPE_LOCAL else source["type"] as? String

            // ACCOUNT_NAME (string) ✅
            builder.putEventString(CalendarContract.Calendars.ACCOUNT_NAME, "name")

            // ACCOUNT_TYPE (nullable string) ✅
            builder.putEventString(CalendarContract.Calendars.ACCOUNT_TYPE, "type") // ensure "type" exists in map
            // or fallback
            val type = source["type"] as? String ?: CalendarContract.ACCOUNT_TYPE_LOCAL
            builder.putEventString(CalendarContract.Calendars.ACCOUNT_TYPE, type)


            // COLOR (int) ✅ use mapper
            builder.putEventString(CalendarContract.Calendars.CALENDAR_COLOR, "color") { value ->
                (details["color"] as? Int) ?: 0
            }

            // ACCESS_LEVEL (int) ✅ use mapper
            builder.putEventString(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL, "accessLevel") { value ->
                calAccessConstantMatchingString(value)
            }

            builder.putEventString(CalendarContract.Calendars.OWNER_ACCOUNT, details["ownerAccount"].toString())
                .putEventTimeZone(CalendarContract.Calendars.CALENDAR_TIME_ZONE, "timeZone")

            val uriBuilder = CalendarContract.Calendars.CONTENT_URI.buildUpon()
                .appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
                .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, source["name"].toString())
                .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_TYPE, accountType)

            val calendarUri = contentResolver.insert(uriBuilder.build(), builder.build())
            return calendarUri!!.lastPathSegment!!.toInt()
        }
    }

    @Throws(SecurityException::class)
    fun deleteCalendar(calendarId: String): Boolean {
        val uri = ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, calendarId.toLong())
        val rows = contentResolver.delete(uri, null, null)
        return rows > 0
    }

    // ------------------- Events -------------------
   @Throws(ParseException::class, SecurityException::class)
    fun saveEvent(details: Map<String, Any>) {
        try {
            val currentActivity = (context as ReactApplicationContext).currentActivity
                ?: throw Exception("No current activity available to show calendar dialog")

            // Determine calendarId
            val calendarId = details["calendarId"]?.toString()?.toInt()
                ?: run {
                    Log.w("Calendar", "calendarId not provided, selecting default calendar")
                    val calendars = getCalendars()
                    // If no calendars found, try to open native calendar app
                    if (calendars.isEmpty()) {
                        Log.w("Calendar", "No calendar found — trying to open native calendar app")

                        val launched = CalendarUtils.tryOpenCalendarApp(context)

                        if (!launched) {
                            throw Exception("No calendar found on device — cannot open create event dialog")
                        }

                        // Stop execution here because user will come back after login/setup
                        return
                    }
                    val defaultCalendar = calendars[0]
                    defaultCalendar.getLong(CalendarContract.Calendars._ID).toInt()
                }

            Log.d("Calendar", "Using calendarId: $calendarId")

            // Map input details to CreatedEventOptions
            val input = CreatedEventOptions(
                title = details["title"] as? String,
                notes = details["notes"] as? String,
                location = details["location"] as? String,
                url = details["url"] as? String,
                allDay = details["allDay"] as? Boolean,
                startDate = details["startDate"] as? String,
                endDate = details["endDate"] as? String,
                timeZone = details["timeZone"] as? String,
                availability = details["availability"] as? String,
                recurrenceRule = details["recurrenceRule"] as? Map<String, Any>,
                startNewActivityTask = true
            )

            // Create and launch the dialog intent
            val intent = CreateEventContract().createIntent(context, input)
            currentActivity.startActivity(intent)

            Log.d("Calendar", "Create event dialog launched")

        } catch (e: SecurityException) {
            Log.e("Calendar", "Calendar permission not granted", e)
            throw SecurityException("Calendar permissions required")
        } catch (e: Exception) {
            Log.e("Calendar", "Failed to open create event dialog", e)
            throw e
        }
    }



    @Throws(SecurityException::class)
    fun deleteEvent(eventID: String): Boolean {
        Log.d("Calendar", "deleteEvent() called for ID: $eventID")

        return try {
            val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventID.toLong())
            val rows = contentResolver.delete(uri, null, null)
            Log.d("Calendar", "Deleted rows count: $rows")
            rows > 0
        } catch (e: Exception) {
            Log.e("Calendar", "Error deleting event $eventID", e)
            false
        }
    }

    fun openEvent(eventID: String) {
        Log.d("Calendar", "openEvent() called for ID: $eventID")
        try {
            val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventID.toLong())
            val intent = Intent(Intent.ACTION_VIEW)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .setData(uri)

            if (intent.resolveActivity(context.packageManager) != null) {
                Log.d("Calendar", "Launching event view intent for ID: $eventID")
                context.startActivity(intent)
            } else {
                Log.w("Calendar", "No activity found to handle view intent")
            }
        } catch (e: Exception) {
            Log.e("Calendar", "Error opening event $eventID", e)
        }
    }

    // ------------------- TurboModule Helper Methods -------------------
    @Throws(SecurityException::class)
    fun getEvents(startDate: String, endDate: String, calendarIds: List<String>? = null): List<Bundle> {
        Log.d(TAG, "Calendar: getEvents() called with startDate=$startDate, endDate=$endDate, calendarIds=$calendarIds")

        // Convert ISO strings to millis
        val startMillis = try {
            val time = sdf.parse(startDate)?.time ?: throw IllegalArgumentException("Invalid startDate: $startDate")
            Log.d(TAG, "Calendar: Parsed startDate to millis: $time")
            time
        } catch (e: Exception) {
            Log.e(TAG, "Calendar: Failed to parse startDate: $startDate", e)
            return emptyList()
        }

        val endMillis = try {
            val time = sdf.parse(endDate)?.time ?: throw IllegalArgumentException("Invalid endDate: $endDate")
            Log.d(TAG, "Calendar: Parsed endDate to millis: $time")
            time
        } catch (e: Exception) {
            Log.e(TAG, "Calendar: Failed to parse endDate: $endDate", e)
            return emptyList()
        }

        // Build selection
        val selectionArgs = mutableListOf(startMillis.toString(), endMillis.toString())
        val selectionBuilder = StringBuilder("${CalendarContract.Events.DTSTART} >= ? AND ${CalendarContract.Events.DTEND} <= ?")

        calendarIds?.let {
            if (it.isNotEmpty()) {
                val placeholders = it.joinToString(",") { "?" }
                selectionBuilder.append(" AND ${CalendarContract.Events.CALENDAR_ID} IN ($placeholders)")
                selectionArgs.addAll(it)
                Log.d(TAG, "Calendar: Filtering by calendarIds: $it, selection: $selectionBuilder, args: $selectionArgs")
            }
        }

        Log.d(TAG, "Calendar: Final selection: $selectionBuilder")
        Log.d(TAG, "Calendar: Final selectionArgs: $selectionArgs")

        val cursor = try {
                        contentResolver.query(
                            CalendarContract.Events.CONTENT_URI,
                            null, // fet
                            selectionBuilder.toString(),
                            selectionArgs.toTypedArray(),
                            null
                        )
                    } catch (e: Exception) {
                        Log.e(TAG, "Error querying events", e) // <- print full stack trace
                        return emptyList()
                    }

        if (cursor == null) {
            Log.w(TAG, "Calendar: Cursor is null — no results")
            return emptyList()
        }

        cursor.use {
            Log.d(TAG, "Calendar: Cursor count: ${it.count}")
            val events = CalendarUtils.serializeEvents(it)
            Log.d(TAG, "Calendar: Serialized ${events.size} events: ${events.map { e -> e.toString() }}")
            return events
        }
    }



    @Throws(SecurityException::class)
    fun getEventById(eventId: String, startDate: String? = null): Bundle {
        val cursor = contentResolver.query(
            CalendarContract.Events.CONTENT_URI,
            findEventsQueryParameters,
            "${CalendarContract.Events._ID} = ?",
            arrayOf(eventId),
            null
        ) ?: throw Exception("Event not found")

        return cursor.use { c ->
            if (c.moveToFirst()) CalendarUtils.serializeEvent(c)
            else throw Exception("Event not found")
        }
    }


    fun mapToReadableMap(map: Map<String, Any>): com.facebook.react.bridge.ReadableMap {
        val writableMap = WritableNativeMap()
        for ((key, value) in map) {
            when (value) {
                is String -> writableMap.putString(key, value)
                is Boolean -> writableMap.putBoolean(key, value)
                is Int -> writableMap.putInt(key, value)
                is Double -> writableMap.putDouble(key, value.toDouble())
                else -> {} // ignore unsupported types
            }
        }
        return writableMap
    }

    companion object {
        internal val TAG = "CalendarModule"
    }
}
