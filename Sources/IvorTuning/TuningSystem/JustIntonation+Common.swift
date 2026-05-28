// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers
private import XestiTools

extension TuningSystem where Self == JustIntonation {

    // MARK: Public Type Properties

    /// Five-limit just intonation: the standard chromatic scale using ratios with no
    /// prime factor above 5.
    ///
    /// Covers all 12 pitch classes of the chromatic octave, including both enharmonic
    /// tritone spellings (45:32 and 64:45). ``ratios`` has 14 elements: the tonic,
    /// 12 interior pitch classes, and the octave.
    ///
    /// Does not support standard pitch notation.
    public static var fiveLimitJI: JustIntonation {
        .fiveLimitJI
    }

    /// Harry Partch’s 43-tone 11-limit just scale.
    ///
    /// The complete 43-tone scale from _Genesis of a Music_ (1949/1974), with 41
    /// distinct pitch classes between the unison and octave. ``ratios`` has 43 elements,
    /// matching Partch’s own count which includes both endpoints.
    ///
    /// Does not support standard pitch notation; its 41 interior pitch classes exceed the
    /// 35-pitch-class maximum, and 11-limit ratios have no standard spelling.
    public static var partch43: JustIntonation {
        .partch43
    }

    /// Seven-limit just intonation: extends five-limit with the harmonic seventh (7:4).
    ///
    /// Adds 7:4 (~969 cents), the defining interval of 7-limit harmony. All five-limit
    /// ratios are retained. ``ratios`` has 15 elements.
    ///
    /// Does not fully support standard pitch notation; the harmonic seventh (7:4) has no
    /// standard spelling and diverges too far from any Pythagorean interval.
    public static var sevenLimitJI: JustIntonation {
        .sevenLimitJI
    }
}

// MARK: -

extension JustIntonation {

    // MARK: Fileprivate Type Properties

    fileprivate static let fiveLimitJI = JustIntonation(ratios: [Ratio(16, 15),    // minor second
                                                                 Ratio(9, 8),      // major second
                                                                 Ratio(6, 5),      // minor third
                                                                 Ratio(5, 4),      // major third
                                                                 Ratio(4, 3),      // perfect fourth
                                                                 Ratio(45, 32),    // augmented fourth
                                                                 Ratio(64, 45),    // diminished fifth
                                                                 Ratio(3, 2),      // perfect fifth
                                                                 Ratio(8, 5),      // minor sixth
                                                                 Ratio(5, 3),      // major sixth
                                                                 Ratio(9, 5),      // minor seventh
                                                                 Ratio(15, 8)])    // major seventh

    fileprivate static let partch43 = JustIntonation(ratios: [Ratio(81, 80),
                                                              Ratio(33, 32),
                                                              Ratio(21, 20),
                                                              Ratio(16, 15),
                                                              Ratio(12, 11),
                                                              Ratio(11, 10),
                                                              Ratio(10, 9),
                                                              Ratio(9, 8),
                                                              Ratio(8, 7),
                                                              Ratio(7, 6),
                                                              Ratio(32, 27),
                                                              Ratio(6, 5),
                                                              Ratio(11, 9),
                                                              Ratio(5, 4),
                                                              Ratio(14, 11),
                                                              Ratio(9, 7),
                                                              Ratio(21, 16),
                                                              Ratio(4, 3),
                                                              Ratio(27, 20),
                                                              Ratio(11, 8),
                                                              Ratio(7, 5),
                                                              Ratio(10, 7),
                                                              Ratio(16, 11),
                                                              Ratio(40, 27),
                                                              Ratio(3, 2),
                                                              Ratio(32, 21),
                                                              Ratio(14, 9),
                                                              Ratio(11, 7),
                                                              Ratio(8, 5),
                                                              Ratio(18, 11),
                                                              Ratio(5, 3),
                                                              Ratio(27, 16),
                                                              Ratio(12, 7),
                                                              Ratio(7, 4),
                                                              Ratio(16, 9),
                                                              Ratio(9, 5),
                                                              Ratio(20, 11),
                                                              Ratio(11, 6),
                                                              Ratio(15, 8),
                                                              Ratio(40, 21),
                                                              Ratio(64, 33)])

    fileprivate static let sevenLimitJI = JustIntonation(ratios: fiveLimitJI.ratios + [Ratio(7, 4)]) // harmonic seventh
}
