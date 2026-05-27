// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

extension TuningSystem where Self == WellTemperament {

    // MARK: Public Type Properties

    /// Kellner (Herbert Anton Kellner, 1977).
    ///
    /// Five fifths — C→G, G→D, D→A, A→E, and B→F♯ — are each narrowed by ⅕ of the
    /// Pythagorean comma, equal to ⁵√(2¹⁴/3⁷) ≈ 697.654 cents. The remaining seven
    /// fifths are pure (3:2). The circle closes exactly.
    ///
    /// Proposed by Kellner as a reconstruction of Bach's own tuning, published in
    /// *Das Musikinstrument* 26 (1977). The choice of five fifths and their positions
    /// mirrors the structure of Werckmeister III while spreading the tempering more evenly.
    public static var kellner: WellTemperament {
        .kellner
    }

    /// Kirnberger II (Johann Philipp Kirnberger, c. 1771).
    ///
    /// Two fifths — D→A and A→E — are each narrowed by ½ of the syntonic comma, equal to
    /// √(20/9) ≈ 691.202 cents. One fifth — F♯→C♯ — is narrowed by one schisma
    /// (32805:32768), equal to 16384:10935 ≈ 699.977 cents. The remaining nine fifths are
    /// pure (3:2). The circle closes exactly because one syntonic comma times one schisma
    /// equals one Pythagorean comma.
    ///
    /// The two half-comma fifths are unusually flat, giving C-adjacent keys very pure
    /// thirds while keys with many sharps or flats suffer greatly.
    public static var kirnbergerII: WellTemperament {
        .kirnbergerII
    }

    /// Kirnberger III (Johann Philipp Kirnberger, 1779).
    ///
    /// Four fifths — C→G, G→D, D→A, and A→E — are each narrowed by ¼ of the syntonic
    /// comma, equal to ⁴√5 ≈ 696.578 cents. One fifth — F♯→C♯ — is narrowed by one
    /// schisma (32805:32768), equal to 16384:10935 ≈ 699.977 cents. The remaining seven
    /// fifths are pure (3:2). The circle closes exactly because one syntonic comma times
    /// one schisma equals one Pythagorean comma.
    ///
    /// The four quarter-comma fifths make C–E a pure major third (5:4). Published in
    /// *Die Kunst des reinen Satzes in der Musik*, Part II.
    public static var kirnbergerIII: WellTemperament {
        .kirnbergerIII
    }

    /// Neidhardt I ("Village"; Johann Georg Neidhardt, 1724).
    ///
    /// Four fifths — C→G, G→D, D→A, A→E — are each narrowed by ⅙ of the Pythagorean
    /// comma (≈ 698.045 cents). Four fifths — E→B, B→F♯, A♭→E♭, E♭→B♭ — are each
    /// narrowed by 1/12 of the Pythagorean comma, equal to the equal-temperament fifth
    /// 2^(7/12) ≈ 700.000 cents. The remaining four fifths are pure. The circle closes
    /// exactly: 4×(1/6) + 4×(1/12) = 1 Pythagorean comma.
    ///
    /// From *Sectio Canonis Harmonici* (Königsberg, 1724). Neidhardt relabeled this
    /// specification "Small City" in his 1732 revision.
    public static var neidhardtI: WellTemperament {
        .neidhardtI
    }

    /// Neidhardt II ("Small City"; Johann Georg Neidhardt, 1724).
    ///
    /// Three fifths — C→G, G→D, D→A — are each narrowed by ⅙ of the Pythagorean comma
    /// (≈ 698.045 cents). Six fifths — A→E, B→F♯, F♯→C♯, C♯→A♭, B♭→F, F→C — are each
    /// narrowed by 1/12 of the Pythagorean comma (≈ 700.000 cents). The remaining three
    /// fifths — E→B, A♭→E♭, E♭→B♭ — are pure. The circle closes exactly:
    /// 3×(1/6) + 6×(1/12) = 1 Pythagorean comma.
    ///
    /// From *Sectio Canonis Harmonici* (Königsberg, 1724). Neidhardt relabeled this
    /// specification "Large City" in his 1732 revision.
    public static var neidhardtII: WellTemperament {
        .neidhardtII
    }

