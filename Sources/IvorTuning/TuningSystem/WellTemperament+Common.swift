// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers
private import XestiTools

extension WellTemperament {

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
    public static let kellner: WellTemperament = {
        // (3/2)·(2¹⁹/3¹²)^(1/5) = ⁵√(2¹⁴/3⁷)
        let tempered = Ratio(16_384, 2_187).divided(by: 5).require()

        return WellTemperament(fifths: [.cToG: tempered,
                                        .gToD: tempered,
                                        .dToA: tempered,
                                        .aToE: tempered,
                                        .bToFSharp: tempered])
    }()

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
    public static let kirnbergerII: WellTemperament = {
        // (3/2)·(80/81)^(1/2) = √(20/9)
        let halfSyntonic = Ratio(20, 9).divided(by: 2).require()
        // (3/2)·(32768/32805) = 16384:10935
        let schismatic = Ratio(16_384, 10_935)

        return WellTemperament(fifths: [.dToA: halfSyntonic,
                                        .aToE: halfSyntonic,
                                        .fSharpToCSharp: schismatic])
    }()

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
    public static let kirnbergerIII: WellTemperament = {
        // (3/2)·(80/81)^(1/4) = ⁴√5
        let quarterSyntonic = Ratio(5, 1).divided(by: 4).require()
        // (3/2)·(32768/32805) = 16384:10935
        let schismatic = Ratio(16_384, 10_935)

        return WellTemperament(fifths: [.cToG: quarterSyntonic,
                                        .gToD: quarterSyntonic,
                                        .dToA: quarterSyntonic,
                                        .aToE: quarterSyntonic,
                                        .fSharpToCSharp: schismatic])
    }()

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
    public static let neidhardtI: WellTemperament = {
        let sixthComma = Ratio(2, 1).multiplied(by: Number(13) / Number(6)).require()
            .subtracting(Ratio(3, 1)).require()
        let twelfthComma = Ratio(2, 1).multiplied(by: Number(7) / Number(12)).require()

        return WellTemperament(fifths: [.cToG: sixthComma,
                                        .gToD: sixthComma,
                                        .dToA: sixthComma,
                                        .aToE: sixthComma,
                                        .eToB: twelfthComma,
                                        .bToFSharp: twelfthComma,
                                        .aFlatToEFlat: twelfthComma,
                                        .eFlatToBFlat: twelfthComma])
    }()

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
    public static let neidhardtII: WellTemperament = {
        let sixthComma = Ratio(2, 1).multiplied(by: Number(13) / Number(6)).require()
            .subtracting(Ratio(3, 1)).require()
        let twelfthComma = Ratio(2, 1).multiplied(by: Number(7) / Number(12)).require()

        return WellTemperament(fifths: [.cToG: sixthComma,
                                        .gToD: sixthComma,
                                        .dToA: sixthComma,
                                        .aToE: twelfthComma,
                                        .bToFSharp: twelfthComma,
                                        .fSharpToCSharp: twelfthComma,
                                        .cSharpToAFlat: twelfthComma,
                                        .bFlatToF: twelfthComma,
                                        .fToC: twelfthComma])
    }()

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
    public static let neidhardtIII: WellTemperament = {
        let sixthComma = Ratio(2, 1).multiplied(by: Number(13) / Number(6)).require()
            .subtracting(Ratio(3, 1)).require()
        let twelfthComma = Ratio(2, 1).multiplied(by: Number(7) / Number(12)).require()

        return WellTemperament(fifths: [.cToG: sixthComma,
                                        .gToD: sixthComma,
                                        .dToA: sixthComma,
                                        .aToE: twelfthComma,
                                        .bToFSharp: twelfthComma,
                                        .fSharpToCSharp: twelfthComma,
                                        .cSharpToAFlat: twelfthComma,
                                        .eFlatToBFlat: twelfthComma,
                                        .bFlatToF: twelfthComma])
    }()

