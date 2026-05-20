// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing

struct RatioTests {
}

// MARK: -

extension RatioTests {
    @Test
    func adding_failure() {
    }

    @Test
    func adding_failure_d2() {
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished2), Fixtures.triplyDiminished3)
        assertEqual(Fixtures.diminished2.adding(Fixtures.minor2), Fixtures.doublyDiminished3)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished3), Fixtures.triplyDiminished4)
        assertEqual(Fixtures.diminished2.adding(Fixtures.minor3), Fixtures.doublyDiminished4)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished4), Fixtures.triplyDiminished5)
        assertEqual(Fixtures.diminished2.adding(Fixtures.perfect4), Fixtures.doublyDiminished5)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished5), Fixtures.doublyDiminished6)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished6), Fixtures.triplyDiminished7)
        assertEqual(Fixtures.diminished2.adding(Fixtures.minor6), Fixtures.doublyDiminished7)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished7), Fixtures.triplyDiminished8)
        assertEqual(Fixtures.diminished2.adding(Fixtures.minor7), Fixtures.doublyDiminished8)
        assertEqual(Fixtures.diminished2.adding(Fixtures.diminished8), Fixtures.doublyDiminished9)
    }

    @Test
    func adding_success_A1() {
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented1), Fixtures.doublyAugmented1)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented2), Fixtures.doublyAugmented2)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented3), Fixtures.doublyAugmented3)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented4), Fixtures.doublyAugmented4)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented5), Fixtures.doublyAugmented5)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented6), Fixtures.doublyAugmented6)
        assertEqual(Fixtures.augmented1.adding(Fixtures.augmented7), Fixtures.doublyAugmented7)
    }

    @Test
    func adding_success_M2() {
        assertEqual(Fixtures.major2.adding(Fixtures.perfect1), Fixtures.major2)
        assertEqual(Fixtures.major2.adding(Fixtures.minor2), Fixtures.minor3)
        assertEqual(Fixtures.major2.adding(Fixtures.major2), Fixtures.major3)
        assertEqual(Fixtures.major2.adding(Fixtures.minor3), Fixtures.perfect4)
        assertEqual(Fixtures.major2.adding(Fixtures.major3), Fixtures.augmented4)
        assertEqual(Fixtures.major2.adding(Fixtures.perfect4), Fixtures.perfect5)
        assertEqual(Fixtures.major2.adding(Fixtures.perfect5), Fixtures.major6)
        assertEqual(Fixtures.major2.adding(Fixtures.minor6), Fixtures.minor7)
        assertEqual(Fixtures.major2.adding(Fixtures.major6), Fixtures.major7)
        assertEqual(Fixtures.major2.adding(Fixtures.minor7), Fixtures.perfect8)
        assertEqual(Fixtures.major2.adding(Fixtures.major7), Fixtures.augmented8)
        assertEqual(Fixtures.major2.adding(Fixtures.perfect8), Fixtures.major9)
    }

    @Test
    func adding_success_M3() {
        assertEqual(Fixtures.major3.adding(Fixtures.perfect1), Fixtures.major3)
        assertEqual(Fixtures.major3.adding(Fixtures.minor2), Fixtures.perfect4)
        assertEqual(Fixtures.major3.adding(Fixtures.major2), Fixtures.augmented4)
        assertEqual(Fixtures.major3.adding(Fixtures.minor3), Fixtures.perfect5)
        assertEqual(Fixtures.major3.adding(Fixtures.major3), Fixtures.augmented5)
        assertEqual(Fixtures.major3.adding(Fixtures.perfect4), Fixtures.major6)
        assertEqual(Fixtures.major3.adding(Fixtures.perfect5), Fixtures.major7)
        assertEqual(Fixtures.major3.adding(Fixtures.minor6), Fixtures.perfect8)
        assertEqual(Fixtures.major3.adding(Fixtures.major6), Fixtures.augmented8)
        assertEqual(Fixtures.major3.adding(Fixtures.minor7), Fixtures.major9)
        assertEqual(Fixtures.major3.adding(Fixtures.major7), Fixtures.augmented9)
        assertEqual(Fixtures.major3.adding(Fixtures.perfect8), Fixtures.major10)
    }

    @Test
    func adding_success_M6() {
        assertEqual(Fixtures.major6.adding(Fixtures.perfect1), Fixtures.major6)
        assertEqual(Fixtures.major6.adding(Fixtures.minor2), Fixtures.minor7)
        assertEqual(Fixtures.major6.adding(Fixtures.major2), Fixtures.major7)
        assertEqual(Fixtures.major6.adding(Fixtures.minor3), Fixtures.perfect8)
        assertEqual(Fixtures.major6.adding(Fixtures.major3), Fixtures.augmented8)
        assertEqual(Fixtures.major6.adding(Fixtures.perfect4), Fixtures.major9)
        assertEqual(Fixtures.major6.adding(Fixtures.perfect5), Fixtures.major10)
        assertEqual(Fixtures.major6.adding(Fixtures.minor6), Fixtures.perfect11)
        assertEqual(Fixtures.major6.adding(Fixtures.major6), Fixtures.augmented11)
        assertEqual(Fixtures.major6.adding(Fixtures.minor7), Fixtures.perfect12)
        assertEqual(Fixtures.major6.adding(Fixtures.major7), Fixtures.augmented12)
        assertEqual(Fixtures.major6.adding(Fixtures.perfect8), Fixtures.major13)
    }

    @Test
    func adding_success_M7() {
        assertEqual(Fixtures.major7.adding(Fixtures.perfect1), Fixtures.major7)
        assertEqual(Fixtures.major7.adding(Fixtures.minor2), Fixtures.perfect8)
        assertEqual(Fixtures.major7.adding(Fixtures.major2), Fixtures.augmented8)
        assertEqual(Fixtures.major7.adding(Fixtures.minor3), Fixtures.major9)
        assertEqual(Fixtures.major7.adding(Fixtures.major3), Fixtures.augmented9)
        assertEqual(Fixtures.major7.adding(Fixtures.perfect4), Fixtures.major10)
        assertEqual(Fixtures.major7.adding(Fixtures.perfect5), Fixtures.augmented11)
        assertEqual(Fixtures.major7.adding(Fixtures.minor6), Fixtures.perfect12)
        assertEqual(Fixtures.major7.adding(Fixtures.major6), Fixtures.augmented12)
        assertEqual(Fixtures.major7.adding(Fixtures.minor7), Fixtures.major13)
        assertEqual(Fixtures.major7.adding(Fixtures.major7), Fixtures.augmented13)
        assertEqual(Fixtures.major7.adding(Fixtures.perfect8), Fixtures.major14)
    }

    @Test
    func adding_success_P1() {
        assertEqual(Fixtures.perfect1.adding(Fixtures.perfect1), Fixtures.perfect1)
        assertEqual(Fixtures.perfect1.adding(Fixtures.minor2), Fixtures.minor2)
        assertEqual(Fixtures.perfect1.adding(Fixtures.major2), Fixtures.major2)
        assertEqual(Fixtures.perfect1.adding(Fixtures.minor3), Fixtures.minor3)
        assertEqual(Fixtures.perfect1.adding(Fixtures.major3), Fixtures.major3)
        assertEqual(Fixtures.perfect1.adding(Fixtures.perfect4), Fixtures.perfect4)
        assertEqual(Fixtures.perfect1.adding(Fixtures.perfect5), Fixtures.perfect5)
        assertEqual(Fixtures.perfect1.adding(Fixtures.minor6), Fixtures.minor6)
        assertEqual(Fixtures.perfect1.adding(Fixtures.major6), Fixtures.major6)
        assertEqual(Fixtures.perfect1.adding(Fixtures.minor7), Fixtures.minor7)
        assertEqual(Fixtures.perfect1.adding(Fixtures.major7), Fixtures.major7)
        assertEqual(Fixtures.perfect1.adding(Fixtures.perfect8), Fixtures.perfect8)
    }

    @Test
    func adding_success_P4() {
        assertEqual(Fixtures.perfect4.adding(Fixtures.perfect1), Fixtures.perfect4)
        assertEqual(Fixtures.perfect4.adding(Fixtures.minor2), Fixtures.diminished5)
        assertEqual(Fixtures.perfect4.adding(Fixtures.major2), Fixtures.perfect5)
        assertEqual(Fixtures.perfect4.adding(Fixtures.minor3), Fixtures.minor6)
        assertEqual(Fixtures.perfect4.adding(Fixtures.major3), Fixtures.major6)
        assertEqual(Fixtures.perfect4.adding(Fixtures.perfect4), Fixtures.minor7)
        assertEqual(Fixtures.perfect4.adding(Fixtures.perfect5), Fixtures.perfect8)
        assertEqual(Fixtures.perfect4.adding(Fixtures.minor6), Fixtures.minor9)
        assertEqual(Fixtures.perfect4.adding(Fixtures.major6), Fixtures.major9)
        assertEqual(Fixtures.perfect4.adding(Fixtures.minor7), Fixtures.minor10)
        assertEqual(Fixtures.perfect4.adding(Fixtures.major7), Fixtures.major10)
        assertEqual(Fixtures.perfect4.adding(Fixtures.perfect8), Fixtures.perfect11)
    }

    @Test
    func adding_success_P5() {
        assertEqual(Fixtures.perfect5.adding(Fixtures.perfect1), Fixtures.perfect5)
        assertEqual(Fixtures.perfect5.adding(Fixtures.minor2), Fixtures.minor6)
        assertEqual(Fixtures.perfect5.adding(Fixtures.major2), Fixtures.major6)
        assertEqual(Fixtures.perfect5.adding(Fixtures.minor3), Fixtures.minor7)
        assertEqual(Fixtures.perfect5.adding(Fixtures.major3), Fixtures.major7)
        assertEqual(Fixtures.perfect5.adding(Fixtures.perfect4), Fixtures.perfect8)
        assertEqual(Fixtures.perfect5.adding(Fixtures.perfect5), Fixtures.major9)
        assertEqual(Fixtures.perfect5.adding(Fixtures.minor6), Fixtures.minor10)
        assertEqual(Fixtures.perfect5.adding(Fixtures.major6), Fixtures.major10)
        assertEqual(Fixtures.perfect5.adding(Fixtures.minor7), Fixtures.perfect11)
        assertEqual(Fixtures.perfect5.adding(Fixtures.major7), Fixtures.augmented11)
        assertEqual(Fixtures.perfect5.adding(Fixtures.perfect8), Fixtures.perfect12)
    }

    @Test
    func adding_success_P8() {
        assertEqual(Fixtures.perfect8.adding(Fixtures.perfect1), Fixtures.perfect8)
        assertEqual(Fixtures.perfect8.adding(Fixtures.minor2), Fixtures.minor9)
        assertEqual(Fixtures.perfect8.adding(Fixtures.major2), Fixtures.major9)
        assertEqual(Fixtures.perfect8.adding(Fixtures.minor3), Fixtures.minor10)
        assertEqual(Fixtures.perfect8.adding(Fixtures.major3), Fixtures.major10)
        assertEqual(Fixtures.perfect8.adding(Fixtures.perfect4), Fixtures.perfect11)
        assertEqual(Fixtures.perfect8.adding(Fixtures.perfect5), Fixtures.perfect12)
        assertEqual(Fixtures.perfect8.adding(Fixtures.minor6), Fixtures.minor13)
        assertEqual(Fixtures.perfect8.adding(Fixtures.major6), Fixtures.major13)
        assertEqual(Fixtures.perfect8.adding(Fixtures.minor7), Fixtures.minor14)
        assertEqual(Fixtures.perfect8.adding(Fixtures.major7), Fixtures.major14)
        assertEqual(Fixtures.perfect8.adding(Fixtures.perfect8), Fixtures.perfect15)
    }

    @Test
    func adding_success_m2() {
        assertEqual(Fixtures.minor2.adding(Fixtures.perfect1), Fixtures.minor2)
        assertEqual(Fixtures.minor2.adding(Fixtures.minor2), Fixtures.diminished3)
        assertEqual(Fixtures.minor2.adding(Fixtures.major2), Fixtures.minor3)
        assertEqual(Fixtures.minor2.adding(Fixtures.minor3), Fixtures.diminished4)
        assertEqual(Fixtures.minor2.adding(Fixtures.major3), Fixtures.perfect4)
        assertEqual(Fixtures.minor2.adding(Fixtures.perfect4), Fixtures.diminished5)
        assertEqual(Fixtures.minor2.adding(Fixtures.perfect5), Fixtures.minor6)
        assertEqual(Fixtures.minor2.adding(Fixtures.minor6), Fixtures.diminished7)
        assertEqual(Fixtures.minor2.adding(Fixtures.major6), Fixtures.minor7)
        assertEqual(Fixtures.minor2.adding(Fixtures.minor7), Fixtures.diminished8)
        assertEqual(Fixtures.minor2.adding(Fixtures.major7), Fixtures.perfect8)
        assertEqual(Fixtures.minor2.adding(Fixtures.perfect8), Fixtures.minor9)
    }

    @Test
    func adding_success_m3() {
        assertEqual(Fixtures.minor3.adding(Fixtures.perfect1), Fixtures.minor3)
        assertEqual(Fixtures.minor3.adding(Fixtures.minor2), Fixtures.diminished4)
        assertEqual(Fixtures.minor3.adding(Fixtures.major2), Fixtures.perfect4)
        assertEqual(Fixtures.minor3.adding(Fixtures.minor3), Fixtures.diminished5)
        assertEqual(Fixtures.minor3.adding(Fixtures.major3), Fixtures.perfect5)
        assertEqual(Fixtures.minor3.adding(Fixtures.perfect4), Fixtures.minor6)
        assertEqual(Fixtures.minor3.adding(Fixtures.perfect5), Fixtures.minor7)
        assertEqual(Fixtures.minor3.adding(Fixtures.minor6), Fixtures.diminished8)
        assertEqual(Fixtures.minor3.adding(Fixtures.major6), Fixtures.perfect8)
        assertEqual(Fixtures.minor3.adding(Fixtures.minor7), Fixtures.minor9)
        assertEqual(Fixtures.minor3.adding(Fixtures.major7), Fixtures.major9)
        assertEqual(Fixtures.minor3.adding(Fixtures.perfect8), Fixtures.minor10)
    }

    @Test
    func adding_success_m6() {
        assertEqual(Fixtures.minor6.adding(Fixtures.perfect1), Fixtures.minor6)
        assertEqual(Fixtures.minor6.adding(Fixtures.minor2), Fixtures.diminished7)
        assertEqual(Fixtures.minor6.adding(Fixtures.major2), Fixtures.minor7)
        assertEqual(Fixtures.minor6.adding(Fixtures.minor3), Fixtures.diminished8)
        assertEqual(Fixtures.minor6.adding(Fixtures.major3), Fixtures.perfect8)
        assertEqual(Fixtures.minor6.adding(Fixtures.perfect4), Fixtures.minor9)
        assertEqual(Fixtures.minor6.adding(Fixtures.perfect5), Fixtures.minor10)
        assertEqual(Fixtures.minor6.adding(Fixtures.minor6), Fixtures.diminished11)
        assertEqual(Fixtures.minor6.adding(Fixtures.major6), Fixtures.perfect11)
        assertEqual(Fixtures.minor6.adding(Fixtures.minor7), Fixtures.diminished12)
        assertEqual(Fixtures.minor6.adding(Fixtures.major7), Fixtures.perfect12)
        assertEqual(Fixtures.minor6.adding(Fixtures.perfect8), Fixtures.minor13)
    }

    @Test
    func adding_success_m7() {
        assertEqual(Fixtures.minor7.adding(Fixtures.perfect1), Fixtures.minor7)
        assertEqual(Fixtures.minor7.adding(Fixtures.minor2), Fixtures.diminished8)
        assertEqual(Fixtures.minor7.adding(Fixtures.major2), Fixtures.perfect8)
        assertEqual(Fixtures.minor7.adding(Fixtures.minor3), Fixtures.minor9)
        assertEqual(Fixtures.minor7.adding(Fixtures.major3), Fixtures.major9)
        assertEqual(Fixtures.minor7.adding(Fixtures.perfect4), Fixtures.minor10)
        assertEqual(Fixtures.minor7.adding(Fixtures.perfect5), Fixtures.perfect11)
        assertEqual(Fixtures.minor7.adding(Fixtures.minor6), Fixtures.diminished12)
        assertEqual(Fixtures.minor7.adding(Fixtures.major6), Fixtures.perfect12)
        assertEqual(Fixtures.minor7.adding(Fixtures.minor7), Fixtures.minor13)
        assertEqual(Fixtures.minor7.adding(Fixtures.major7), Fixtures.major13)
        assertEqual(Fixtures.minor7.adding(Fixtures.perfect8), Fixtures.minor14)
    }

    @Test
    func subtracting_failure() {
    }

    @Test
    func subtracting_success_M2() {
        assertEqual(Fixtures.major2.subtracting(Fixtures.perfect1), Fixtures.major2)
        assertEqual(Fixtures.minor3.subtracting(Fixtures.minor2), Fixtures.major2)
        assertEqual(Fixtures.major3.subtracting(Fixtures.major2), Fixtures.major2)
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.minor3), Fixtures.major2)
        assertEqual(Fixtures.augmented4.subtracting(Fixtures.major3), Fixtures.major2)
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.perfect4), Fixtures.major2)
        assertEqual(Fixtures.major6.subtracting(Fixtures.perfect5), Fixtures.major2)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.minor6), Fixtures.major2)
        assertEqual(Fixtures.major7.subtracting(Fixtures.major6), Fixtures.major2)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.minor7), Fixtures.major2)
        assertEqual(Fixtures.augmented8.subtracting(Fixtures.major7), Fixtures.major2)
        assertEqual(Fixtures.major9.subtracting(Fixtures.perfect8), Fixtures.major2)
    }

    @Test
    func subtracting_success_M3() {
        assertEqual(Fixtures.major3.subtracting(Fixtures.perfect1), Fixtures.major3)
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.minor2), Fixtures.major3)
        assertEqual(Fixtures.augmented4.subtracting(Fixtures.major2), Fixtures.major3)
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.minor3), Fixtures.major3)
        assertEqual(Fixtures.augmented5.subtracting(Fixtures.major3), Fixtures.major3)
        assertEqual(Fixtures.major6.subtracting(Fixtures.perfect4), Fixtures.major3)
        assertEqual(Fixtures.major7.subtracting(Fixtures.perfect5), Fixtures.major3)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.minor6), Fixtures.major3)
        assertEqual(Fixtures.augmented8.subtracting(Fixtures.major6), Fixtures.major3)
        assertEqual(Fixtures.major9.subtracting(Fixtures.minor7), Fixtures.major3)
        assertEqual(Fixtures.augmented9.subtracting(Fixtures.major7), Fixtures.major3)
        assertEqual(Fixtures.major10.subtracting(Fixtures.perfect8), Fixtures.major3)
    }

    @Test
    func subtracting_success_M6() {
        assertEqual(Fixtures.major6.subtracting(Fixtures.perfect1), Fixtures.major6)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.minor2), Fixtures.major6)
        assertEqual(Fixtures.major7.subtracting(Fixtures.major2), Fixtures.major6)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.minor3), Fixtures.major6)
        assertEqual(Fixtures.augmented8.subtracting(Fixtures.major3), Fixtures.major6)
        assertEqual(Fixtures.major9.subtracting(Fixtures.perfect4), Fixtures.major6)
        assertEqual(Fixtures.major10.subtracting(Fixtures.perfect5), Fixtures.major6)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.minor6), Fixtures.major6)
        assertEqual(Fixtures.augmented11.subtracting(Fixtures.major6), Fixtures.major6)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.minor7), Fixtures.major6)
        assertEqual(Fixtures.augmented12.subtracting(Fixtures.major7), Fixtures.major6)
        assertEqual(Fixtures.major13.subtracting(Fixtures.perfect8), Fixtures.major6)
    }

    @Test
    func subtracting_success_M7() {
        assertEqual(Fixtures.major7.subtracting(Fixtures.perfect1), Fixtures.major7)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.minor2), Fixtures.major7)
        assertEqual(Fixtures.augmented8.subtracting(Fixtures.major2), Fixtures.major7)
        assertEqual(Fixtures.major9.subtracting(Fixtures.minor3), Fixtures.major7)
        assertEqual(Fixtures.augmented9.subtracting(Fixtures.major3), Fixtures.major7)
        assertEqual(Fixtures.major10.subtracting(Fixtures.perfect4), Fixtures.major7)
        assertEqual(Fixtures.augmented11.subtracting(Fixtures.perfect5), Fixtures.major7)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.minor6), Fixtures.major7)
        assertEqual(Fixtures.augmented12.subtracting(Fixtures.major6), Fixtures.major7)
        assertEqual(Fixtures.major13.subtracting(Fixtures.minor7), Fixtures.major7)
        assertEqual(Fixtures.augmented13.subtracting(Fixtures.major7), Fixtures.major7)
        assertEqual(Fixtures.major14.subtracting(Fixtures.perfect8), Fixtures.major7)
    }

    @Test
    func subtracting_success_P1() {
        assertEqual(Fixtures.perfect1.subtracting(Fixtures.perfect1), Fixtures.perfect1)
        assertEqual(Fixtures.minor2.subtracting(Fixtures.minor2), Fixtures.perfect1)
        assertEqual(Fixtures.major2.subtracting(Fixtures.major2), Fixtures.perfect1)
        assertEqual(Fixtures.minor3.subtracting(Fixtures.minor3), Fixtures.perfect1)
        assertEqual(Fixtures.major3.subtracting(Fixtures.major3), Fixtures.perfect1)
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.perfect4), Fixtures.perfect1)
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.perfect5), Fixtures.perfect1)
        assertEqual(Fixtures.minor6.subtracting(Fixtures.minor6), Fixtures.perfect1)
        assertEqual(Fixtures.major6.subtracting(Fixtures.major6), Fixtures.perfect1)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.minor7), Fixtures.perfect1)
        assertEqual(Fixtures.major7.subtracting(Fixtures.major7), Fixtures.perfect1)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.perfect8), Fixtures.perfect1)
    }

    @Test
    func subtracting_success_P4() {
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.perfect1), Fixtures.perfect4)
        assertEqual(Fixtures.diminished5.subtracting(Fixtures.minor2), Fixtures.perfect4)
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.major2), Fixtures.perfect4)
        assertEqual(Fixtures.minor6.subtracting(Fixtures.minor3), Fixtures.perfect4)
        assertEqual(Fixtures.major6.subtracting(Fixtures.major3), Fixtures.perfect4)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.perfect4), Fixtures.perfect4)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.perfect5), Fixtures.perfect4)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.minor6), Fixtures.perfect4)
        assertEqual(Fixtures.major9.subtracting(Fixtures.major6), Fixtures.perfect4)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.minor7), Fixtures.perfect4)
        assertEqual(Fixtures.major10.subtracting(Fixtures.major7), Fixtures.perfect4)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.perfect8), Fixtures.perfect4)
    }

    @Test
    func subtracting_success_P5() {
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.perfect1), Fixtures.perfect5)
        assertEqual(Fixtures.minor6.subtracting(Fixtures.minor2), Fixtures.perfect5)
        assertEqual(Fixtures.major6.subtracting(Fixtures.major2), Fixtures.perfect5)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.minor3), Fixtures.perfect5)
        assertEqual(Fixtures.major7.subtracting(Fixtures.major3), Fixtures.perfect5)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.perfect4), Fixtures.perfect5)
        assertEqual(Fixtures.major9.subtracting(Fixtures.perfect5), Fixtures.perfect5)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.minor6), Fixtures.perfect5)
        assertEqual(Fixtures.major10.subtracting(Fixtures.major6), Fixtures.perfect5)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.minor7), Fixtures.perfect5)
        assertEqual(Fixtures.augmented11.subtracting(Fixtures.major7), Fixtures.perfect5)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.perfect8), Fixtures.perfect5)
    }

    @Test
    func subtracting_success_P8() {
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.perfect1), Fixtures.perfect8)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.minor2), Fixtures.perfect8)
        assertEqual(Fixtures.major9.subtracting(Fixtures.major2), Fixtures.perfect8)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.minor3), Fixtures.perfect8)
        assertEqual(Fixtures.major10.subtracting(Fixtures.major3), Fixtures.perfect8)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.perfect4), Fixtures.perfect8)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.perfect5), Fixtures.perfect8)
        assertEqual(Fixtures.minor13.subtracting(Fixtures.minor6), Fixtures.perfect8)
        assertEqual(Fixtures.major13.subtracting(Fixtures.major6), Fixtures.perfect8)
        assertEqual(Fixtures.minor14.subtracting(Fixtures.minor7), Fixtures.perfect8)
        assertEqual(Fixtures.major14.subtracting(Fixtures.major7), Fixtures.perfect8)
        assertEqual(Fixtures.perfect15.subtracting(Fixtures.perfect8), Fixtures.perfect8)
    }

    @Test
    func subtracting_success_m2() {
        assertEqual(Fixtures.minor2.subtracting(Fixtures.perfect1), Fixtures.minor2)
        assertEqual(Fixtures.diminished3.subtracting(Fixtures.minor2), Fixtures.minor2)
        assertEqual(Fixtures.minor3.subtracting(Fixtures.major2), Fixtures.minor2)
        assertEqual(Fixtures.diminished4.subtracting(Fixtures.minor3), Fixtures.minor2)
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.major3), Fixtures.minor2)
        assertEqual(Fixtures.diminished5.subtracting(Fixtures.perfect4), Fixtures.minor2)
        assertEqual(Fixtures.minor6.subtracting(Fixtures.perfect5), Fixtures.minor2)
        assertEqual(Fixtures.diminished7.subtracting(Fixtures.minor6), Fixtures.minor2)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.major6), Fixtures.minor2)
        assertEqual(Fixtures.diminished8.subtracting(Fixtures.minor7), Fixtures.minor2)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.major7), Fixtures.minor2)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.perfect8), Fixtures.minor2)
    }

    @Test
    func subtracting_success_m3() {
        assertEqual(Fixtures.minor3.subtracting(Fixtures.perfect1), Fixtures.minor3)
        assertEqual(Fixtures.diminished4.subtracting(Fixtures.minor2), Fixtures.minor3)
        assertEqual(Fixtures.perfect4.subtracting(Fixtures.major2), Fixtures.minor3)
        assertEqual(Fixtures.diminished5.subtracting(Fixtures.minor3), Fixtures.minor3)
        assertEqual(Fixtures.perfect5.subtracting(Fixtures.major3), Fixtures.minor3)
        assertEqual(Fixtures.minor6.subtracting(Fixtures.perfect4), Fixtures.minor3)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.perfect5), Fixtures.minor3)
        assertEqual(Fixtures.diminished8.subtracting(Fixtures.minor6), Fixtures.minor3)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.major6), Fixtures.minor3)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.minor7), Fixtures.minor3)
        assertEqual(Fixtures.major9.subtracting(Fixtures.major7), Fixtures.minor3)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.perfect8), Fixtures.minor3)
    }

    @Test
    func subtracting_success_m6() {
        assertEqual(Fixtures.minor6.subtracting(Fixtures.perfect1), Fixtures.minor6)
        assertEqual(Fixtures.diminished7.subtracting(Fixtures.minor2), Fixtures.minor6)
        assertEqual(Fixtures.minor7.subtracting(Fixtures.major2), Fixtures.minor6)
        assertEqual(Fixtures.diminished8.subtracting(Fixtures.minor3), Fixtures.minor6)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.major3), Fixtures.minor6)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.perfect4), Fixtures.minor6)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.perfect5), Fixtures.minor6)
        assertEqual(Fixtures.diminished11.subtracting(Fixtures.minor6), Fixtures.minor6)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.major6), Fixtures.minor6)
        assertEqual(Fixtures.diminished12.subtracting(Fixtures.minor7), Fixtures.minor6)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.major7), Fixtures.minor6)
        assertEqual(Fixtures.minor13.subtracting(Fixtures.perfect8), Fixtures.minor6)
    }

    @Test
    func subtracting_success_m7() {
        assertEqual(Fixtures.minor7.subtracting(Fixtures.perfect1), Fixtures.minor7)
        assertEqual(Fixtures.diminished8.subtracting(Fixtures.minor2), Fixtures.minor7)
        assertEqual(Fixtures.perfect8.subtracting(Fixtures.major2), Fixtures.minor7)
        assertEqual(Fixtures.minor9.subtracting(Fixtures.minor3), Fixtures.minor7)
        assertEqual(Fixtures.major9.subtracting(Fixtures.major3), Fixtures.minor7)
        assertEqual(Fixtures.minor10.subtracting(Fixtures.perfect4), Fixtures.minor7)
        assertEqual(Fixtures.perfect11.subtracting(Fixtures.perfect5), Fixtures.minor7)
        assertEqual(Fixtures.diminished12.subtracting(Fixtures.minor6), Fixtures.minor7)
        assertEqual(Fixtures.perfect12.subtracting(Fixtures.major6), Fixtures.minor7)
        assertEqual(Fixtures.minor13.subtracting(Fixtures.minor7), Fixtures.minor7)
        assertEqual(Fixtures.major13.subtracting(Fixtures.major7), Fixtures.minor7)
        assertEqual(Fixtures.minor14.subtracting(Fixtures.perfect8), Fixtures.minor7)
    }
}
