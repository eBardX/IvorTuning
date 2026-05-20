// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct MeantoneTemperamentCommonTests {
}

// MARK: -

extension MeantoneTemperamentCommonTests {

    @Test
    func fifthSize_ordering() {
        #expect(MeantoneTemperament.thirdComma.fifthRatio.cents
                < MeantoneTemperament.twoSeventhComma.fifthRatio.cents)
        #expect(MeantoneTemperament.twoSeventhComma.fifthRatio.cents
                < MeantoneTemperament.quarterComma.fifthRatio.cents)
        #expect(MeantoneTemperament.quarterComma.fifthRatio.cents
                < MeantoneTemperament.sixthComma.fifthRatio.cents)
    }

    @Test
    func quarterComma_fifth() {
        // Four stacked fifths should equal a pure major third plus two octaves (5:1)
        assertEqual(MeantoneTemperament.quarterComma.fifthRatio.multiplied(by: 4), 5)
    }

    @Test
    func sixthComma_fifth() throws {
        // Six stacked fifths should equal 45:4
        let fortyFiveQuarters = try #require(Ratio(numberValue: Number(45) / Number(4)))

        assertEqual(MeantoneTemperament.sixthComma.fifthRatio.multiplied(by: 6), fortyFiveQuarters)
    }

    @Test
    func thirdComma_fifth() throws {
        // Three stacked fifths should equal a pure major sixth plus one octave (10:3)
        let tenThirds = try #require(Ratio(numberValue: Number(10) / Number(3)))

        assertEqual(MeantoneTemperament.thirdComma.fifthRatio.multiplied(by: 3), tenThirds)
    }

    @Test
    func twoSeventhComma_fifth() throws {
        // Seven stacked fifths should equal 50:3
        let fiftyThirds = try #require(Ratio(numberValue: Number(50) / Number(3)))

        assertEqual(MeantoneTemperament.twoSeventhComma.fifthRatio.multiplied(by: 7), fiftyThirds)
    }
}
