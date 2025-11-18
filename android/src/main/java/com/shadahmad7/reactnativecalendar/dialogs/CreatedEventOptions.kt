package com.shadahmad7.reactnativecalendar.dialogs

import java.io.Serializable

data class CreatedEventOptions(
    val title: String? = null,
    val location: String? = null,
    val url: String? = null,
    val notes: String? = null,
    val timeZone: String? = null,
    val availability: String? = null,
    val allDay: Boolean? = null,
    val startDate: String? = null,
    val endDate: String? = null,
    val recurrenceRule: Map<String, Any>? = null, // replaced ReadableArguments
    val startNewActivityTask: Boolean = true
) : Serializable
