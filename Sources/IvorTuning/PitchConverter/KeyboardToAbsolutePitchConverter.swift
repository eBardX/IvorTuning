// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A converter from MIDI note numbers (``NoteNumber``) to absolute frequency pitches
/// (``Frequency``), using a keyboard layout.
///
/// A pitch-class or degree layout takes its key frequencies from a tuning system and pitch
/// standard, so it is used with ``init(keyboardLayout:tuningSystem:pitchStandard:)``. A raw layout
/// (raw-ratio or frequency) tunes itself, so it is used with ``init(keyboardLayout:)``.
public struct KeyboardToAbsolutePitchConverter {

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
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` with
    ///             ``KeyboardLayout/Problem/rawLayoutRequired`` if `keyboardLayout` is a
    ///             pitch-class or degree layout.
    public init(keyboardLayout: KeyboardLayout) throws(TuningError) {
        self.keyboardMap = try KeyboardMap(rawLayout: keyboardLayout)
    }

    /// Creates a converter with the given keyboard layout, tuned by the given tuning system and
    /// pitch standard.
    ///
    /// - Parameter keyboardLayout: A pitch-class or degree layout.
    /// - Parameter tuningSystem:   The tuning system that tunes the keys.
    /// - Parameter pitchStandard:  The pitch standard that anchors the tuning. Defaults to `.a440`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `keyboardLayout` is a raw layout
    ///             (``KeyboardLayout/Problem/rawLayoutNotAllowed``) or is invalid in
    ///             `tuningSystem`, or ``TuningError/unsupportedStandardConversion`` for a
    ///             pitch-class layout used with a tuning system that does not support standard
    ///             notation.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440) throws(TuningError) {
        guard !keyboardLayout.isRaw
        else { throw .invalidKeyboardLayout(.rawLayoutNotAllowed) }

        self.keyboardMap = try KeyboardMap(keyboardLayout: keyboardLayout,
                                           tuningSystem: tuningSystem,
                                           pitchStandard: pitchStandard)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
}

// MARK: - PitchConverter

extension KeyboardToAbsolutePitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the frequency of the given key.
    ///
    /// - Parameter noteNumber: The MIDI note number to convert.
    ///
    /// - Returns:  The frequency of the key, or `nil` if the layout leaves it unmapped.
    public func convert(_ noteNumber: NoteNumber) -> Frequency? {
        keyboardMap.frequency(of: noteNumber)
    }
}
