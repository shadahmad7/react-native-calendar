package com.shadahmad7.reactnativecalendar

import android.content.ContentValues
import android.text.TextUtils
import com.facebook.react.bridge.ReadableMap
import java.util.*

class CalendarEventBuilder(
    private val eventDetails: ReadableMap
) {
    private val eventValues = ContentValues()

    fun getAsLong(key: String): Long = eventValues.getAsLong(key)

    fun put(key: String, value: String) = apply {
        eventValues.put(key, value)
    }

    fun put(key: String, value: Int) = apply {
        eventValues.put(key, value)
    }

    fun put(key: String, value: Long) = apply {
        eventValues.put(key, value)
    }

    fun put(key: String, value: Boolean) = apply {
        eventValues.put(key, value)
    }

    fun putNull(key: String) = apply {
        eventValues.putNull(key)
    }

    fun checkIfContainsRequiredKeys(vararg keys: String) = apply {
        keys.forEach { checkDetailsContainsRequiredKey(it) }
    }

    // ---------- FIXED ----------

    fun putEventString(eventKey: String, detailsKey: String) = apply {
        if (eventDetails.hasKey(detailsKey)) {
            val value = eventDetails.getString(detailsKey) ?: ""
            eventValues.put(eventKey, value)
        }
    }

    fun putEventString(eventKey: String, detailsKey: String, mapper: (String) -> Int) = apply {
        if (eventDetails.hasKey(detailsKey)) {
            val value = eventDetails.getString(detailsKey) ?: ""
            eventValues.put(eventKey, mapper(value))
        }
    }

    fun putEventBoolean(eventKey: String, detailsKey: String) = apply {
        if (eventDetails.hasKey(detailsKey)) {
            eventValues.put(eventKey, if (eventDetails.getBoolean(detailsKey)) 1 else 0)
        }
    }

    fun putEventBoolean(eventKey: String, detailsKey: String, value: Boolean) = apply {
        if (eventDetails.hasKey(detailsKey)) {
            eventValues.put(eventKey, value)
        }
    }

    fun putEventTimeZone(eventKey: String, detailsKey: String) = apply {
        val value = if (eventDetails.hasKey(detailsKey)) {
            eventDetails.getString(detailsKey) ?: TimeZone.getDefault().id
        } else {
            TimeZone.getDefault().id
        }
        eventValues.put(eventKey, value)
    }

    fun <OutputListItemType> putEventDetailsList(
        eventKey: String,
        detailsKey: String,
        mappingMethod: (Any?) -> OutputListItemType
    ) = apply {
        val array = eventDetails.getArray(eventKey)
        if (array != null) {
            val values = array.toArrayList().map { mappingMethod(it) }
            eventValues.put(detailsKey, TextUtils.join(",", values))
        }
    }

    // ---------- Helpers ----------
    private fun checkDetailsContainsRequiredKey(key: String) = apply {
        if (!eventDetails.hasKey(key)) {
            throw Exception("new calendars require $key")
        }
    }

    fun build() = eventValues
}