    /// Vallotti (Francesco Antonio Vallotti, c. 1728).
    ///
    /// Six consecutive fifths from F to B — F→C, C→G, G→D, D→A, A→E, E→B — are each
    /// narrowed by ⅙ of the Pythagorean comma, equal to 2^(13/6)/3 ≈ 698.045 cents.
    /// The remaining six fifths are pure (3:2). The circle closes exactly.
    public static let vallotti: WellTemperament = {
        let tempered = Ratio(2, 1).multiplied(by: Number(13) / Number(6)).require()
            .subtracting(Ratio(3, 1)).require()

        return WellTemperament(fifths: [.fToC: tempered,
                                        .cToG: tempered,
                                        .gToD: tempered,
                                        .dToA: tempered,
                                        .aToE: tempered,
                                        .eToB: tempered])
    }()

    /// Werckmeister III (Andreas Werckmeister, 1691).
    ///
    /// Four fifths are narrowed by ¼ of the Pythagorean comma — C→G, G→D, D→A, and B→F♯
    /// — each equal to 2^(15/4)/9 ≈ 696.090 cents. The remaining eight fifths are pure
    /// (3:2). The circle closes exactly.
    ///
    /// This is the most historically cited well temperament, often associated with
    /// Bach's Well-Tempered Clavier.
    public static let werckmeisterIII: WellTemperament = {
        let tempered = Ratio(2, 1).multiplied(by: Number(15) / Number(4)).require()
            .subtracting(Ratio(9, 1)).require()

        return WellTemperament(fifths: [.cToG: tempered,
                                        .gToD: tempered,
                                        .dToA: tempered,
                                        .bToFSharp: tempered])
    }()

    /// Young I (Thomas Young, 1800).
    ///
    /// Four fifths — C→G, G→D, D→A, and A→E — are each narrowed by 3/16 of the syntonic
    /// comma, equal to (3/2)·(80/81)^(3/16) ≈ 697.923 cents. Four more fifths — E→B,
    /// B→F♯, B♭→F, and F→C — are each narrowed by (¼ PC − 3/16 SC) ≈ 1.833 cents,
    /// equal to (3/2)·(81/80)^(3/16)·(2¹⁹/3¹²)^(−1/4) ≈ 700.122 cents. The remaining
    /// four fifths are pure (3:2). The circle closes exactly.
    ///
    /// Published in *Philosophical Transactions of the Royal Society* 90 (1800).
    public static let youngI: WellTemperament = {
        let pure = Ratio(3, 2)
        let sc = Ratio(81, 80)
        let pc = Ratio(531_441, 524_288)
        let sc316 = sc.multiplied(by: Number(3) / Number(16)).require()
        let pc14 = pc.divided(by: 4).require()

        // (3/2)·(80/81)^(3/16) — narrowed by 3/16 SC
        let temperedA = pure.subtracting(sc316).require()
        // (3/2)·(81/80)^(3/16)·(2¹⁹/3¹²)^(−1/4) — narrowed by (1/4 PC − 3/16 SC)
        let temperedB = pure.adding(sc316).require().subtracting(pc14).require()

        return WellTemperament(fifths: [.cToG: temperedA,
                                        .gToD: temperedA,
                                        .dToA: temperedA,
                                        .aToE: temperedA,
                                        .eToB: temperedB,
                                        .bToFSharp: temperedB,
                                        .bFlatToF: temperedB,
                                        .fToC: temperedB])
    }()

    /// Young II (Thomas Young, 1800).
    ///
    /// Six consecutive fifths from C to F♯ — C→G, G→D, D→A, A→E, E→B, B→F♯ — are each
    /// narrowed by ⅙ of the Pythagorean comma, equal to 2^(13/6)/3 ≈ 698.045 cents.
    /// The remaining six fifths are pure (3:2). The circle closes exactly.
    ///
    /// The tempered fifth size is identical to Vallotti, but the tempered segment runs
    /// from C through F♯ (six sharps) rather than from F through B (six naturals/flats).
    /// Published in *Philosophical Transactions of the Royal Society* 90 (1800).
    public static let youngII: WellTemperament = {
        // Same size as Vallotti: (3/2)·(2¹⁹/3¹²)^(1/6) = 2^(13/6)/3
        let tempered = Ratio(2, 1).multiplied(by: Number(13) / Number(6)).require()
            .subtracting(Ratio(3, 1)).require()

        return WellTemperament(fifths: [.cToG: tempered,
                                        .gToD: tempered,
                                        .dToA: tempered,
                                        .aToE: tempered,
                                        .eToB: tempered,
                                        .bToFSharp: tempered])
    }()
}
