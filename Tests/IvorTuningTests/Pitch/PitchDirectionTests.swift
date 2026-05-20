// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct PitchDirectionTests {
}

// MARK: -

extension PitchDirectionTests {
    @Test
    func codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in [PitchDirection.ascending, .descending, .same] {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(PitchDirection.self, from: data)

            #expect(decoded == value)
        }
    }

    @Test
    func distinctness() {
        #expect(PitchDirection.ascending != .descending)
        #expect(PitchDirection.ascending != .same)
        #expect(PitchDirection.descending != .same)
    }
}
