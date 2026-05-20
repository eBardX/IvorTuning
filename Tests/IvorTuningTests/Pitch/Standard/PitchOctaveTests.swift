// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PitchOctaveTests {
}

// MARK: -

extension PitchOctaveTests {

    @Test
    func init_invalid() {
        #expect(Pitch.Octave(intValue: -2) == nil)
        #expect(Pitch.Octave(intValue: 10) == nil)
    }

    @Test
    func init_valid() {
        #expect(Pitch.Octave(intValue: -1) != nil)
        #expect(Pitch.Octave(intValue: 0) != nil)
        #expect(Pitch.Octave(intValue: 4) != nil)
        #expect(Pitch.Octave(intValue: 9) != nil)
    }

    @Test
    func intValue() {
        #expect(Pitch.Octave(intValue: 4)?.intValue == 4)
    }

    @Test
    func isValid() {
        #expect(Pitch.Octave.isValid(-1))
        #expect(Pitch.Octave.isValid(9))
        #expect(!Pitch.Octave.isValid(-2))
        #expect(!Pitch.Octave.isValid(10))
    }
}
