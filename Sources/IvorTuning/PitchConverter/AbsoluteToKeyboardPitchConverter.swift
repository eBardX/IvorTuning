// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A converter from absolute frequency pitches (``Frequency``) to MIDI note numbers
/// (``NoteNumber``), using a keyboard layout.
///
/// Each frequency converts to the key that sounds nearest. A frequency lying equally near two keys
/// converts to the lower key.
///
/// A pitch-class or degree layout takes its key frequencies from a tuning system and pitch
/// standard, so it is used with ``init(keyboardLayout:tuningSystem:pitchStandard:keyMatching:)``.
/// A raw layout (raw-ratio or frequency) tunes itself, so it is used with
/// ``init(keyboardLayout:keyMatching:)``.
public struct AbsoluteToKeyboardPitchConverter {

    // MARK: Public Initializers

    /// Creates a converter for the usual piano: ``KeyboardLayout/piano``, 12-tone equal
    /// temperament, and ``PitchStandard/a440``.
    public init() {
        self = (try? Self(keyboardLayout: .piano,
                          tuningSystem: EqualTemperament.edo12)).require()
    }

    /// Creates a converter with the given raw keyboard layout, which tunes its own keys.
    ///
    /// - Parameter keyboardLayout: A raw-ratio or frequency layout.
    /// - Parameter keyMatching:    How strictly a frequency must match a key. Defaults to
    ///                             `.nearest`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` with
    ///             ``KeyboardLayout/Problem/rawLayoutRequired`` if `keyboardLayout` is a
    ///             pitch-class or degree layout.
    public init(keyboardLayout: KeyboardLayout,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        self.keyboardMap = try KeyboardMap(rawLayout: keyboardLayout)
        self.keyMatching = keyMatching
    }

    /// Creates a converter with the given keyboard layout, tuned by the given tuning system and
    /// pitch standard.
    ///
    /// - Parameter keyboardLayout: A pitch-class or degree layout.
    /// - Parameter tuningSystem:   The tuning system that tunes the keys.
    /// - Parameter pitchStandard:  The pitch standard that anchors the tuning. Defaults to `.a440`.
    /// - Parameter keyMatching:    How strictly a frequency must match a key. Defaults to
    ///                             `.nearest`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `keyboardLayout` is a raw layout
    ///             (``KeyboardLayout/Problem/rawLayoutNotAllowed``) or is invalid in
    ///             `tuningSystem`, or ``TuningError/unsupportedStandardConversion`` for a
    ///             pitch-class layout used with a tuning system that does not support standard
    ///             notation.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        guard !keyboardLayout.isRaw
        else { throw .invalidKeyboardLayout(.rawLayoutNotAllowed) }

        self.keyboardMap = try KeyboardMap(keyboardLayout: keyboardLayout,
                                           tuningSystem: tuningSystem,
                                           pitchStandard: pitchStandard)
        self.keyMatching = keyMatching
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let keyMatching: KeyMatching
}

// MARK: - PitchConverter

extension AbsoluteToKeyboardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the MIDI note number of the key that sounds nearest the given frequency.
    ///
    /// - Parameter frequency:  The frequency to convert.
    ///
    /// - Returns:  The nearest key, or `nil` if `frequency` lies beyond the lowest or highest key
    ///             by more than half the step to that key’s inner neighbor, or is farther from
    ///             every key than a ``KeyMatching/within(_:)`` tolerance.
    public func convert(_ frequency: Frequency) -> NoteNumber? {
        keyboardMap.nearestKey(to: frequency,
                               keyMatching: keyMatching)
    }
}
