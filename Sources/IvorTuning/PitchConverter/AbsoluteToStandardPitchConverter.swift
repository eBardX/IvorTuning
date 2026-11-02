// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A converter from absolute frequency pitches (``Frequency``) to standard notation pitches
/// (``Pitch``), using a keyboard layout and a pitch speller.
///
/// Each frequency first converts to the key that sounds nearest, as in
/// ``AbsoluteToKeyboardPitchConverter``; then the key is spelled. With a ``PitchSpeller``, the
/// speller spells, even when the layout has spellings of its own; a speller is allowed only on a
/// layout with 12 keys per octave, the shape it assumes. A pitch-class layout used without a
/// speller spells each key with its own fixed name, through ``KeyboardLayoutSpeller``.
///
/// A context-aware speller such as ``MeredithPitchSpeller`` needs the whole passage, so convert a
/// sequence with ``convert(_:)-([Frequency])``. Converting a single frequency gives it no context:
/// with ``MeredithPitchSpeller``, a lone note always gets the default spelling — naturals for white
/// keys, and B♭, C♯, E♭, F♯ and G♯ for black keys.
public struct AbsoluteToStandardPitchConverter<Speller: PitchSpeller> {

    // MARK: Public Initializers

    /// Creates a converter with the given raw keyboard layout, which tunes its own keys, and the
    /// given pitch speller.
    ///
    /// - Parameter keyboardLayout: A raw-ratio layout with 12 slots per octave.
    /// - Parameter pitchSpeller:   The pitch speller that spells the keys.
    /// - Parameter keyMatching:    How strictly a frequency must match a key. Defaults to
    ///                             `.nearest`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` with
    ///             ``KeyboardLayout/Problem/rawLayoutRequired`` for a pitch-class or degree layout,
    ///             or ``KeyboardLayout/Problem/notTwelveKeysPerOctave`` for a frequency layout or a
    ///             raw-ratio layout without 12 slots per octave.
    public init(keyboardLayout: KeyboardLayout,
                pitchSpeller: Speller,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        let keyboardMap = try KeyboardMap(rawLayout: keyboardLayout)

        guard keyboardLayout.hasTwelveKeysPerOctave(period: nil)
        else { throw .invalidKeyboardLayout(.notTwelveKeysPerOctave) }

        self.init(keyboardMap: keyboardMap,
                  keyMatching: keyMatching,
                  pitchSpeller: pitchSpeller,
                  spellableKeys: nil)
    }

    /// Creates a converter with the given keyboard layout, tuned by the given tuning system and
    /// pitch standard, and the given pitch speller.
    ///
    /// - Parameter keyboardLayout: A pitch-class or degree layout with 12 slots per octave.
    /// - Parameter tuningSystem:   The tuning system that tunes the keys.
    /// - Parameter pitchStandard:  The pitch standard that anchors the tuning. Defaults to `.a440`.
    /// - Parameter pitchSpeller:   The pitch speller that spells the keys.
    /// - Parameter keyMatching:    How strictly a frequency must match a key. Defaults to
    ///                             `.nearest`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `keyboardLayout` is a raw layout
    ///             (``KeyboardLayout/Problem/rawLayoutNotAllowed``), doesn’t have 12 slots per
    ///             octave (``KeyboardLayout/Problem/notTwelveKeysPerOctave``), or is invalid in
    ///             `tuningSystem`; or ``TuningError/unsupportedStandardConversion`` for a
    ///             pitch-class layout used with a tuning system that does not support standard
    ///             notation.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440,
                pitchSpeller: Speller,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        guard !keyboardLayout.isRaw
        else { throw .invalidKeyboardLayout(.rawLayoutNotAllowed) }

        guard keyboardLayout.hasTwelveKeysPerOctave(period: tuningSystem.equivalenceRatio)
        else { throw .invalidKeyboardLayout(.notTwelveKeysPerOctave) }

        try self.init(keyboardMap: KeyboardMap(keyboardLayout: keyboardLayout,
                                               tuningSystem: tuningSystem,
                                               pitchStandard: pitchStandard),
                      keyMatching: keyMatching,
                      pitchSpeller: pitchSpeller,
                      spellableKeys: nil)
    }

    // MARK: Private Initializers

    private init(keyboardMap: KeyboardMap,
                 keyMatching: KeyMatching,
                 pitchSpeller: Speller,
                 spellableKeys: [Bool]?) {
        self.keyboardMap = keyboardMap
        self.keyMatching = keyMatching
        self.pitchSpeller = pitchSpeller
        self.spellableKeys = spellableKeys
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let keyMatching: KeyMatching
    private let pitchSpeller: Speller

    // Indexed by note number; `nil` if the speller can spell every key.
    private let spellableKeys: [Bool]?
}

