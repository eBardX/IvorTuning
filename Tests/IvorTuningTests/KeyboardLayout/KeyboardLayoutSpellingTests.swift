// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct KeyboardLayoutSpellingTests {
}

// MARK: -

extension KeyboardLayoutSpellingTests {
    @Test
    func hasTwelveKeysPerOctave() throws {
        let raw = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                     equivalenceRatio: .octave,
                                     referenceFrequency: 440)
        let rawTritave = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                            equivalenceRatio: .tritave,
                                            referenceFrequency: 440)
        let degrees = try KeyboardLayout(degrees: Array(0..<12))
        let frequencies = try KeyboardLayout(frequencies: [Frequency?](repeating: 440, count: 128))

        #expect(KeyboardLayout.piano.hasTwelveKeysPerOctave(period: nil))
        #expect(raw.hasTwelveKeysPerOctave(period: nil))
        #expect(!rawTritave.hasTwelveKeysPerOctave(period: nil))
        #expect(degrees.hasTwelveKeysPerOctave(period: .octave))
        #expect(degrees.hasTwelveKeysPerOctave(period: nil))
        #expect(!degrees.hasTwelveKeysPerOctave(period: .tritave))
        #expect(!KeyboardLayout.bohlenPierce.hasTwelveKeysPerOctave(period: .tritave))
        #expect(!frequencies.hasTwelveKeysPerOctave(period: nil))
    }

    @Test
    func mappedKeys() throws {
        let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])
        let keys = lambda.mappedKeys

        #expect(keys.count == 128)
        #expect(keys[60] && !keys[61] && keys[62])
        #expect(!keys[49] && !keys[73])       // the C♯ slot, a period down and up
        #expect(KeyboardLayout.piano.mappedKeys.allSatisfy { $0 })
    }
}
