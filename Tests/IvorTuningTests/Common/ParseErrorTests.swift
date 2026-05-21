// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiTools

struct ParseErrorTests {
}

// MARK: -

extension ParseErrorTests {
    @Test
    func category() {
        #expect(ParseError.invalidInterval("x").category?.stringValue == "IvorTuning")
    }

    @Test
    func message_invalidInterval() {
        #expect(ParseError.invalidInterval("bad").message == "Invalid interval: \u{2018}bad\u{2019}")
    }

    @Test
    func message_invalidIntervalQuality() {
        #expect(ParseError.invalidIntervalQuality("q").message == "Invalid interval quality: \u{2018}q\u{2019}")
    }

    @Test
    func message_invalidPitch() {
        #expect(ParseError.invalidPitch("x").message == "Invalid pitch: \u{2018}x\u{2019}")
    }

    @Test
    func message_invalidPitchAccidental() {
        #expect(ParseError.invalidPitchAccidental("acc").message == "Invalid pitch accidental: \u{2018}acc\u{2019}")
    }

    @Test
    func message_invalidPitchClass() {
        #expect(ParseError.invalidPitchClass("c").message == "Invalid pitch class: \u{2018}c\u{2019}")
    }

    @Test
    func message_invalidPitchLetter() {
        #expect(ParseError.invalidPitchLetter("h").message == "Invalid pitch letter: \u{2018}h\u{2019}")
    }

    @Test
    func message_invalidPitchNotation() {
        #expect(ParseError.invalidPitchNotation("midi").message == "Invalid pitch notation: \u{2018}midi\u{2019}")
    }
}