// MARK: -

extension AbsoluteToStandardPitchConverter where Speller == MeredithPitchSpeller {

    // MARK: Public Initializers

    /// Creates a converter for the usual piano — ``KeyboardLayout/piano``, 12-tone equal
    /// temperament, and ``PitchStandard/a440`` — spelled with ``MeredithPitchSpeller``.
    public init() {
        self = (try? Self(keyboardLayout: .piano,
                          tuningSystem: EqualTemperament.edo12,
                          pitchSpeller: MeredithPitchSpeller())).require()
    }
}

// MARK: -

extension AbsoluteToStandardPitchConverter where Speller == KeyboardLayoutSpeller {

    // MARK: Public Initializers

    /// Creates a converter with the given pitch-class layout, tuned by the given tuning system and
    /// pitch standard, that spells each key with the layout’s own spelling.
    ///
    /// The spelling is fixed and context-free: with ``KeyboardLayout/piano``, the key between D and
    /// E is always E♭, never D♯. Pass a ``PitchSpeller`` to the other initializers for
    /// context-aware spelling.
    ///
    /// - Parameter keyboardLayout: A pitch-class layout.
    /// - Parameter tuningSystem:   The tuning system that tunes the keys. Must support standard
    ///                             pitch notation.
    /// - Parameter pitchStandard:  The pitch standard that anchors the tuning. Defaults to `.a440`.
    /// - Parameter keyMatching:    How strictly a frequency must match a key. Defaults to
    ///                             `.nearest`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `keyboardLayout` is not a
    ///             pitch-class layout (``KeyboardLayout/Problem/pitchClassLayoutRequired``) or is
    ///             invalid in `tuningSystem`, or ``TuningError/unsupportedStandardConversion`` if
    ///             `tuningSystem` does not support standard pitch notation.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440,
                keyMatching: KeyMatching = .nearest) throws(TuningError) {
        guard case .pitchClasses = keyboardLayout.definition
        else { throw .invalidKeyboardLayout(.pitchClassLayoutRequired) }

        let keyboardMap = try KeyboardMap(keyboardLayout: keyboardLayout,
                                          tuningSystem: tuningSystem,
                                          pitchStandard: pitchStandard)
        let pitches = keyboardMap.pitches.require()

        self.init(keyboardMap: keyboardMap,
                  keyMatching: keyMatching,
                  pitchSpeller: KeyboardLayoutSpeller(pitches: pitches),
                  spellableKeys: pitches.map { $0 != nil })
    }
}

// MARK: - PitchConverter

extension AbsoluteToStandardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the spelled pitch of the key nearest each frequency, spelling the whole sequence
    /// together.
    ///
    /// - Parameter frequencies:    The frequencies to convert, in performance order: by onset
    ///                             time, then from low to high within a chord.
    ///
    /// - Returns:  The spelled pitches, index-aligned with `frequencies`. An element is `nil` if
    ///             no key matches its frequency or its key can’t be spelled.
    public func convert(_ frequencies: [Frequency]) -> [Pitch?] {
        let noteNumbers = frequencies.map { frequency -> NoteNumber? in
            guard let noteNumber = keyboardMap.nearestKey(to: frequency,
                                                          keyMatching: keyMatching),
                  spellableKeys?[Int(noteNumber.uintValue)] ?? true
            else { return nil }

            return noteNumber
        }

        return pitchSpeller.spellMapped(noteNumbers)
    }

    /// Returns the spelled pitch of the key nearest the given frequency, with no musical context.
    ///
    /// A context-aware speller sees only this one note, so prefer
    /// ``convert(_:)-([Frequency])`` for a passage.
    ///
    /// - Parameter frequency:  The frequency to convert.
    ///
    /// - Returns:  The spelled pitch, or `nil` if no key matches `frequency` or its key can’t be
    ///             spelled.
    public func convert(_ frequency: Frequency) -> Pitch? {
        convert([frequency])[0]
    }
}