    /// Neidhardt III ("Large City"; Johann Georg Neidhardt, 1724).
    ///
    /// Three fifths — C→G, G→D, D→A — are each narrowed by ⅙ of the Pythagorean comma
    /// (≈ 698.045 cents). Six fifths — A→E, B→F♯, F♯→C♯, C♯→A♭, E♭→B♭, B♭→F — are
    /// each narrowed by 1/12 of the Pythagorean comma (≈ 700.000 cents). The remaining
    /// three fifths — E→B, A♭→E♭, F→C — are pure. The circle closes exactly:
    /// 3×(1/6) + 6×(1/12) = 1 Pythagorean comma.
    ///
    /// From *Sectio Canonis Harmonici* (Königsberg, 1724). Differs from ``neidhardtII``
    /// only in the placement of the sixth-comma group on the flat side: E♭→B♭ is tempered
    /// here where it is pure in Neidhardt II, and F→C is pure here where it is tempered
    /// in Neidhardt II.
    public static var neidhardtIII: WellTemperament {
        .neidhardtIII
    }

    /// Vallotti (Francesco Antonio Vallotti, c. 1728).
    ///
    /// Six consecutive fifths from F to B — F→C, C→G, G→D, D→A, A→E, E→B — are each
    /// narrowed by ⅙ of the Pythagorean comma, equal to 2^(13/6)/3 ≈ 698.045 cents.
    /// The remaining six fifths are pure (3:2). The circle closes exactly.
    public static var vallotti: WellTemperament {
        .vallotti
    }

    /// Werckmeister III (Andreas Werckmeister, 1691).
    ///
    /// Four fifths are narrowed by ¼ of the Pythagorean comma — C→G, G→D, D→A, and B→F♯
    /// — each equal to 2^(15/4)/9 ≈ 696.090 cents. The remaining eight fifths are pure
    /// (3:2). The circle closes exactly.
    ///
    /// This is the most historically cited well temperament, often associated with
    /// Bach's Well-Tempered Clavier.
    public static var werckmeisterIII: WellTemperament {
        .werckmeisterIII
    }

    /// Young I (Thomas Young, 1800).
    ///
    /// Four fifths — C→G, G→D, D→A, and A→E — are each narrowed by 3/16 of the syntonic
    /// comma, equal to (3/2)·(80/81)^(3/16) ≈ 697.923 cents. Four more fifths — E→B,
    /// B→F♯, B♭→F, and F→C — are each narrowed by (¼ PC − 3/16 SC) ≈ 1.833 cents,
    /// equal to (3/2)·(81/80)^(3/16)·(2¹⁹/3¹²)^(−1/4) ≈ 700.122 cents. The remaining
    /// four fifths are pure (3:2). The circle closes exactly.
    ///
    /// Published in *Philosophical Transactions of the Royal Society* 90 (1800).
    public static var youngI: WellTemperament {
        .youngI
    }

    /// Young II (Thomas Young, 1800).
    ///
    /// Six consecutive fifths from C to F♯ — C→G, G→D, D→A, A→E, E→B, B→F♯ — are each
    /// narrowed by ⅙ of the Pythagorean comma, equal to 2^(13/6)/3 ≈ 698.045 cents.
    /// The remaining six fifths are pure (3:2). The circle closes exactly.
    ///
    /// The tempered fifth size is identical to Vallotti, but the tempered segment runs
    /// from C through F♯ (six sharps) rather than from F through B (six naturals/flats).
    /// Published in *Philosophical Transactions of the Royal Society* 90 (1800).
    public static var youngII: WellTemperament {
        .youngII
    }
}

// MARK: -

extension WellTemperament {

    // MARK: Fileprivate Type Properties

    fileprivate static let kellner = WellTemperament(fifths: [.cToG: fifthPCFifth,
                                                              .gToD: fifthPCFifth,
                                                              .dToA: fifthPCFifth,
                                                              .aToE: fifthPCFifth,
                                                              .bToFSharp: fifthPCFifth])

    fileprivate static let kirnbergerII = WellTemperament(fifths: [.dToA: halfSCFifth,
                                                                   .aToE: halfSCFifth,
                                                                   .fSharpToCSharp: schismaticFifth])

