package dev.steenbakker.mobile_scanner

class NoCamera : Exception()
class AlreadyStarted : Exception()
class AlreadyStopped : Exception()
class AlreadyPaused : Exception()
class CameraError : Exception()
class ZoomWhenStopped : Exception()
class ZoomNotInRange : Exception()

// Local patch: preserve the original Android failure instead of discarding it.
class CameraSetupError(val stage: String, original: Throwable) :
    Exception("$stage: ${original.javaClass.simpleName}: ${original.message}", original)
