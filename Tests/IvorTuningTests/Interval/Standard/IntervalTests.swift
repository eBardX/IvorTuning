// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

// swiftlint:disable file_length

struct IntervalTests {
}

// MARK: -

extension IntervalTests {
    @Test
    func adding_failure() {
        // Fifth-chain sum overflows the ±33 range
        #expect(Interval.quadruplyAugmented7.adding(.augmented1) == nil)
        #expect(Interval.quadruplyAugmented7.adding(.perfect5) == nil)
        #expect(Interval.quadruplyDiminished2.adding(.diminished2) == nil)
        #expect(Interval.quadruplyDiminished2.adding(.diminished5) == nil)
    }

    @Test
    func adding_failure_d2() {
        #expect(Interval.diminished2.adding(.diminished2) == .triplyDiminished3)
        #expect(Interval.diminished2.adding(.minor2) == .doublyDiminished3)
        #expect(Interval.diminished2.adding(.diminished3) == .triplyDiminished4)
        #expect(Interval.diminished2.adding(.minor3) == .doublyDiminished4)
        #expect(Interval.diminished2.adding(.diminished4) == .triplyDiminished5)
        #expect(Interval.diminished2.adding(.perfect4) == .doublyDiminished5)
        #expect(Interval.diminished2.adding(.diminished5) == .doublyDiminished6)
        #expect(Interval.diminished2.adding(.diminished6) == .triplyDiminished7)
        #expect(Interval.diminished2.adding(.minor6) == .doublyDiminished7)
        #expect(Interval.diminished2.adding(.diminished7) == .triplyDiminished8)
        #expect(Interval.diminished2.adding(.minor7) == .doublyDiminished8)
        #expect(Interval.diminished2.adding(.diminished8) == .doublyDiminished9)
    }

    @Test
    func adding_success_A1() {
        #expect(Interval.augmented1.adding(.augmented1) == .doublyAugmented1)
        #expect(Interval.augmented1.adding(.augmented2) == .doublyAugmented2)
        #expect(Interval.augmented1.adding(.augmented3) == .doublyAugmented3)
        #expect(Interval.augmented1.adding(.augmented4) == .doublyAugmented4)
        #expect(Interval.augmented1.adding(.augmented5) == .doublyAugmented5)
        #expect(Interval.augmented1.adding(.augmented6) == .doublyAugmented6)
        #expect(Interval.augmented1.adding(.augmented7) == .doublyAugmented7)
    }

    @Test
    func adding_success_M2() {
        #expect(Interval.major2.adding(.perfect1) == .major2)
        #expect(Interval.major2.adding(.minor2) == .minor3)
        #expect(Interval.major2.adding(.major2) == .major3)
        #expect(Interval.major2.adding(.minor3) == .perfect4)
        #expect(Interval.major2.adding(.major3) == .augmented4)
        #expect(Interval.major2.adding(.perfect4) == .perfect5)
        #expect(Interval.major2.adding(.perfect5) == .major6)
        #expect(Interval.major2.adding(.minor6) == .minor7)
        #expect(Interval.major2.adding(.major6) == .major7)
        #expect(Interval.major2.adding(.minor7) == .perfect8)
        #expect(Interval.major2.adding(.major7) == .augmented8)
        #expect(Interval.major2.adding(.perfect8) == .major9)
    }

    @Test
    func adding_success_M3() {
        #expect(Interval.major3.adding(.perfect1) == .major3)
        #expect(Interval.major3.adding(.minor2) == .perfect4)
        #expect(Interval.major3.adding(.major2) == .augmented4)
        #expect(Interval.major3.adding(.minor3) == .perfect5)
        #expect(Interval.major3.adding(.major3) == .augmented5)
        #expect(Interval.major3.adding(.perfect4) == .major6)
        #expect(Interval.major3.adding(.perfect5) == .major7)
        #expect(Interval.major3.adding(.minor6) == .perfect8)
        #expect(Interval.major3.adding(.major6) == .augmented8)
        #expect(Interval.major3.adding(.minor7) == .major9)
        #expect(Interval.major3.adding(.major7) == .augmented9)
        #expect(Interval.major3.adding(.perfect8) == .major10)
    }

