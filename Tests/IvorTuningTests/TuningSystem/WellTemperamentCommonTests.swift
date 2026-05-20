// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct WellTemperamentCommonTests {

    private static let allFifths: [WellTemperament.Fifth] = [.cToG,
                                                             .gToD,
                                                             .dToA,
                                                             .aToE,
                                                             .eToB,
                                                             .bToFSharp,
                                                             .fSharpToCSharp,
                                                             .cSharpToAFlat,
                                                             .aFlatToEFlat,
                                                             .eFlatToBFlat,
                                                             .bFlatToF,
                                                             .fToC]

    private func circleCloses(_ wt: WellTemperament) -> Bool {
        guard let pure = Ratio(numberValue: Number(3) / Number(2))
        else {
            return false
        }

        let product = Self.allFifths
            .map { wt.fifths[$0] ?? pure }
            .map(\.numberValue)
            .reduce(Number(1), *)

        return abs(product.doubleValue - 128) < 1e-6
    }
}

// MARK: -

extension WellTemperamentCommonTests {

    @Test
    func kellner_circleCloses() {
        #expect(circleCloses(.kellner))
    }

    @Test
    func kellner_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.eToB,
                                                   .fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.kellner.fifths[fifth] == nil)
        }
    }

    @Test
    func kellner_temperedFifths() throws {
        let ratio    = try #require(Ratio(numberValue: Number(16_384) / Number(2_187)))
        let expected = try #require(ratio.divided(by: 5))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .aToE, .bToFSharp] {
            assertEqual(WellTemperament.kellner.fifths[fifth], expected)
        }
    }

    @Test
    func kirnbergerII_circleCloses() {
        #expect(circleCloses(.kirnbergerII))
    }

    @Test
    func kirnbergerII_halfSyntonicFifths() throws {
        let expected = try #require(Ratio(numberValue: Number(20) / Number(9))?.divided(by: 2))

        for fifth in [WellTemperament.Fifth.dToA, .aToE] {
            assertEqual(WellTemperament.kirnbergerII.fifths[fifth], expected)
        }
    }

    @Test
    func kirnbergerII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.cToG,
                                                   .gToD,
                                                   .eToB,
                                                   .bToFSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.kirnbergerII.fifths[fifth] == nil)
        }
    }

    @Test
    func kirnbergerII_schismaticFifth() throws {
        let expected = try #require(Ratio(numberValue: Number(16_384) / Number(10_935)))

        assertEqual(WellTemperament.kirnbergerII.fifths[.fSharpToCSharp], expected)
    }

    @Test
    func kirnbergerIII_circleCloses() {
        #expect(circleCloses(.kirnbergerIII))
    }

    @Test
    func kirnbergerIII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.eToB,
                                                   .bToFSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.kirnbergerIII.fifths[fifth] == nil)
        }
    }

    @Test
    func kirnbergerIII_quarterSyntonicFifths() throws {
        let expected = try #require((5 as Ratio).divided(by: 4))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .aToE] {
            assertEqual(WellTemperament.kirnbergerIII.fifths[fifth], expected)
        }
    }

    @Test
    func kirnbergerIII_schismaticFifth() throws {
        let expected = try #require(Ratio(numberValue: Number(16_384) / Number(10_935)))

        assertEqual(WellTemperament.kirnbergerIII.fifths[.fSharpToCSharp], expected)
    }

    @Test
    func neidhardtI_circleCloses() {
        #expect(circleCloses(.neidhardtI))
    }

    @Test
    func neidhardtI_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.neidhardtI.fifths[fifth] == nil)
        }
    }

    @Test
    func neidhardtI_sixthCommaFifths() throws {
        let base     = try #require((2 as Ratio).multiplied(by: Number(13) / Number(6)))
        let expected = try #require(base.subtracting(3 as Ratio))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .aToE] {
            assertEqual(WellTemperament.neidhardtI.fifths[fifth], expected)
        }
    }

    @Test
    func neidhardtI_twelfthCommaFifths() throws {
        let expected = try #require((2 as Ratio).multiplied(by: Number(7) / Number(12)))

        for fifth in [WellTemperament.Fifth.eToB, .bToFSharp, .aFlatToEFlat, .eFlatToBFlat] {
            assertEqual(WellTemperament.neidhardtI.fifths[fifth], expected)
        }
    }

    @Test
    func neidhardtII_circleCloses() {
        #expect(circleCloses(.neidhardtII))
    }

    @Test
    func neidhardtII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.eToB, .aFlatToEFlat, .eFlatToBFlat]

        for fifth in pureFifths {
            #expect(WellTemperament.neidhardtII.fifths[fifth] == nil)
        }
    }

    @Test
    func neidhardtII_sixthCommaFifths() throws {
        let base     = try #require((2 as Ratio).multiplied(by: Number(13) / Number(6)))
        let expected = try #require(base.subtracting(3 as Ratio))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA] {
            assertEqual(WellTemperament.neidhardtII.fifths[fifth], expected)
        }
    }

    @Test
    func neidhardtII_twelfthCommaFifths() throws {
        let expected = try #require((2 as Ratio).multiplied(by: Number(7) / Number(12)))

        for fifth in [WellTemperament.Fifth.aToE,
                      .bToFSharp,
                      .fSharpToCSharp,
                      .cSharpToAFlat,
                      .bFlatToF,
                      .fToC] {
            assertEqual(WellTemperament.neidhardtII.fifths[fifth], expected)
        }
    }

    @Test
    func neidhardtIII_circleCloses() {
        #expect(circleCloses(.neidhardtIII))
    }

    @Test
    func neidhardtIII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.eToB, .aFlatToEFlat, .fToC]

        for fifth in pureFifths {
            #expect(WellTemperament.neidhardtIII.fifths[fifth] == nil)
        }
    }

    @Test
    func neidhardtIII_sixthCommaFifths() throws {
        let base     = try #require((2 as Ratio).multiplied(by: Number(13) / Number(6)))
        let expected = try #require(base.subtracting(3 as Ratio))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA] {
            assertEqual(WellTemperament.neidhardtIII.fifths[fifth], expected)
        }
    }

    @Test
    func neidhardtIII_twelfthCommaFifths() throws {
        let expected = try #require((2 as Ratio).multiplied(by: Number(7) / Number(12)))

        for fifth in [WellTemperament.Fifth.aToE,
                      .bToFSharp,
                      .fSharpToCSharp,
                      .cSharpToAFlat,
                      .eFlatToBFlat,
                      .bFlatToF] {
            assertEqual(WellTemperament.neidhardtIII.fifths[fifth], expected)
        }
    }

    @Test
    func vallotti_circleCloses() {
        #expect(circleCloses(.vallotti))
    }

    @Test
    func vallotti_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.bToFSharp,
                                                   .fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF]
        for fifth in pureFifths {
            #expect(WellTemperament.vallotti.fifths[fifth] == nil)
        }
    }

    @Test
    func vallotti_temperedFifths() throws {
        let twoToThe13Over6 = try #require((2 as Ratio).multiplied(by: Number(13) / Number(6)))
        let expected        = try #require(twoToThe13Over6.subtracting(3 as Ratio))

        for fifth in [WellTemperament.Fifth.fToC, .cToG, .gToD, .dToA, .aToE, .eToB] {
            assertEqual(WellTemperament.vallotti.fifths[fifth], expected)
        }
    }

    @Test
    func werckmeisterIII_circleCloses() {
        #expect(circleCloses(.werckmeisterIII))
    }

    @Test
    func werckmeisterIII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.aToE,
                                                   .eToB,
                                                   .fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.werckmeisterIII.fifths[fifth] == nil)
        }
    }

    @Test
    func werckmeisterIII_temperedFifths() throws {
        let twoToThe15Over4 = try #require((2 as Ratio).multiplied(by: Number(15) / Number(4)))
        let expected        = try #require(twoToThe15Over4.subtracting(9 as Ratio))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .bToFSharp] {
            assertEqual(WellTemperament.werckmeisterIII.fifths[fifth], expected)
        }
    }

    @Test
    func youngI_circleCloses() {
        #expect(circleCloses(.youngI))
    }

    @Test
    func youngI_lessNarrowFifths() throws {
        let pure   = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let sc     = try #require(Ratio(numberValue: Number(81) / Number(80)))
        let pc     = try #require(Ratio(numberValue: Number(531_441) / Number(524_288)))
        let sc316  = try #require(sc.multiplied(by: Number(3) / Number(16)))
        let pc14   = try #require(pc.divided(by: 4))
        let withSC = try #require(pure.adding(sc316))
        let expected = try #require(withSC.subtracting(pc14))

        for fifth in [WellTemperament.Fifth.eToB, .bToFSharp, .bFlatToF, .fToC] {
            assertEqual(WellTemperament.youngI.fifths[fifth], expected)
        }
    }

    @Test
    func youngI_narrowerFifths() throws {
        let pure     = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let sc       = try #require(Ratio(numberValue: Number(81) / Number(80)))
        let sc316    = try #require(sc.multiplied(by: Number(3) / Number(16)))
        let expected = try #require(pure.subtracting(sc316))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .aToE] {
            assertEqual(WellTemperament.youngI.fifths[fifth], expected)
        }
    }

    @Test
    func youngI_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat]
        for fifth in pureFifths {
            #expect(WellTemperament.youngI.fifths[fifth] == nil)
        }
    }

    @Test
    func youngII_circleCloses() {
        #expect(circleCloses(.youngII))
    }

    @Test
    func youngII_pureFifths() {
        let pureFifths: [WellTemperament.Fifth] = [.fSharpToCSharp,
                                                   .cSharpToAFlat,
                                                   .aFlatToEFlat,
                                                   .eFlatToBFlat,
                                                   .bFlatToF,
                                                   .fToC]
        for fifth in pureFifths {
            #expect(WellTemperament.youngII.fifths[fifth] == nil)
        }
    }

    @Test
    func youngII_temperedFifths() throws {
        let twoToThe13Over6 = try #require((2 as Ratio).multiplied(by: Number(13) / Number(6)))
        let expected        = try #require(twoToThe13Over6.subtracting(3 as Ratio))

        for fifth in [WellTemperament.Fifth.cToG, .gToD, .dToA, .aToE, .eToB, .bToFSharp] {
            assertEqual(WellTemperament.youngII.fifths[fifth], expected)
        }
    }
}
