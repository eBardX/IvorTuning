// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A converter from standard notation pitches (``Pitch``) to MIDI note numbers (``NoteNumber``),
/// using a keyboard layout, tuning system, and pitch standard.
///
/// Conversion is acoustic: the converter realizes each pitch as a frequency using the tuning system
/// and pitch standard, then picks the key of the layout that sounds nearest. The keys are tuned by
/// the same tuning system and pitch standard, so the pitch standard tunes the keyboard rather than
/// transposing it: with ``PitchStandard/a415``, A4 still converts to 69, and key 69 sounds 415 Hz.
///
/// With the default configuration — ``KeyboardLayout/piano``, 12-tone equal temperament, and
/// ``PitchStandard/a440`` — this matches the usual piano key assignments, so B♯3 and C4 both
/// convert to 60, and C♭4 to 59. With other tuning systems, a pitch may convert to a key other
/// than the one its spelling suggests: in quarter-comma meantone, B𝄪3 sounds about 45 cents above
/// C4 — nearer the C key than the C♯ key — so it converts to 60, not 61.
///
/// When a pitch lies equally near two keys of a pitch-class layout, it converts to the key whose
/// spelling shares its letter; otherwise, to the lower key.
public struct StandardToKeyboardPitchConverter {

    // MARK: Public Initializers

    /// Creates a converter for the usual piano key assignments: ``KeyboardLayout/piano``, 12-tone
    /// equal temperament, and ``PitchStandard/a440``.
    public init() {
        self = (try? Self(keyboardLayout: .piano,
                          tuningSystem: EqualTemperament.edo12)).require()
    }

    /// Creates a converter with the given keyboard layout, tuning system, and pitch standard.
    ///
    /// A raw layout (raw-ratio or frequency) tunes its own keys. The tuning system and pitch
    /// standard still realize each written pitch, so if they disagree with the layout’s own
    /// tuning, the result transposes. Prefer a pitch-class or degree layout when the tuning is one
    /// the library knows.
    ///
    /// - Parameter keyboardLayout: The keyboard layout.
    /// - Parameter tuningSystem:   The tuning system used to realize pitches and tune the keys.
    ///                             Must support standard pitch notation.
    /// - Parameter pitchStandard:  The reference pitch and its frequency. Defaults to `.a440`.
    /// - Parameter keyMatching:    How strictly a pitch must match a key. Defaults to `.nearest`.
    ///
    /// - Throws:   ``TuningError/unsupportedStandardConversion`` if `tuningSystem` does not support
    ///             standard pitch notation, or ``TuningError/invalidKeyboardLayout(_:)`` if
    ///             `keyboardLayout` is invalid in `tuningSystem`.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        self.keyMatching = keyMatching
        self.keyboardMap = try KeyboardMap(keyboardLayout: keyboardLayout,
                                           tuningSystem: tuningSystem,
                                           pitchStandard: pitchStandard)
        self.standardToAbsolute = try StandardToAbsolutePitchConverter(tuningSystem: tuningSystem,
                                                                       pitchStandard: pitchStandard)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let keyMatching: KeyMatching
    private let standardToAbsolute: StandardToAbsolutePitchConverter
}

// MARK: - PitchConverter

extension StandardToKeyboardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the MIDI note number of the key that sounds nearest the given standard pitch.
    ///
    /// - Parameter pitch:  The standard pitch to convert.
    ///
    /// - Returns:  The nearest key, or `nil` if `pitch` lies beyond the lowest or highest key by
    ///             more than half the step to that key’s inner neighbor (for example, C♭−1 and G♯9
    ///             with the default configuration), or is farther from every key than a
    ///             ``KeyMatching/within(_:)`` tolerance.
    public func convert(_ pitch: Pitch) -> NoteNumber? {
        guard let frequency = standardToAbsolute.convert(pitch)
        else { return nil }

        return keyboardMap.nearestKey(to: frequency,
                                      letter: pitch.letter,
                                      keyMatching: keyMatching)
    }
}
