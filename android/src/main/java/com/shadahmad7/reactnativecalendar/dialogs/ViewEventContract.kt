package com.shadahmad7.reactnativecalendar.dialogs

import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.provider.CalendarContract

class ViewEventContract {

    fun createIntent(context: Context, input: ViewedEventOptions): Intent {
        val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, input.id.toLong())
        return Intent(Intent.ACTION_VIEW).apply {
            data = uri
            if (input.startNewActivityTask) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
    }

    fun parseResult(input: ViewedEventOptions, resultCode: Int, intent: Intent?): ViewEventIntentResult {
        // On Android, there's no reliable way to tell what the user did
        // so we return the same result for all cases
        return ViewEventIntentResult()
    }
}
