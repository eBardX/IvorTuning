// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct IntervalProtocolTests {
}

// MARK: -

extension IntervalProtocolTests {
    @Test
    func formatted_interval() {
        let value: any IntervalProtocol = Interval.perfect5

        #expect(value.formatted() == Interval.perfect5.formatted())
    }

    @Test
    func formatted_noteDistance() throws {
        let distance = try #require(NoteDistance(uintValue: 7))
        let value: any IntervalProtocol = distance

        #expect(value.formatted() == distance.formatted())
    }

    @Test
    func formatted_ratio() {
        let value: any IntervalProtocol = Ratio.octave

        #expect(value.formatted() == Ratio.octave.formatted())
    }

    @Test
    func formatted_unrecognizedType_fallsBackToDescription() {
        let value: any IntervalProtocol = StubInterval()

        #expect(value.formatted() == AttributedString("\(value)"))
    }
}
