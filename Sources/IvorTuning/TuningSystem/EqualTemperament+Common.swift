// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

extension TuningSystem where Self == EqualTemperament {

    // MARK: Public Type Properties

    /// Bohlen-Pierce: 13 equal divisions of the tritave (3:1).
    ///
    /// Each step is ¹³√3 ≈ 146.304 cents. Proposed independently by Heinz Bohlen (1978)
    /// and John R. Pierce. Because the interval of equivalence is a tritave rather than
    /// an octave, this system is not directly compatible with standard octave-based instruments.
    ///
    /// Does not support standard pitch notation (non-octave interval of equivalence).
    public static var bohlenPierce: EqualTemperament {
        .bohlenPierce
    }

    /// Carlos Alpha (α): non-octave ET whose step is one ninth of a pure fifth (3:2).
    ///
    /// Each step is ⁹√(3/2) ≈ 77.995 cents, so 9 steps produce a pure perfect fifth.
    /// Five steps approximate the major third (5:4) at ≈ 390.0 cents (+3.7 cents wide).
    /// Introduced by Wendy Carlos in *Tuning: At the Crossroads*, Computer Music Journal
    /// 11/1 (1987). The interval of equivalence is undefined; the octave is not closed.
    ///
    /// Does not support standard pitch notation (non-octave interval of equivalence).
    public static var carlosAlpha: EqualTemperament {
        .carlosAlpha
    }

    /// Carlos Beta (β): non-octave ET whose step is one eleventh of a pure fifth (3:2).
    ///
    /// Each step is ¹¹√(3/2) ≈ 63.814 cents, so 11 steps produce a pure perfect fifth.
    /// Six steps approximate the major third (5:4) at ≈ 382.9 cents (−3.4 cents narrow).
    /// Introduced by Wendy Carlos alongside Alpha and Gamma (1987).
    ///
    /// Does not support standard pitch notation (non-octave interval of equivalence).
    public static var carlosBeta: EqualTemperament {
        .carlosBeta
    }

    /// Carlos Gamma (γ): non-octave ET whose step is one twentieth of a pure fifth (3:2).
    ///
    /// Each step is ²⁰√(3/2) ≈ 35.098 cents, so 20 steps produce a pure perfect fifth.
    /// Eleven steps approximate the major third (5:4) at ≈ 386.1 cents (−0.2 cents narrow),
    /// making Gamma the most accurate of the three Carlos scales for 5-limit harmony.
    /// Introduced by Wendy Carlos alongside Alpha and Beta (1987).
    ///
    /// Does not support standard pitch notation (non-octave interval of equivalence).
    public static var carlosGamma: EqualTemperament {
        .carlosGamma
    }

    /// 12-EDO: 12 equal divisions of the octave.
    ///
    /// Each step (semitone) is ¹²√2 ≈ 100 cents. The standard tuning system of Western
    /// music since the late Baroque period.
    ///
    /// Fully supports standard pitch notation.
    public static var edo12: EqualTemperament {
        .edo12
    }

    /// 19-EDO: 19 equal divisions of the octave.
    ///
    /// Each step is ¹⁹√2 ≈ 63.158 cents. Closely approximates 1/3-comma meantone and
    /// provides excellent major thirds (≈ 378.947 cents vs. pure 386.314 cents). Noted
    /// by Guillaume Costeley (1570) and Salinas (1577).
    ///
    /// Fully supports standard pitch notation.
    public static var edo19: EqualTemperament {
        .edo19
    }

    /// 22-EDO: 22 equal divisions of the octave.
    ///
    /// Each step is ²²√2 ≈ 54.545 cents. A “superpyth” temperament that tempers out the
    /// diaschisma (2048:2025). Advocated by Paul Erlich for its efficient approximations
    /// of 7-limit harmony.
    ///
    /// Standard pitch notation support is partial; its “superpyth” structure means some
    /// pitch-class spellings produce unexpected interval relationships.
    public static var edo22: EqualTemperament {
        .edo22
    }

    /// 24-EDO: 24 equal divisions of the octave (quarter-tone).
    ///
    /// Each step is ²⁴√2 ≈ 50 cents. The standard system for Arabic classical music and
    /// used by many 20th-century Western composers (e.g., Hába, Wyschnegradsky).
    ///
    /// Standard pitch notation support is partial; quarter-tone pitches have no standard
    /// spelling and cannot be represented by the 35 available pitch classes.
    public static var edo24: EqualTemperament {
        .edo24
    }

    /// 31-EDO: 31 equal divisions of the octave.
    ///
    /// Each step is ³¹√2 ≈ 38.710 cents. Closely approximates 1/4-comma meantone and
    /// provides near-pure major thirds (≈ 387.097 cents). Associated with Christiaan
    /// Huygens (1661) and Adriaan Fokker (1955).
    ///
    /// Fully supports standard pitch notation.
    public static var edo31: EqualTemperament {
        .edo31
    }

    /// 53-EDO: 53 equal divisions of the octave.
    ///
    /// Each step (Holdrian comma) is ⁵³√2 ≈ 22.642 cents. Provides excellent
    /// approximations of 5-limit just intonation; the Pythagorean comma is almost exactly
    /// 3 steps (3 × 22.642 ≈ 23.460 cents vs. 23.460 cents). Used in Ottoman and Chinese
    /// theory.
    ///
    /// Does not fully support standard pitch notation; 53 distinct pitches per octave
    /// exceed the 35-pitch-class maximum (7 letters × 5 accidentals).
    public static var edo53: EqualTemperament {
        .edo53
    }
}

// MARK: -

extension EqualTemperament {

    // MARK: Fileprivate Type Properties

    fileprivate static let bohlenPierce = EqualTemperament(divisions: 13,
                                                           equivalenceRatio: .tritave)
    fileprivate static let carlosAlpha  = EqualTemperament(divisions: 9,
                                                           equivalenceRatio: pureFifth)
    fileprivate static let carlosBeta   = EqualTemperament(divisions: 11,
                                                           equivalenceRatio: pureFifth)
    fileprivate static let carlosGamma  = EqualTemperament(divisions: 20,
                                                           equivalenceRatio: pureFifth)
    fileprivate static let edo12        = EqualTemperament(divisions: 12)
    fileprivate static let edo19        = EqualTemperament(divisions: 19)
    fileprivate static let edo22        = EqualTemperament(divisions: 22)
    fileprivate static let edo24        = EqualTemperament(divisions: 24)
    fileprivate static let edo31        = EqualTemperament(divisions: 31)
    fileprivate static let edo53        = EqualTemperament(divisions: 53)
}

// MARK: - Private Constants

private let pureFifth = Ratio(3, 2)
