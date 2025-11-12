package com.shadahmad7.reactnativecalendar.dialogs

import java.io.Serializable

data class ViewedEventOptions(
    val id: String,
    val startNewActivityTask: Boolean = true
) : Serializable
