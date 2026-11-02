// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardLayoutDefinitionTests {
}

// MARK: -

extension KeyboardLayoutDefinitionTests {
    @Test
    func codable_degrees() throws {
        let original = KeyboardLayout.Definition.degrees([0, nil, 2],
                                                         anchorNote: 48,
                                                         referenceNote: 50)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyboardLayout.Definition.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_frequencies() throws {
        let original = KeyboardLayout.Definition.frequencies([440, nil, 880])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyboardLayout.Definition.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_pitchClasses() throws {
        let original = KeyboardLayout.Definition.pitchClasses([.c, nil, .d],
                                                              anchorNote: 60,
                                                              anchorOctave: 4)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyboardLayout.Definition.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_ratios() throws {
        let original = KeyboardLayout.Definition.ratios([.unison, nil, Ratio(cents: 200)],
                                                        equivalenceRatio: .octave,
                                                        anchorNote: 60,
                                                        referenceNote: 69,
                                                        referenceFrequency: 440)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyboardLayout.Definition.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func equality() {
        let degrees = KeyboardLayout.Definition.degrees([0, 1],
                                                        anchorNote: 60,
                                                        referenceNote: 60)

        #expect(degrees == .degrees([0, 1],
                                    anchorNote: 60,
                                    referenceNote: 60))
        #expect(degrees != .degrees([0, 1],
                                    anchorNote: 60,
                                    referenceNote: 61))
        #expect(degrees != .degrees([0, nil],
                                    anchorNote: 60,
                                    referenceNote: 60))
        #expect(KeyboardLayout.Definition.frequencies([440]) != .frequencies([441]))
    }

    @Test
    func hashable() {
        let definitions: Set<KeyboardLayout.Definition> = [.frequencies([440]),
                                                           .frequencies([440]),
                                                           .frequencies([880]),
                                                           .pitchClasses([.c],
                                                                         anchorNote: 60,
                                                                         anchorOctave: 4)]

        #expect(definitions.count == 3)
    }

    @Test
    func layoutDefinition_matchesInitializerArguments() throws {
        let layout = try KeyboardLayout(pitchClasses: [.a, .bFlat, .b],
                                        anchorNote: 57,
                                        anchorOctave: 3)

        #expect(layout.definition == .pitchClasses([.a, .bFlat, .b],
                                                   anchorNote: 57,
                                                   anchorOctave: 3))
    }
}