    @Test
    func adding_success_M6() {
        #expect(Interval.major6.adding(.perfect1) == .major6)
        #expect(Interval.major6.adding(.minor2) == .minor7)
        #expect(Interval.major6.adding(.major2) == .major7)
        #expect(Interval.major6.adding(.minor3) == .perfect8)
        #expect(Interval.major6.adding(.major3) == .augmented8)
        #expect(Interval.major6.adding(.perfect4) == .major9)
        #expect(Interval.major6.adding(.perfect5) == .major10)
        #expect(Interval.major6.adding(.minor6) == .perfect11)
        #expect(Interval.major6.adding(.major6) == .augmented11)
        #expect(Interval.major6.adding(.minor7) == .perfect12)
        #expect(Interval.major6.adding(.major7) == .augmented12)
        #expect(Interval.major6.adding(.perfect8) == .major13)
    }

    @Test
    func adding_success_M7() {
        #expect(Interval.major7.adding(.perfect1) == .major7)
        #expect(Interval.major7.adding(.minor2) == .perfect8)
        #expect(Interval.major7.adding(.major2) == .augmented8)
        #expect(Interval.major7.adding(.minor3) == .major9)
        #expect(Interval.major7.adding(.major3) == .augmented9)
        #expect(Interval.major7.adding(.perfect4) == .major10)
        #expect(Interval.major7.adding(.perfect5) == .augmented11)
        #expect(Interval.major7.adding(.minor6) == .perfect12)
        #expect(Interval.major7.adding(.major6) == .augmented12)
        #expect(Interval.major7.adding(.minor7) == .major13)
        #expect(Interval.major7.adding(.major7) == .augmented13)
        #expect(Interval.major7.adding(.perfect8) == .major14)
    }

    @Test
    func adding_success_P1() {
        #expect(Interval.perfect1.adding(.perfect1) == .perfect1)
        #expect(Interval.perfect1.adding(.minor2) == .minor2)
        #expect(Interval.perfect1.adding(.major2) == .major2)
        #expect(Interval.perfect1.adding(.minor3) == .minor3)
        #expect(Interval.perfect1.adding(.major3) == .major3)
        #expect(Interval.perfect1.adding(.perfect4) == .perfect4)
        #expect(Interval.perfect1.adding(.perfect5) == .perfect5)
        #expect(Interval.perfect1.adding(.minor6) == .minor6)
        #expect(Interval.perfect1.adding(.major6) == .major6)
        #expect(Interval.perfect1.adding(.minor7) == .minor7)
        #expect(Interval.perfect1.adding(.major7) == .major7)
        #expect(Interval.perfect1.adding(.perfect8) == .perfect8)
    }

    @Test
    func adding_success_P4() {
        #expect(Interval.perfect4.adding(.perfect1) == .perfect4)
        #expect(Interval.perfect4.adding(.minor2) == .diminished5)
        #expect(Interval.perfect4.adding(.major2) == .perfect5)
        #expect(Interval.perfect4.adding(.minor3) == .minor6)
        #expect(Interval.perfect4.adding(.major3) == .major6)
        #expect(Interval.perfect4.adding(.perfect4) == .minor7)
        #expect(Interval.perfect4.adding(.perfect5) == .perfect8)
        #expect(Interval.perfect4.adding(.minor6) == .minor9)
        #expect(Interval.perfect4.adding(.major6) == .major9)
        #expect(Interval.perfect4.adding(.minor7) == .minor10)
        #expect(Interval.perfect4.adding(.major7) == .major10)
        #expect(Interval.perfect4.adding(.perfect8) == .perfect11)
    }

    @Test
    func adding_success_P5() {
        #expect(Interval.perfect5.adding(.perfect1) == .perfect5)
        #expect(Interval.perfect5.adding(.minor2) == .minor6)
        #expect(Interval.perfect5.adding(.major2) == .major6)
        #expect(Interval.perfect5.adding(.minor3) == .minor7)
        #expect(Interval.perfect5.adding(.major3) == .major7)
        #expect(Interval.perfect5.adding(.perfect4) == .perfect8)
        #expect(Interval.perfect5.adding(.perfect5) == .major9)
        #expect(Interval.perfect5.adding(.minor6) == .minor10)
        #expect(Interval.perfect5.adding(.major6) == .major10)
        #expect(Interval.perfect5.adding(.minor7) == .perfect11)
        #expect(Interval.perfect5.adding(.major7) == .augmented11)
        #expect(Interval.perfect5.adding(.perfect8) == .perfect12)
    }

