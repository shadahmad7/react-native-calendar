package com.shadahmad7.reactnativecalendar

import com.facebook.react.bridge.ReadableMap
import android.content.ContentValues

class AttendeeBuilder(
  private val attendeeDetails: ReadableMap
) {
    private val attendeeValues = ContentValues()

    fun put(key: String, value: Int?) = apply {
        attendeeValues.put(key, value)
    }

    fun putString(detailsKey: String, detailsString: String) = apply {
        if (attendeeDetails.hasKey(detailsKey)) {
            val value = attendeeDetails.getString(detailsKey) ?: ""
            attendeeValues.put(detailsString, value)
        }
    }

    fun putString(detailsKey: String, detailsString: String, isRequired: Boolean) = apply {
        if (attendeeDetails.hasKey(detailsKey)) {
            val value = attendeeDetails.getString(detailsKey) ?: ""
            attendeeValues.put(detailsString, value)
        } else if (isRequired) {
            throw Exception("new attendees require `$detailsKey`")
        }
    }

    fun putString(
        detailsKey: String,
        detailsString: String,
        isRequired: Boolean?,
        mapper: (String) -> Int
    ) = apply {
        if (attendeeDetails.hasKey(detailsKey)) {
            val value = attendeeDetails.getString(detailsKey) ?: ""
            attendeeValues.put(detailsString, mapper(value))
        } else if (isRequired == true) {
            throw Exception("new attendees require `$detailsKey`")
        }
    }


    fun build() = attendeeValues
}
