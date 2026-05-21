// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct LinearTemperamentCommonTests {
}

// MARK: -

extension LinearTemperamentCommonTests {

    @Test
    func fifthSize_ordering() throws {
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))

        let thirdFifth      = try #require(pureFifth.subtracting(LinearTemperament.thirdCommaMeantone.narrowingRatio))
        let twoSeventhFifth = try #require(pureFifth.subtracting(LinearTemperament.twoSeventhCommaMeantone.narrowingRatio))
        let quarterFifth    = try #require(pureFifth.subtracting(LinearTemperament.quarterCommaMeantone.narrowingRatio))
        let sixthFifth      = try #require(pureFifth.subtracting(LinearTemperament.sixthCommaMeantone.narrowingRatio))

        #expect(thirdFifth.cents < twoSeventhFifth.cents)
        #expect(twoSeventhFifth.cents < quarterFifth.cents)
        #expect(quarterFifth.cents < sixthFifth.cents)
    }

    @Test
    func pythagorean_noNarrowing() {
        #expect(LinearTemperament.pythagorean.narrowingRatio == .unison)
    }

    @Test
    func quarterCommaMeantone_fifth() throws {
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let fifth = try #require(pureFifth.subtracting(LinearTemperament.quarterCommaMeantone.narrowingRatio))

        // Four stacked fifths should equal a pure major third plus two octaves (5:1)
        assertEqual(fifth.multiplied(by: 4), 5)
    }

    @Test
    func sixthCommaMeantone_fifth() throws {
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let fifth = try #require(pureFifth.subtracting(LinearTemperament.sixthCommaMeantone.narrowingRatio))
        let fortyFiveQuarters = try #require(Ratio(numberValue: Number(45) / Number(4)))

        // Six stacked fifths should equal 45:4
        assertEqual(fifth.multiplied(by: 6), fortyFiveQuarters)
    }

    @Test
    func thirdCommaMeantone_fifth() throws {
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let fifth = try #require(pureFifth.subtracting(LinearTemperament.thirdCommaMeantone.narrowingRatio))
        let tenThirds = try #require(Ratio(numberValue: Number(10) / Number(3)))

        // Three stacked fifths should equal a pure major sixth plus one octave (10:3)
        assertEqual(fifth.multiplied(by: 3), tenThirds)
    }

    @Test
    func twoSeventhCommaMeantone_fifth() throws {
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let fifth = try #require(pureFifth.subtracting(LinearTemperament.twoSeventhCommaMeantone.narrowingRatio))
        let fiftyThirds = try #require(Ratio(numberValue: Number(50) / Number(3)))

        // Seven stacked fifths should equal 50:3
        assertEqual(fifth.multiplied(by: 7), fiftyThirds)
    }
}