    @Test
    func adding_success_P8() {
        #expect(Interval.perfect8.adding(.perfect1) == .perfect8)
        #expect(Interval.perfect8.adding(.minor2) == .minor9)
        #expect(Interval.perfect8.adding(.major2) == .major9)
        #expect(Interval.perfect8.adding(.minor3) == .minor10)
        #expect(Interval.perfect8.adding(.major3) == .major10)
        #expect(Interval.perfect8.adding(.perfect4) == .perfect11)
        #expect(Interval.perfect8.adding(.perfect5) == .perfect12)
        #expect(Interval.perfect8.adding(.minor6) == .minor13)
        #expect(Interval.perfect8.adding(.major6) == .major13)
        #expect(Interval.perfect8.adding(.minor7) == .minor14)
        #expect(Interval.perfect8.adding(.major7) == .major14)
        #expect(Interval.perfect8.adding(.perfect8) == .perfect15)
    }

    @Test
    func adding_success_m2() {
        #expect(Interval.minor2.adding(.perfect1) == .minor2)
        #expect(Interval.minor2.adding(.minor2) == .diminished3)
        #expect(Interval.minor2.adding(.major2) == .minor3)
        #expect(Interval.minor2.adding(.minor3) == .diminished4)
        #expect(Interval.minor2.adding(.major3) == .perfect4)
        #expect(Interval.minor2.adding(.perfect4) == .diminished5)
        #expect(Interval.minor2.adding(.perfect5) == .minor6)
        #expect(Interval.minor2.adding(.minor6) == .diminished7)
        #expect(Interval.minor2.adding(.major6) == .minor7)
        #expect(Interval.minor2.adding(.minor7) == .diminished8)
        #expect(Interval.minor2.adding(.major7) == .perfect8)
        #expect(Interval.minor2.adding(.perfect8) == .minor9)
    }

    @Test
    func adding_success_m3() {
        #expect(Interval.minor3.adding(.perfect1) == .minor3)
        #expect(Interval.minor3.adding(.minor2) == .diminished4)
        #expect(Interval.minor3.adding(.major2) == .perfect4)
        #expect(Interval.minor3.adding(.minor3) == .diminished5)
        #expect(Interval.minor3.adding(.major3) == .perfect5)
        #expect(Interval.minor3.adding(.perfect4) == .minor6)
        #expect(Interval.minor3.adding(.perfect5) == .minor7)
        #expect(Interval.minor3.adding(.minor6) == .diminished8)
        #expect(Interval.minor3.adding(.major6) == .perfect8)
        #expect(Interval.minor3.adding(.minor7) == .minor9)
        #expect(Interval.minor3.adding(.major7) == .major9)
        #expect(Interval.minor3.adding(.perfect8) == .minor10)
    }

    @Test
    func adding_success_m6() {
        #expect(Interval.minor6.adding(.perfect1) == .minor6)
        #expect(Interval.minor6.adding(.minor2) == .diminished7)
        #expect(Interval.minor6.adding(.major2) == .minor7)
        #expect(Interval.minor6.adding(.minor3) == .diminished8)
        #expect(Interval.minor6.adding(.major3) == .perfect8)
        #expect(Interval.minor6.adding(.perfect4) == .minor9)
        #expect(Interval.minor6.adding(.perfect5) == .minor10)
        #expect(Interval.minor6.adding(.minor6) == .diminished11)
        #expect(Interval.minor6.adding(.major6) == .perfect11)
        #expect(Interval.minor6.adding(.minor7) == .diminished12)
        #expect(Interval.minor6.adding(.major7) == .perfect12)
        #expect(Interval.minor6.adding(.perfect8) == .minor13)
    }

