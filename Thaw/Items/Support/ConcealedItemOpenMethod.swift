//
//  ConcealedItemOpenMethod.swift
//  Project: Thaw
//
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import CoreGraphics

/// Apps differ in which concealed-menu methods they answer.
/// Moving beside Thaw is unsafe: the agent refuses the concealed move back, stranding the item.
nonisolated enum ConcealedItemOpenMethod: String, CaseIterable, Sendable {
    /// Accessibility press on the parked item. Nothing appears in the bar.
    case pressInPlace
    /// Reveal the item where it sits and click it there, pressing it through
    /// accessibility first when the owner takes that.
    case revealInPlace
    /// Reveal the item where it sits and post a real click, for owners that
    /// accept an accessibility press and do nothing with it.
    case clickInPlace
    /// AXShowMenu on the parked item, the menu a right click opens. Right clicks only.
    case showMenuInPlace

    /// Whether the method activates the item through an accessibility press.
    /// An owner that ignores one press ignores the other.
    var pressesThroughAccessibility: Bool {
        self == .pressInPlace || self == .revealInPlace
    }

    /// The learned method first, then the cheapest. Right clicks skip press, which opens the default action;
    /// showInMenuBar reveals first.
    ///
    /// unverified holds the methods that recently reached the owner without a
    /// visible reaction. They go last, so a repeated request tries something
    /// else instead of repeating an activation that may have toggled the item.
    static func openMethodOrder(
        for mouseButton: CGMouseButton,
        learned: ConcealedItemOpenMethod?,
        showInMenuBar: Bool = false,
        unverified: Set<ConcealedItemOpenMethod> = []
    ) -> [ConcealedItemOpenMethod] {
        if mouseButton == .right {
            return showInMenuBar ? [.revealInPlace] : [.showMenuInPlace, .revealInPlace]
        }
        let preferred: [ConcealedItemOpenMethod]
        if showInMenuBar {
            preferred = [.revealInPlace, .clickInPlace, .pressInPlace]
        } else {
            let candidates: [ConcealedItemOpenMethod] = [.pressInPlace, .revealInPlace, .clickInPlace]
            // A right click's method would open the wrong menu on a left click.
            if let learned, learned != .showMenuInPlace {
                preferred = [learned] + candidates.filter { $0 != learned }
            } else {
                preferred = candidates
            }
        }
        let demotesPresses = unverified.contains { $0.pressesThroughAccessibility }
        let isDemoted: (ConcealedItemOpenMethod) -> Bool = { method in
            unverified.contains(method) || (demotesPresses && method.pressesThroughAccessibility)
        }
        let promoted = preferred.filter { !isDemoted($0) }
        // Everything was tried: start over rather than refuse the request.
        guard !promoted.isEmpty else { return preferred }
        return promoted + preferred.filter(isDemoted)
    }
}

/// What one open method achieved.
nonisolated enum ConcealedItemOpenAttempt: Equatable, Sendable {
    /// Nothing reached the owner, so the next method may try.
    case notDelivered
    /// The owner took the activation but was not seen doing anything. It may
    /// still have acted (a toggle flips a glyph invisibly), so the request
    /// must not activate the item again.
    case deliveredUnobserved
    /// The owner was seen reacting.
    case reacted
}
