package com.shadahmad7.reactnativecalendar

import android.util.Log
import com.facebook.react.bridge.ReadableMap
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.TimeZone

data class Recurrence(
    val frequency: String,
    val interval: Int?,
    val endDate: String?,
    val occurrence: Int?
)

object EventRecurrenceUtils {

    private const val TAG = "RNCalendarModule"

    private val isoDateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").apply {
        timeZone = TimeZone.getTimeZone("GMT")
    }

    private val androidRRuleFormat = SimpleDateFormat("yyyyMMdd'T'HHmmss'Z'").apply {
        timeZone = TimeZone.getTimeZone("GMT")
    }

    /**
     * Extract recurrence from a JS object (ReadableMap) into Recurrence data class
     */
    fun extractRecurrence(recurrenceRule: ReadableMap): Recurrence {
        val frequency = recurrenceRule.getString("frequency") ?: ""
        val interval = if (recurrenceRule.hasKey("interval")) recurrenceRule.getInt("interval") else null
        val occurrence = if (recurrenceRule.hasKey("occurrence")) recurrenceRule.getInt("occurrence") else null

        var endDate: String? = null
        if (recurrenceRule.hasKey("endDate")) {
            val endObj = recurrenceRule.getDynamic("endDate")
            endDate = when {
                endObj != null && endObj.type == com.facebook.react.bridge.ReadableType.String -> {
                    endObj.asString()?.let { parseEndDate(it) }
                }
                endObj != null && endObj.type == com.facebook.react.bridge.ReadableType.Number -> {
                    val calendar = Calendar.getInstance()
                    calendar.timeInMillis = endObj.asDouble().toLong()
                    androidRRuleFormat.format(calendar.time)
                }
                else -> {
                    Log.e(TAG, "endDate could not be parsed")
                    null
                }
            }
        }

        return Recurrence(frequency, interval, endDate, occurrence)
    }

    /**
     * Build RRULE string for Android calendar
     */
    fun createRecurrenceRule(opts: Recurrence): String {
        val (frequency, interval, endDate, occurrence) = opts
        var rrule = when (frequency.lowercase()) {
            "daily" -> "FREQ=DAILY"
            "weekly" -> "FREQ=WEEKLY"
            "monthly" -> "FREQ=MONTHLY"
            "yearly" -> "FREQ=YEARLY"
            else -> ""
        }

        if (interval != null) rrule += ";INTERVAL=$interval"
        if (endDate != null) rrule += ";UNTIL=$endDate"
        else if (occurrence != null) rrule += ";COUNT=$occurrence"

        return rrule
    }

    /**
     * Helper to parse ISO8601 string into Android RRULE format
     */
    private fun parseEndDate(dateStr: String): String? {
        return try {
            val parsed = isoDateFormat.parse(dateStr)
            if (parsed != null) androidRRuleFormat.format(parsed) else null
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing endDate: $dateStr", e)
            null
        }
    }
}
