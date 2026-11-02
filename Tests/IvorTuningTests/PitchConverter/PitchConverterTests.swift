// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiTools

struct PitchConverterTests {
}

// MARK: -

extension PitchConverterTests {
    @Test
    func convertSequence_default_mapsEachPitch() {
        let converter = StandardToKeyboardPitchConverter()

        #expect(converter.convert(["C4", "A4", "Cb-1"]) == [60, 69, nil])
    }

    @Test
    func convertSequence_genericCall_reachesSpellingOverride() {
        // Called through `some PitchConverter`, the sequence form must still use the speller’s
        // context, not the per-note default.
        let eMajor: [NoteNumber] = [64, 66, 68, 69, 71, 73, 75, 76]

        #expect(convertGenerically(KeyboardToStandardPitchConverter(), eMajor)[6] == "D#5")
    }
}
