// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

extension LinearTemperament {

    // MARK: Public Type Properties

    /// Pythagorean tuning: the perfect fifth is pure (3:2). No narrowing.
    ///
    /// All intervals are derived by stacking pure fifths and reducing by octaves. Because
    /// the 12th fifth does not return to the starting pitch, the circle of fifths does not
    /// close; pitches that differ by a Pythagorean comma (531441:524288 ≈ 23.460 cents)
    /// are distinct.
    public static let pythagorean = LinearTemperament()

    /// Quarter-comma meantone: the fifth is narrowed by 1/4 of the syntonic comma so that
    /// four stacked fifths produce a pure major third (5:4). Fifth ≈ 696.578 cents.
    ///
    /// This is the most historically common meantone temperament, widely used in the
    /// Renaissance and Baroque periods.
    public static let quarterCommaMeantone = LinearTemperament(narrowingRatio: syntonicComma.div(4))

    /// Sixth-comma meantone: the fifth is narrowed by 1/6 of the syntonic comma, giving a
    /// major third midway between pure (5:4) and Pythagorean (81:64). Fifth ≈ 698.371 cents.
    public static let sixthCommaMeantone = LinearTemperament(narrowingRatio: syntonicComma.div(6))

    /// Third-comma meantone: the fifth is narrowed by 1/3 of the syntonic comma so that
    /// three stacked fifths produce a pure minor third (6:5). Fifth ≈ 694.786 cents.
    public static let thirdCommaMeantone = LinearTemperament(narrowingRatio: syntonicComma.div(3))

    /// Two-seventh-comma meantone (Zarlino, 1571): the fifth is narrowed by 2/7 of the
    /// syntonic comma. Fifth ≈ 695.810 cents.
    ///
    /// This is the minimax temperament for 5-limit triads: the major third error (wide of
    /// 5:4) and the minor third error (narrow of 6:5) are equal in magnitude and opposite
    /// in sign, minimising the worst error across both thirds.
    public static let twoSeventhCommaMeantone = LinearTemperament(narrowingRatio: syntonicComma.mul(2, 7))
}

// MARK: - Private Constants

private let syntonicComma = Ratio(81, 80)
