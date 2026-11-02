// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiTools

struct KeyboardLayoutCommonTests {
}

// MARK: -

extension KeyboardLayoutCommonTests {
    @Test
    func bohlenPierce() {
        #expect(KeyboardLayout.bohlenPierce.definition == .degrees(Array(0..<13),
                                                                   anchorNote: 60,
                                                                   referenceNote: 69))
        #expect(KeyboardLayout.bohlenPierce.keysPerPeriod == 13)
    }

    @Test
    func piano() {
        #expect(KeyboardLayout.piano.definition == .pitchClasses([.c,
                                                                  .cSharp,
                                                                  .d,
                                                                  .eFlat,
                                                                  .e,
                                                                  .f,
                                                                  .fSharp,
                                                                  .g,
                                                                  .gSharp,
                                                                  .a,
                                                                  .bFlat,
                                                                  .b],
                                                                 anchorNote: 60,
                                                                 anchorOctave: 4))
        #expect(KeyboardLayout.piano.keysPerPeriod == 12)
    }
}
