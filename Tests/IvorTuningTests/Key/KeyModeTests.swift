// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing

struct KeyModeTests {
}

// MARK: -

extension KeyModeTests {

    @Test
    func codable() throws {
        for mode in Key.Mode.allCases {
            let data = try JSONEncoder().encode(mode)

            #expect(String(bytes: data, encoding: .utf8) == "\"\(mode.rawValue)\"")
            #expect(try JSONDecoder().decode(Key.Mode.self, from: data) == mode)
        }

        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Mode.self, from: Data(#""aeolian""#.utf8)) }
    }

    @Test
    func diatonicIndex() {
        #expect(Key.Mode.lydian.diatonicIndex == 0)
        #expect(Key.Mode.major.diatonicIndex == 1)
        #expect(Key.Mode.mixolydian.diatonicIndex == 2)
        #expect(Key.Mode.dorian.diatonicIndex == 3)
        #expect(Key.Mode.minor.diatonicIndex == 4)
        #expect(Key.Mode.phrygian.diatonicIndex == 5)
        #expect(Key.Mode.locrian.diatonicIndex == 6)
    }

    @Test
    func init_name() {
        #expect(Key.Mode(name: "major") == .major)
        #expect(Key.Mode(name: "Minor") == .minor)
        #expect(Key.Mode(name: "DORIAN") == .dorian)
        #expect(Key.Mode(name: "ionian") == .major)
        #expect(Key.Mode(name: "Aeolian") == .minor)

        for mode in Key.Mode.allCases {
            #expect(Key.Mode(name: mode.rawValue) == mode)
        }
    }

    @Test
    func init_name_invalid() {
        #expect(Key.Mode(name: "none") == nil)
        #expect(Key.Mode(name: "") == nil)
        #expect(Key.Mode(name: "maj") == nil)
    }

    @Test
    func init_rawValue() {
        #expect(Key.Mode(rawValue: "aeolian") == nil)
        #expect(Key.Mode(rawValue: "ionian") == nil)
        #expect(Key.Mode(rawValue: "Minor") == nil)
        #expect(Key.Mode(rawValue: "minor") == .minor)
    }

    @Test
    func inverted() {
        #expect(Key.Mode.major.inverted == .phrygian)
        #expect(Key.Mode.minor.inverted == .mixolydian)
        #expect(Key.Mode.lydian.inverted == .locrian)
        #expect(Key.Mode.dorian.inverted == .dorian)

        for mode in Key.Mode.allCases {
            #expect(mode.inverted.inverted == mode)
            #expect(mode.inverted.diatonicIndex == 6 - mode.diatonicIndex)
        }
    }
}
