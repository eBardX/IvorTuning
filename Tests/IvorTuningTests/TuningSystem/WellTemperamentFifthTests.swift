// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct WellTemperamentFifthTests {
}

// MARK: -

extension WellTemperamentFifthTests {

    @Test
    func distinctCases() {
        let all: Set<WellTemperament.Fifth> = [.aFlatToEFlat,
                                               .aToE,
                                               .bFlatToF,
                                               .bToFSharp,
                                               .cSharpToAFlat,
                                               .cToG,
                                               .dToA,
                                               .eFlatToBFlat,
                                               .eToB,
                                               .fSharpToCSharp,
                                               .fToC,
                                               .gToD]

        #expect(all.count == 12)
    }
}
