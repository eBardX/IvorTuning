// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing

struct PerfectFifthsTests {
}

// MARK: -

extension PerfectFifthsTests {
    @Test
    func fifths_failure() {
        #expect(PerfectFifths.fifths(for: .augmented8) == nil)
        #expect(PerfectFifths.fifths(for: .diminished11) == nil)
        #expect(PerfectFifths.fifths(for: .major10) == nil)
        #expect(PerfectFifths.fifths(for: .minor13) == nil)
        #expect(PerfectFifths.fifths(for: .perfect12) == nil)
    }

    @Test
    func fifths_success1() {
        #expect(PerfectFifths.fifths(for: .augmented2) == 9)
        #expect(PerfectFifths.fifths(for: .augmented4) == 6)
        #expect(PerfectFifths.fifths(for: .diminished3) == -10)
        #expect(PerfectFifths.fifths(for: .diminished7) == -9)
        #expect(PerfectFifths.fifths(for: .diminished8) == -7)
        #expect(PerfectFifths.fifths(for: .major2) == 2)
        #expect(PerfectFifths.fifths(for: .major6) == 3)
        #expect(PerfectFifths.fifths(for: .minor6) == -4)
        #expect(PerfectFifths.fifths(for: .minor7) == -2)
        #expect(PerfectFifths.fifths(for: .perfect5) == 1)
        #expect(PerfectFifths.fifths(for: .perfect1) == PerfectFifths.fifths(for: .perfect8))
    }

    @Test
    func fifths_success2() {
        #expect(PerfectFifths.fifths(for: .fDoubleFlat) == -14)
        #expect(PerfectFifths.fifths(for: .fFlat) == -7)
        #expect(PerfectFifths.fifths(for: .c) == 1)
        #expect(PerfectFifths.fifths(for: .bSharp) == 13)
        #expect(PerfectFifths.fifths(for: .bDoubleSharp) == 20)
    }

    @Test
    func interval_failure() {
        #expect(PerfectFifths.interval(for: -50) == nil)
        #expect(PerfectFifths.interval(for: -34) == nil)
        #expect(PerfectFifths.interval(for: 34) == nil)
        #expect(PerfectFifths.interval(for: 50) == nil)
    }

    @Test
    func interval_success() {
        #expect(PerfectFifths.interval(for: -12) == .diminished2)
        #expect(PerfectFifths.interval(for: -9) == .diminished7)
        #expect(PerfectFifths.interval(for: -6) == .diminished5)
        #expect(PerfectFifths.interval(for: -3) == .minor3)
        #expect(PerfectFifths.interval(for: 0) == .perfect1)
        #expect(PerfectFifths.interval(for: 2) == .major2)
        #expect(PerfectFifths.interval(for: 5) == .major7)
        #expect(PerfectFifths.interval(for: 8) == .augmented5)
        #expect(PerfectFifths.interval(for: 11) == .augmented3)
    }

    @Test
    func pitchClass_failure() {
        #expect(PerfectFifths.pitchClass(for: -50) == nil)
        #expect(PerfectFifths.pitchClass(for: -15) == nil)
        #expect(PerfectFifths.pitchClass(for: 21) == nil)
        #expect(PerfectFifths.pitchClass(for: 50) == nil)
    }

    @Test
    func pitchClass_success() {
        #expect(PerfectFifths.pitchClass(for: -14) == .fDoubleFlat)
        #expect(PerfectFifths.pitchClass(for: -7) == .fFlat)
        #expect(PerfectFifths.pitchClass(for: 1) == .c)
        #expect(PerfectFifths.pitchClass(for: 13) == .bSharp)
        #expect(PerfectFifths.pitchClass(for: 20) == .bDoubleSharp)
    }
}
