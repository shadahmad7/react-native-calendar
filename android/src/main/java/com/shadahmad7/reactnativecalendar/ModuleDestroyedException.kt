package com.shadahmad7.reactnativecalendar

import kotlinx.coroutines.CancellationException

class ModuleDestroyedException : CancellationException("Module destroyed, all promises canceled")
