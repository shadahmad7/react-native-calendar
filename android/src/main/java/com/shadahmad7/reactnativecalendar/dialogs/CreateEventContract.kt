package com.shadahmad7.reactnativecalendar.dialogs

import android.content.Context
import android.content.Intent
import android.provider.CalendarContract
import com.facebook.react.bridge.Arguments
import com.shadahmad7.reactnativecalendar.EventRecurrenceUtils.createRecurrenceRule
import com.shadahmad7.reactnativecalendar.EventRecurrenceUtils.extractRecurrence
import com.shadahmad7.reactnativecalendar.availabilityConstantMatchingString
import java.text.SimpleDateFormat
import java.util.*


class CreateEventContract {

    fun createIntent(context: Context, input: CreatedEventOptions): Intent =
        Intent(Intent.ACTION_INSERT, CalendarContract.Events.CONTENT_URI).apply {
            input.title?.let { putExtra(CalendarContract.Events.TITLE, it) }
            input.notes?.let { putExtra(CalendarContract.Events.DESCRIPTION, it) }
            input.location?.let { putExtra(CalendarContract.Events.EVENT_LOCATION, it) }
            input.allDay?.let { putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, it) }

            input.url?.let { 
                putExtra(CalendarContract.Events.CUSTOM_APP_URI, it) 
            }

            // **Send milliseconds directly**
            input.startDate?.let { putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, it.toLong()) }
            input.endDate?.let { putExtra(CalendarContract.EXTRA_EVENT_END_TIME, it.toLong()) }

            // Optional timezone (not strictly necessary if millis are correct)
            putExtra(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)

            input.availability?.let { putExtra(CalendarContract.Events.AVAILABILITY, availabilityConstantMatchingString(it)) }

            if (input.startNewActivityTask) addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

    // No need to parse ISO strings anymore if you send millis from JS
    fun getTimestamp(dateString: String): Long = dateString.toLong()

    fun parseResult(resultCode: Int, intent: Intent?): CreateEventIntentResult {
        return CreateEventIntentResult()
    }
}