    @Test
    func adding_success_m7() {
        #expect(Interval.minor7.adding(.perfect1) == .minor7)
        #expect(Interval.minor7.adding(.minor2) == .diminished8)
        #expect(Interval.minor7.adding(.major2) == .perfect8)
        #expect(Interval.minor7.adding(.minor3) == .minor9)
        #expect(Interval.minor7.adding(.major3) == .major9)
        #expect(Interval.minor7.adding(.perfect4) == .minor10)
        #expect(Interval.minor7.adding(.perfect5) == .perfect11)
        #expect(Interval.minor7.adding(.minor6) == .diminished12)
        #expect(Interval.minor7.adding(.major6) == .perfect12)
        #expect(Interval.minor7.adding(.minor7) == .minor13)
        #expect(Interval.minor7.adding(.major7) == .major13)
        #expect(Interval.minor7.adding(.perfect8) == .minor14)
    }

    @Test
    func description() {
        #expect(Interval.perfect1.description == "P1")
        #expect(Interval.augmented1.description == "A1")

        #expect(Interval.diminished2.description == "d2")
        #expect(Interval.minor2.description == "m2")
        #expect(Interval.major2.description == "M2")
        #expect(Interval.augmented2.description == "A2")

        #expect(Interval.diminished3.description == "d3")
        #expect(Interval.minor3.description == "m3")
        #expect(Interval.major3.description == "M3")
        #expect(Interval.augmented3.description == "A3")

        #expect(Interval.diminished4.description == "d4")
        #expect(Interval.perfect4.description == "P4")
        #expect(Interval.augmented4.description == "A4")

        #expect(Interval.diminished5.description == "d5")
        #expect(Interval.perfect5.description == "P5")
        #expect(Interval.augmented5.description == "A5")

        #expect(Interval.diminished6.description == "d6")
        #expect(Interval.minor6.description == "m6")
        #expect(Interval.major6.description == "M6")
        #expect(Interval.augmented6.description == "A6")

        #expect(Interval.diminished7.description == "d7")
        #expect(Interval.minor7.description == "m7")
        #expect(Interval.major7.description == "M7")
        #expect(Interval.augmented7.description == "A7")

        #expect(Interval.diminished8.description == "d8")
        #expect(Interval.perfect8.description == "P8")
        #expect(Interval.augmented8.description == "A8")

        #expect(Interval.diminished9.description == "d9")
        #expect(Interval.minor9.description == "m9")
        #expect(Interval.major9.description == "M9")
        #expect(Interval.augmented9.description == "A9")

        #expect(Interval.diminished10.description == "d10")
        #expect(Interval.minor10.description == "m10")
        #expect(Interval.major10.description == "M10")
        #expect(Interval.augmented10.description == "A10")

        #expect(Interval.diminished11.description == "d11")
        #expect(Interval.perfect11.description == "P11")
        #expect(Interval.augmented11.description == "A11")

        #expect(Interval.diminished12.description == "d12")
        #expect(Interval.perfect12.description == "P12")
        #expect(Interval.augmented12.description == "A12")

        #expect(Interval.diminished13.description == "d13")
        #expect(Interval.minor13.description == "m13")
        #expect(Interval.major13.description == "M13")
        #expect(Interval.augmented13.description == "A13")

        #expect(Interval.diminished14.description == "d14")
        #expect(Interval.minor14.description == "m14")
        #expect(Interval.major14.description == "M14")
        #expect(Interval.augmented14.description == "A14")

        #expect(Interval.diminished15.description == "d15")
        #expect(Interval.perfect15.description == "P15")
        #expect(Interval.augmented15.description == "A15")
    }