    fileprivate static let kirnbergerIII = WellTemperament(fifths: [.cToG: quarterSCFifth,
                                                                    .gToD: quarterSCFifth,
                                                                    .dToA: quarterSCFifth,
                                                                    .aToE: quarterSCFifth,
                                                                    .fSharpToCSharp: schismaticFifth])

    fileprivate static let neidhardtI = WellTemperament(fifths: [.cToG: sixthPCFifth,
                                                                 .gToD: sixthPCFifth,
                                                                 .dToA: sixthPCFifth,
                                                                 .aToE: sixthPCFifth,
                                                                 .eToB: twelfthPCFifth,
                                                                 .bToFSharp: twelfthPCFifth,
                                                                 .aFlatToEFlat: twelfthPCFifth,
                                                                 .eFlatToBFlat: twelfthPCFifth])

    fileprivate static let neidhardtII = WellTemperament(fifths: [.cToG: sixthPCFifth,
                                                                  .gToD: sixthPCFifth,
                                                                  .dToA: sixthPCFifth,
                                                                  .aToE: twelfthPCFifth,
                                                                  .bToFSharp: twelfthPCFifth,
                                                                  .fSharpToCSharp: twelfthPCFifth,
                                                                  .cSharpToAFlat: twelfthPCFifth,
                                                                  .bFlatToF: twelfthPCFifth,
                                                                  .fToC: twelfthPCFifth])

    fileprivate static let neidhardtIII = WellTemperament(fifths: [.cToG: sixthPCFifth,
                                                                   .gToD: sixthPCFifth,
                                                                   .dToA: sixthPCFifth,
                                                                   .aToE: twelfthPCFifth,
                                                                   .bToFSharp: twelfthPCFifth,
                                                                   .fSharpToCSharp: twelfthPCFifth,
                                                                   .cSharpToAFlat: twelfthPCFifth,
                                                                   .eFlatToBFlat: twelfthPCFifth,
                                                                   .bFlatToF: twelfthPCFifth])

    fileprivate static let vallotti = WellTemperament(fifths: [.fToC: sixthPCFifth,
                                                               .cToG: sixthPCFifth,
                                                               .gToD: sixthPCFifth,
                                                               .dToA: sixthPCFifth,
                                                               .aToE: sixthPCFifth,
                                                               .eToB: sixthPCFifth])

    fileprivate static let werckmeisterIII = WellTemperament(fifths: [.cToG: quarterPCFifth,
                                                                      .gToD: quarterPCFifth,
                                                                      .dToA: quarterPCFifth,
                                                                      .bToFSharp: quarterPCFifth])

    fileprivate static let youngI: WellTemperament = {
        let sc316 = syntonicComma.mul(3, 16)
        let temperedA = pureFifth.sub(sc316)
        let temperedB = pureFifth.add(sc316).sub(pythagoreanComma.div(4))

        return WellTemperament(fifths: [.cToG: temperedA,
                                        .gToD: temperedA,
                                        .dToA: temperedA,
                                        .aToE: temperedA,
                                        .eToB: temperedB,
                                        .bToFSharp: temperedB,
                                        .bFlatToF: temperedB,
                                        .fToC: temperedB])
    }()

    fileprivate static let youngII = WellTemperament(fifths: [.cToG: sixthPCFifth,
                                                              .gToD: sixthPCFifth,
                                                              .dToA: sixthPCFifth,
                                                              .aToE: sixthPCFifth,
                                                              .eToB: sixthPCFifth,
                                                              .bToFSharp: sixthPCFifth])
}

// MARK: - Private Constants

private let pureFifth        = Ratio(3, 2)
private let pythagoreanComma = Ratio(531_441, 524_288)
private let syntonicComma    = Ratio(81, 80)

private let fifthPCFifth     = pureFifth.sub(pythagoreanComma.div(5))
private let halfSCFifth      = pureFifth.sub(syntonicComma.div(2))
private let quarterPCFifth   = pureFifth.sub(pythagoreanComma.div(4))
private let quarterSCFifth   = pureFifth.sub(syntonicComma.div(4))
private let schismaticFifth  = Ratio(16_384, 10_935)
private let sixthPCFifth     = pureFifth.sub(pythagoreanComma.div(6))
private let twelfthPCFifth   = pureFifth.sub(pythagoreanComma.div(12))
