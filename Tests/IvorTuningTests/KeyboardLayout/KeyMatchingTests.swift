// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers

struct KeyMatchingTests {
}

// MARK: -

extension KeyMatchingTests {
    @Test
    func codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in [KeyMatching.nearest, .within(Ratio(cents: 5)), .within(.unison)] {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(KeyMatching.self, from: data)

            #expect(decoded == value)
        }
    }

    @Test
    func equality() {
        #expect(KeyMatching.nearest == .nearest)
        #expect(KeyMatching.within(Ratio(cents: 5)) == .within(Ratio(cents: 5)))
        #expect(KeyMatching.within(Ratio(cents: 5)) != .within(Ratio(cents: 6)))
        #expect(KeyMatching.nearest != .within(.unison))
    }
}
