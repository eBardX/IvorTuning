// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct PitchProtocolTests {
}

// MARK: -

extension PitchProtocolTests {
    @Test
    func formatted_frequency() {
        let value: any PitchProtocol = Fixtures.a4

        #expect(value.formatted() == Fixtures.a4.formatted())
    }

    @Test
    func formatted_noteNumber() throws {
        let note = try #require(NoteNumber(uintValue: 69))
        let value: any PitchProtocol = note

        #expect(value.formatted() == note.formatted())
    }

    @Test
    func formatted_pitch() {
        let value: any PitchProtocol = Pitch.a4

        #expect(value.formatted() == Pitch.a4.formatted())
    }

    @Test
    func formatted_unrecognizedType_fallsBackToDescription() {
        let value: any PitchProtocol = StubPitch()

        #expect(value.formatted() == AttributedString("\(value)"))
    }
}
