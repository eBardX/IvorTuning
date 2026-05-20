// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers
private import XestiTools

extension MeantoneTemperament {

    // MARK: Public Type Properties

    /// Quarter-comma meantone: the fifth is narrowed so that four stacked fifths produce a
    /// pure major third (5:4). Fifth = ⁴√5 ≈ 696.578 cents.
    ///
    /// This is the most historically common meantone temperament, widely used in the
    /// Renaissance and Baroque periods.
    public static let quarterComma = MeantoneTemperament(fifthRatio: (5 as Ratio).divided(by: 4).require())

    /// Sixth-comma meantone: the fifth is narrowed by a sixth of the syntonic comma, giving a
    /// major third midway between pure (5:4) and Pythagorean (81:64). Fifth = ⁶√(45/4) ≈
    /// 698.371 cents.
    public static let sixthComma = MeantoneTemperament(fifthRatio: Ratio(numberValue: Number(45) / Number(4)).require().divided(by: 6).require())

    /// Third-comma meantone: the fifth is narrowed so that three stacked fifths produce a
    /// pure major sixth (5:3). Fifth = ∛(10/3) ≈ 694.786 cents.
    public static let thirdComma = MeantoneTemperament(fifthRatio: Ratio(numberValue: Number(10) / Number(3)).require().divided(by: 3).require())

    /// Two-seventh-comma meantone (Zarlino, 1558): the fifth is narrowed by 2/7 of the
    /// syntonic comma. Fifth = ⁷√(50/3) ≈ 695.810 cents.
    ///
    /// This is the minimax temperament for 5-limit triads: the major third error (wide of
    /// 5:4) and the minor third error (narrow of 6:5) are equal in magnitude and opposite
    /// in sign, minimising the worst error across both thirds. Seven stacked fifths produce
    /// exactly 50:3.
    public static let twoSeventhComma = MeantoneTemperament(fifthRatio: Ratio(numberValue: Number(50) / Number(3)).require().divided(by: 7).require())
}
