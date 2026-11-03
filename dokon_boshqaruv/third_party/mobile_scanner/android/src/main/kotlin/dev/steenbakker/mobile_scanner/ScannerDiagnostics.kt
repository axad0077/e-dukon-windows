package dev.steenbakker.mobile_scanner

import java.util.concurrent.atomic.AtomicLong

// Local, bounded metadata only. Never stores images or barcode values.
object ScannerDiagnostics {
    @Volatile var stage: String = "idle"
    @Volatile var lastFailure: String? = null
    val frames = AtomicLong(0)
    val released = AtomicLong(0)
    val analyzed = AtomicLong(0)
    val successes = AtomicLong(0)
    val failures = AtomicLong(0)
    val detections = AtomicLong(0)
    fun reset() {
        stage = "start.request"
        lastFailure = null
        frames.set(0); released.set(0); analyzed.set(0)
        successes.set(0); failures.set(0); detections.set(0)
    }
    fun failure(stageName: String, error: Throwable) {
        stage = stageName
        failures.incrementAndGet()
        lastFailure = ("$stageName: " + error.stackTraceToString()).take(10000)
    }
    fun snapshot(): Map<String, Any?> = mapOf(
        "stage" to stage,
        "frames_received" to frames.get(),
        "frames_released" to released.get(),
        "mlkit_requests" to analyzed.get(),
        "mlkit_successes" to successes.get(),
        "failures" to failures.get(),
        "barcodes_detected_count" to detections.get(),
        "last_failure" to lastFailure
    )
}
