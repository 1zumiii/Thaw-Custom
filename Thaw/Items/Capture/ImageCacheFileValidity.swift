//
//  ImageCacheFileValidity.swift
//  Project: Thaw
//
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import Foundation

/// Whether a saved image cache file may be read.
///
/// Thaw-Custom keeps the file across Thaw builds: a new build would otherwise
/// reveal every hidden item again for a picture. A format change still drops
/// it, and an entry whose app was updated is dropped on its own (ownerVersion).
nonisolated enum ImageCacheFileValidity {
    /// The build that writes and reads the file, from the app bundle.
    static var appBuild: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    /// The builds are recorded for diagnostics only; the format decides.
    static func isCurrent(fileVersion: Int?, fileBuild _: String?, cacheVersion: Int, appBuild _: String?) -> Bool {
        fileVersion == cacheVersion
    }
}
