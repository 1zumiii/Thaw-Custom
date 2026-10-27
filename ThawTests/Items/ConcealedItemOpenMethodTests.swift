//
//  ConcealedItemOpenMethodTests.swift
//  Project: Thaw
//
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import Testing
@testable import Thaw

/// Pins the order ConcealedItemOpenMethod.openMethodOrder(for:learned:showInMenuBar:) tries
/// the ways of opening a concealed item.
@MainActor
struct ConcealedItemOpenMethodTests {
    @Test("with nothing learned, a left click tries the cheapest method first")
    func defaultLeftOrder() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: nil)
                == [.pressInPlace, .revealInPlace, .clickInPlace]
        )
    }

    @Test("the remembered method goes first and the rest keep their order")
    func learnedMethodLeads() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: .revealInPlace)
                == [.revealInPlace, .pressInPlace, .clickInPlace]
        )
    }

    @Test("a right click opens its menu in place first and never tries the press")
    func rightClickSkipsPress() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .right, learned: nil)
                == [.showMenuInPlace, .revealInPlace]
        )
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .right, learned: .pressInPlace)
                == [.showMenuInPlace, .revealInPlace]
        )
    }

    @Test("a right click's method is never tried first on a left click")
    func leftClickIgnoresLearnedShowMenu() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: .showMenuInPlace)
                == [.pressInPlace, .revealInPlace]
        )
    }

    @Test("showing items in the menu bar reveals first and keeps the press as a fallback")
    func showInMenuBarRevealsFirst() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: nil, showInMenuBar: true)
                == [.revealInPlace, .clickInPlace, .pressInPlace]
        )
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: .pressInPlace, showInMenuBar: true)
                == [.revealInPlace, .clickInPlace, .pressInPlace]
        )
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .right, learned: nil, showInMenuBar: true)
                == [.revealInPlace]
        )
    }

    @Test("an unverified press sends the next request to a real click, not another press")
    func unverifiedPressGoesToClick() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(for: .left, learned: nil, unverified: [.pressInPlace])
                == [.clickInPlace, .pressInPlace, .revealInPlace]
        )
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(
                for: .left, learned: .revealInPlace, showInMenuBar: true, unverified: [.revealInPlace]
            ) == [.clickInPlace, .revealInPlace, .pressInPlace]
        )
    }

    @Test("once every method went unverified the order starts over")
    func allUnverifiedStartsOver() {
        #expect(
            ConcealedItemOpenMethod.openMethodOrder(
                for: .left, learned: nil, unverified: [.pressInPlace, .clickInPlace]
            ) == [.pressInPlace, .revealInPlace, .clickInPlace]
        )
    }
}
