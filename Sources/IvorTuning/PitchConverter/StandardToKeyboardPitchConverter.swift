// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// Converts standard notation pitches (``Pitch``) to MIDI note numbers (``NoteNumber``)
/// using a keyboard map, tuning system, and pitch standard.
///
/// Conversion is acoustic: the converter realizes each pitch as a frequency using the tuning system
/// and pitch standard, then picks the keyboard map’s nearest mapped note number. With the default
/// configuration — ``KeyboardMap/a440``, 12-tone equal temperament, and ``PitchStandard/a440`` —
/// this matches the usual piano key assignments, so B♯3 and C4 both convert to 60, and C♭4 to 59.
///
/// Because conversion goes through frequency, a pitch standard that differs from the keyboard
/// map’s reference transposes the result rather than being an error. For example, with
/// ``PitchStandard/a415`` and ``KeyboardMap/a440``, A4 converts to 68, the key that sounds closest
/// to 415 Hz. In tuning systems other than 12-tone equal temperament, a pitch may convert to a key
/// other than the one its spelling suggests: in quarter-comma meantone, B𝄪3 sounds about 45 cents
/// above C4 — nearer C4 than C♯4 — so it converts to 60, not 61.
public struct StandardToKeyboardPitchConverter {

    // MARK: Public Initializers

    /// Creates a converter for the usual piano key assignments: ``KeyboardMap/a440``, 12-tone equal
    /// temperament, and ``PitchStandard/a440``.
    public init() {
        self = (try? Self(keyboardMap: .a440,
                          tuningSystem: EqualTemperament.edo12)).require()
    }

    /// Creates a converter with the given keyboard map, tuning system, and pitch standard.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the key layout.
    /// - Parameter tuningSystem:   The tuning system used to map pitches to frequencies. Must
    ///                             support standard pitch notation.
    /// - Parameter pitchStandard:  The reference pitch and its frequency. Defaults to `.a440`.
    ///
    /// - Throws:   ``TuningError/emptyKeyboardMap`` if `keyboardMap` does not map any MIDI note
    ///             number, or ``TuningError/unsupportedStandardConversion`` if `tuningSystem` does
    ///             not support standard pitch notation.
    public init(keyboardMap: KeyboardMap,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440) throws(TuningError) {
        guard keyboardMap.hasMappedNotes
        else { throw TuningError.emptyKeyboardMap }

        self.keyboardMap = keyboardMap
        self.standardToAbsolute = try StandardToAbsolutePitchConverter(tuningSystem: tuningSystem,
                                                                       pitchStandard: pitchStandard)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let standardToAbsolute: StandardToAbsolutePitchConverter
}

// MARK: - PitchConverter

extension StandardToKeyboardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the MIDI note number nearest to the given standard pitch.
    ///
    /// - Parameter pitch:  The standard pitch to convert.
    ///
    /// - Returns:  The nearest mapped note number, or `nil` if `pitch` lies beyond the lowest or
    ///             highest mapped note by more than half the step to that note’s inner neighbor
    ///             (for example, C♭−1 and G♯9 with ``KeyboardMap/a440``).
    public func convert(_ pitch: Pitch) -> NoteNumber? {
        guard let frequency = standardToAbsolute.convert(pitch)
        else { return nil }

        return keyboardMap.unrealize(frequency: frequency)
    }
}
