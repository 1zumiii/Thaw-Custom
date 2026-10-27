//
//  MenuBarDisplayChangeEffects+Recapture.swift
//  Project: Thaw
//
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

/// What a settled display change asks of the image cache.
protocol DisplayChangeImageCache: AnyObject {
    /// Drops the images captured on a display that is gone.
    func performCacheCleanup()
    /// Captures once for whatever needs images now, as the cache's own triggers do.
    func recaptureForCurrentConsumers() async
}

extension MenuBarItemImageCache: DisplayChangeImageCache {
    func recaptureForCurrentConsumers() async {
        // A display change can explain a capture that came back empty.
        retryExhaustedInitialPreviews(reason: "display configuration changed")
        await refreshVisibleConsumersOrPrewarmLayoutCache(allowBackgroundCapture: hasBackgroundCaptureDemand())
    }
}

extension MenuBarDisplayChangeEffects {
    func recaptureImages() async {
        await imageCache.recaptureForCurrentConsumers()
    }
}