    @Test
    func init_failure() {
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .diminished, size: 1)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .major, size: 4)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .major, size: 18)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .minor, size: 5)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .minor, size: 12)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .perfect, size: 3)
        }
        #expect(throws: Interval.InvalidCombinationError.self) {
            try Interval(quality: .perfect, size: 10)
        }
    }

    @Test
    func init_success() throws {
        _ = try Interval(quality: .augmented, size: 1)
        _ = try Interval(quality: .augmented, size: 8)

        _ = try Interval(quality: .diminished, size: 2)
        _ = try Interval(quality: .diminished, size: 8)

        _ = try Interval(quality: .major, size: 2)
        _ = try Interval(quality: .major, size: 3)
        _ = try Interval(quality: .major, size: 6)
        _ = try Interval(quality: .major, size: 7)
        _ = try Interval(quality: .major, size: 9)

        _ = try Interval(quality: .minor, size: 2)
        _ = try Interval(quality: .minor, size: 3)
        _ = try Interval(quality: .minor, size: 6)
        _ = try Interval(quality: .minor, size: 7)
        _ = try Interval(quality: .minor, size: 9)

        _ = try Interval(quality: .perfect, size: 1)
        _ = try Interval(quality: .perfect, size: 4)
        _ = try Interval(quality: .perfect, size: 5)
        _ = try Interval(quality: .perfect, size: 8)
        _ = try Interval(quality: .perfect, size: 11)
    }

    @Test
    func invert_failure() {
        #expect(Interval.augmented8.inverted() == nil)

        #expect(Interval.diminished9.inverted() == nil)
        #expect(Interval.minor9.inverted() == nil)

        #expect(Interval.major14.inverted() == nil)
        #expect(Interval.augmented14.inverted() == nil)

        #expect(Interval.diminished15.inverted() == nil)
        #expect(Interval.perfect15.inverted() == nil)
        #expect(Interval.augmented15.inverted() == nil)
    }

    @Test
    func invert_success() {
        #expect(Interval.perfect1.inverted() == Interval.perfect8)
        #expect(Interval.augmented1.inverted() == Interval.diminished8)

        #expect(Interval.diminished2.inverted() == Interval.augmented7)
        #expect(Interval.minor2.inverted() == Interval.major7)

        #expect(Interval.major7.inverted() == Interval.minor2)
        #expect(Interval.augmented7.inverted() == Interval.diminished2)

        #expect(Interval.diminished8.inverted() == Interval.augmented1)
        #expect(Interval.perfect8.inverted() == Interval.perfect1)
    }

    @Test
    func isSimple() {
        #expect(Interval.perfect1.isSimple)
        #expect(Interval.augmented1.isSimple)

        #expect(Interval.diminished2.isSimple)
        #expect(Interval.minor2.isSimple)

        #expect(Interval.major7.isSimple)
        #expect(Interval.augmented7.isSimple)

        #expect(Interval.diminished8.isSimple)
        #expect(Interval.perfect8.isSimple)
        #expect(!Interval.augmented8.isSimple)

        #expect(!Interval.diminished9.isSimple)
        #expect(!Interval.minor9.isSimple)
    }

    @Test
    func octaveSpan() {
        #expect(Interval.perfect1.octaveSpan == 0)
        #expect(Interval.augmented1.octaveSpan == 0)

        #expect(Interval.diminished2.octaveSpan == 0)
        #expect(Interval.minor2.octaveSpan == 0)

        #expect(Interval.major7.octaveSpan == 0)
        #expect(Interval.augmented7.octaveSpan == 0)

        #expect(Interval.diminished8.octaveSpan == 1)
        #expect(Interval.perfect8.octaveSpan == 1)
        #expect(Interval.augmented8.octaveSpan == 1)

        #expect(Interval.diminished9.octaveSpan == 1)
        #expect(Interval.minor9.octaveSpan == 1)

        #expect(Interval.diminished15.octaveSpan == 2)
        #expect(Interval.perfect15.octaveSpan == 2)
        #expect(Interval.augmented15.octaveSpan == 2)
    }

    @Test
    func simplify() {
        #expect(Interval.perfect1.simplified() == Interval.perfect1)
        #expect(Interval.augmented1.simplified() == Interval.augmented1)

        #expect(Interval.diminished2.simplified() == Interval.diminished2)
        #expect(Interval.minor2.simplified() == Interval.minor2)

        #expect(Interval.major7.simplified() == Interval.major7)
        #expect(Interval.augmented7.simplified() == Interval.augmented7)

        #expect(Interval.diminished8.simplified() == Interval.diminished8)
        #expect(Interval.perfect8.simplified() == Interval.perfect8)
        #expect(Interval.augmented8.simplified() == Interval.augmented1)

        #expect(Interval.diminished9.simplified() == Interval.diminished2)
        #expect(Interval.minor9.simplified() == Interval.minor2)

        #expect(Interval.major14.simplified() == Interval.major7)
        #expect(Interval.augmented14.simplified() == Interval.augmented7)

        #expect(Interval.diminished15.simplified() == Interval.diminished8)
        #expect(Interval.perfect15.simplified() == Interval.perfect8)
        #expect(Interval.augmented15.simplified() == Interval.augmented1)
    }

    @Test
    func subtracting_failure() {
        // Resulting size would be zero or negative
        #expect(Interval.minor2.subtracting(.minor3) == nil)
        #expect(Interval.perfect1.subtracting(.minor2) == nil)
        #expect(Interval.perfect4.subtracting(.perfect5) == nil)
        // Fifth-chain difference overflows the ±33 range
        #expect(Interval.quadruplyDiminished2.subtracting(.augmented1) == nil)
        #expect(Interval.quadruplyAugmented7.subtracting(.quadruplyDiminished2) == nil)
    }

    @Test
    func subtracting_success_M2() {
        #expect(Interval.major2.subtracting(.perfect1) == .major2)
        #expect(Interval.minor3.subtracting(.minor2) == .major2)
        #expect(Interval.major3.subtracting(.major2) == .major2)
        #expect(Interval.perfect4.subtracting(.minor3) == .major2)
        #expect(Interval.augmented4.subtracting(.major3) == .major2)
        #expect(Interval.perfect5.subtracting(.perfect4) == .major2)
        #expect(Interval.major6.subtracting(.perfect5) == .major2)
        #expect(Interval.minor7.subtracting(.minor6) == .major2)
        #expect(Interval.major7.subtracting(.major6) == .major2)
        #expect(Interval.perfect8.subtracting(.minor7) == .major2)
        #expect(Interval.augmented8.subtracting(.major7) == .major2)
        #expect(Interval.major9.subtracting(.perfect8) == .major2)
    }

    @Test
    func subtracting_success_M3() {
        #expect(Interval.major3.subtracting(.perfect1) == .major3)
        #expect(Interval.perfect4.subtracting(.minor2) == .major3)
        #expect(Interval.augmented4.subtracting(.major2) == .major3)
        #expect(Interval.perfect5.subtracting(.minor3) == .major3)
        #expect(Interval.augmented5.subtracting(.major3) == .major3)
        #expect(Interval.major6.subtracting(.perfect4) == .major3)
        #expect(Interval.major7.subtracting(.perfect5) == .major3)
        #expect(Interval.perfect8.subtracting(.minor6) == .major3)
        #expect(Interval.augmented8.subtracting(.major6) == .major3)
        #expect(Interval.major9.subtracting(.minor7) == .major3)
        #expect(Interval.augmented9.subtracting(.major7) == .major3)
        #expect(Interval.major10.subtracting(.perfect8) == .major3)
    }

    @Test
    func subtracting_success_M6() {
        #expect(Interval.major6.subtracting(.perfect1) == .major6)
        #expect(Interval.minor7.subtracting(.minor2) == .major6)
        #expect(Interval.major7.subtracting(.major2) == .major6)
        #expect(Interval.perfect8.subtracting(.minor3) == .major6)
        #expect(Interval.augmented8.subtracting(.major3) == .major6)
        #expect(Interval.major9.subtracting(.perfect4) == .major6)
        #expect(Interval.major10.subtracting(.perfect5) == .major6)
        #expect(Interval.perfect11.subtracting(.minor6) == .major6)
        #expect(Interval.augmented11.subtracting(.major6) == .major6)
        #expect(Interval.perfect12.subtracting(.minor7) == .major6)
        #expect(Interval.augmented12.subtracting(.major7) == .major6)
        #expect(Interval.major13.subtracting(.perfect8) == .major6)
    }

    @Test
    func subtracting_success_M7() {
        #expect(Interval.major7.subtracting(.perfect1) == .major7)
        #expect(Interval.perfect8.subtracting(.minor2) == .major7)
        #expect(Interval.augmented8.subtracting(.major2) == .major7)
        #expect(Interval.major9.subtracting(.minor3) == .major7)
        #expect(Interval.augmented9.subtracting(.major3) == .major7)
        #expect(Interval.major10.subtracting(.perfect4) == .major7)
        #expect(Interval.augmented11.subtracting(.perfect5) == .major7)
        #expect(Interval.perfect12.subtracting(.minor6) == .major7)
        #expect(Interval.augmented12.subtracting(.major6) == .major7)
        #expect(Interval.major13.subtracting(.minor7) == .major7)
        #expect(Interval.augmented13.subtracting(.major7) == .major7)
        #expect(Interval.major14.subtracting(.perfect8) == .major7)
    }

    @Test
    func subtracting_success_P1() {
        #expect(Interval.perfect1.subtracting(.perfect1) == .perfect1)
        #expect(Interval.minor2.subtracting(.minor2) == .perfect1)
        #expect(Interval.major2.subtracting(.major2) == .perfect1)
        #expect(Interval.minor3.subtracting(.minor3) == .perfect1)
        #expect(Interval.major3.subtracting(.major3) == .perfect1)
        #expect(Interval.perfect4.subtracting(.perfect4) == .perfect1)
        #expect(Interval.perfect5.subtracting(.perfect5) == .perfect1)
        #expect(Interval.minor6.subtracting(.minor6) == .perfect1)
        #expect(Interval.major6.subtracting(.major6) == .perfect1)
        #expect(Interval.minor7.subtracting(.minor7) == .perfect1)
        #expect(Interval.major7.subtracting(.major7) == .perfect1)
        #expect(Interval.perfect8.subtracting(.perfect8) == .perfect1)
    }

    @Test
    func subtracting_success_P4() {
        #expect(Interval.perfect4.subtracting(.perfect1) == .perfect4)
        #expect(Interval.diminished5.subtracting(.minor2) == .perfect4)
        #expect(Interval.perfect5.subtracting(.major2) == .perfect4)
        #expect(Interval.minor6.subtracting(.minor3) == .perfect4)
        #expect(Interval.major6.subtracting(.major3) == .perfect4)
        #expect(Interval.minor7.subtracting(.perfect4) == .perfect4)
        #expect(Interval.perfect8.subtracting(.perfect5) == .perfect4)
        #expect(Interval.minor9.subtracting(.minor6) == .perfect4)
        #expect(Interval.major9.subtracting(.major6) == .perfect4)
        #expect(Interval.minor10.subtracting(.minor7) == .perfect4)
        #expect(Interval.major10.subtracting(.major7) == .perfect4)
        #expect(Interval.perfect11.subtracting(.perfect8) == .perfect4)
    }

    @Test
    func subtracting_success_P5() {
        #expect(Interval.perfect5.subtracting(.perfect1) == .perfect5)
        #expect(Interval.minor6.subtracting(.minor2) == .perfect5)
        #expect(Interval.major6.subtracting(.major2) == .perfect5)
        #expect(Interval.minor7.subtracting(.minor3) == .perfect5)
        #expect(Interval.major7.subtracting(.major3) == .perfect5)
        #expect(Interval.perfect8.subtracting(.perfect4) == .perfect5)
        #expect(Interval.major9.subtracting(.perfect5) == .perfect5)
        #expect(Interval.minor10.subtracting(.minor6) == .perfect5)
        #expect(Interval.major10.subtracting(.major6) == .perfect5)
        #expect(Interval.perfect11.subtracting(.minor7) == .perfect5)
        #expect(Interval.augmented11.subtracting(.major7) == .perfect5)
        #expect(Interval.perfect12.subtracting(.perfect8) == .perfect5)
    }

    @Test
    func subtracting_success_P8() {
        #expect(Interval.perfect8.subtracting(.perfect1) == .perfect8)
        #expect(Interval.minor9.subtracting(.minor2) == .perfect8)
        #expect(Interval.major9.subtracting(.major2) == .perfect8)
        #expect(Interval.minor10.subtracting(.minor3) == .perfect8)
        #expect(Interval.major10.subtracting(.major3) == .perfect8)
        #expect(Interval.perfect11.subtracting(.perfect4) == .perfect8)
        #expect(Interval.perfect12.subtracting(.perfect5) == .perfect8)
        #expect(Interval.minor13.subtracting(.minor6) == .perfect8)
        #expect(Interval.major13.subtracting(.major6) == .perfect8)
        #expect(Interval.minor14.subtracting(.minor7) == .perfect8)
        #expect(Interval.major14.subtracting(.major7) == .perfect8)
        #expect(Interval.perfect15.subtracting(.perfect8) == .perfect8)
    }

    @Test
    func subtracting_success_m2() {
        #expect(Interval.minor2.subtracting(.perfect1) == .minor2)
        #expect(Interval.diminished3.subtracting(.minor2) == .minor2)
        #expect(Interval.minor3.subtracting(.major2) == .minor2)
        #expect(Interval.diminished4.subtracting(.minor3) == .minor2)
        #expect(Interval.perfect4.subtracting(.major3) == .minor2)
        #expect(Interval.diminished5.subtracting(.perfect4) == .minor2)
        #expect(Interval.minor6.subtracting(.perfect5) == .minor2)
        #expect(Interval.diminished7.subtracting(.minor6) == .minor2)
        #expect(Interval.minor7.subtracting(.major6) == .minor2)
        #expect(Interval.diminished8.subtracting(.minor7) == .minor2)
        #expect(Interval.perfect8.subtracting(.major7) == .minor2)
        #expect(Interval.minor9.subtracting(.perfect8) == .minor2)
    }

    @Test
    func subtracting_success_m3() {
        #expect(Interval.minor3.subtracting(.perfect1) == .minor3)
        #expect(Interval.diminished4.subtracting(.minor2) == .minor3)
        #expect(Interval.perfect4.subtracting(.major2) == .minor3)
        #expect(Interval.diminished5.subtracting(.minor3) == .minor3)
        #expect(Interval.perfect5.subtracting(.major3) == .minor3)
        #expect(Interval.minor6.subtracting(.perfect4) == .minor3)
        #expect(Interval.minor7.subtracting(.perfect5) == .minor3)
        #expect(Interval.diminished8.subtracting(.minor6) == .minor3)
        #expect(Interval.perfect8.subtracting(.major6) == .minor3)
        #expect(Interval.minor9.subtracting(.minor7) == .minor3)
        #expect(Interval.major9.subtracting(.major7) == .minor3)
        #expect(Interval.minor10.subtracting(.perfect8) == .minor3)
    }

    @Test
    func subtracting_success_m6() {
        #expect(Interval.minor6.subtracting(.perfect1) == .minor6)
        #expect(Interval.diminished7.subtracting(.minor2) == .minor6)
        #expect(Interval.minor7.subtracting(.major2) == .minor6)
        #expect(Interval.diminished8.subtracting(.minor3) == .minor6)
        #expect(Interval.perfect8.subtracting(.major3) == .minor6)
        #expect(Interval.minor9.subtracting(.perfect4) == .minor6)
        #expect(Interval.minor10.subtracting(.perfect5) == .minor6)
        #expect(Interval.diminished11.subtracting(.minor6) == .minor6)
        #expect(Interval.perfect11.subtracting(.major6) == .minor6)
        #expect(Interval.diminished12.subtracting(.minor7) == .minor6)
        #expect(Interval.perfect12.subtracting(.major7) == .minor6)
        #expect(Interval.minor13.subtracting(.perfect8) == .minor6)
    }

    @Test
    func subtracting_success_m7() {
        #expect(Interval.minor7.subtracting(.perfect1) == .minor7)
        #expect(Interval.diminished8.subtracting(.minor2) == .minor7)
        #expect(Interval.perfect8.subtracting(.major2) == .minor7)
        #expect(Interval.minor9.subtracting(.minor3) == .minor7)
        #expect(Interval.major9.subtracting(.major3) == .minor7)
        #expect(Interval.minor10.subtracting(.perfect4) == .minor7)
        #expect(Interval.perfect11.subtracting(.perfect5) == .minor7)
        #expect(Interval.diminished12.subtracting(.minor6) == .minor7)
        #expect(Interval.perfect12.subtracting(.major6) == .minor7)
        #expect(Interval.minor13.subtracting(.minor7) == .minor7)
        #expect(Interval.major13.subtracting(.major7) == .minor7)
        #expect(Interval.minor14.subtracting(.perfect8) == .minor7)
    }
}
