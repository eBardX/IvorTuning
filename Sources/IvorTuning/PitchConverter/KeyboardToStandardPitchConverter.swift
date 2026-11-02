// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A converter from MIDI note numbers (``NoteNumber``) to standard notation pitches (``Pitch``),
/// using a pitch speller or a pitch-class keyboard layout.
///
/// With a ``PitchSpeller``, the speller spells, even when a layout has spellings of its own; a
/// speller is allowed only on a layout with 12 keys per octave, the shape it assumes. A
/// pitch-class layout used without a speller spells each key with its own fixed name, through
/// ``KeyboardLayoutSpeller``. Either way, the layout decides which keys are mapped, and an unmapped
/// key converts to `nil`. No frequencies are produced.
///
/// A context-aware speller such as ``MeredithPitchSpeller`` needs the whole passage, so convert a
/// sequence with ``convert(_:)-([NoteNumber])``. Converting a single note number gives it no
/// context: with ``MeredithPitchSpeller``, a lone note always gets the default spelling — naturals
/// for white keys, and B♭, C♯, E♭, F♯ and G♯ for black keys.
public struct KeyboardToStandardPitchConverter<Speller: PitchSpeller> {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard layout and pitch speller.
    ///
    /// The layout decides which keys are mapped; the speller spells them.
    ///
    /// - Parameter keyboardLayout: A pitch-class, degree or raw-ratio layout with 12 slots per
    ///                             period. A raw-ratio layout’s period must also be an octave;
    ///                             a degree layout’s period can’t be checked without a tuning
    ///                             system.
    /// - Parameter pitchSpeller:   The pitch speller that spells the keys.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` with
    ///             ``KeyboardLayout/Problem/notTwelveKeysPerOctave`` if `keyboardLayout` is a
    ///             frequency layout or doesn’t have 12 slots per octave.
    public init(keyboardLayout: KeyboardLayout,
                pitchSpeller: Speller) throws(TuningError) {
        guard keyboardLayout.hasTwelveKeysPerOctave(period: nil)
        else { throw .invalidKeyboardLayout(.notTwelveKeysPerOctave) }

        self.init(mappedKeys: keyboardLayout.mappedKeys,
                  pitchSpeller: pitchSpeller)
    }

    /// Creates a converter with the given pitch speller, for the usual piano numbering.
    ///
    /// The speller is assumed to work in 12-tone equal temperament piano numbering, with every key
    /// mapped. This behaves like ``init(keyboardLayout:pitchSpeller:)`` with
    /// ``KeyboardLayout/piano``.
    ///
    /// - Parameter pitchSpeller:   The pitch speller that spells the keys.
    public init(pitchSpeller: Speller) {
        self.init(mappedKeys: Array(repeating: true, count: 128),
                  pitchSpeller: pitchSpeller)
    }

    // MARK: Private Initializers

    private init(mappedKeys: [Bool],
                 pitchSpeller: Speller) {
        self.mappedKeys = mappedKeys
        self.pitchSpeller = pitchSpeller
    }

    // MARK: Private Instance Properties

    // Which keys can be converted, indexed by note number.
    private let mappedKeys: [Bool]
    private let pitchSpeller: Speller
}

// MARK: -

extension KeyboardToStandardPitchConverter where Speller == MeredithPitchSpeller {

    // MARK: Public Initializers

    /// Creates a converter for the usual piano numbering, spelled with ``MeredithPitchSpeller``.
    public init() {
        self.init(pitchSpeller: MeredithPitchSpeller())
    }
}

// MARK: -

extension KeyboardToStandardPitchConverter where Speller == KeyboardLayoutSpeller {

    // MARK: Public Initializers

    /// Creates a converter that spells each key with the given pitch-class layout’s own spelling.
    ///
    /// The spelling is fixed and context-free: with ``KeyboardLayout/piano``, key 63 is always E♭4,
    /// never D♯4. Pass a ``PitchSpeller`` to ``init(keyboardLayout:pitchSpeller:)`` for
    /// context-aware spelling.
    ///
    /// Each key’s octave comes from the layout’s placement rule, which depends on how the
    /// spellings sound in `tuningSystem`: each mapped slot takes the lowest octave of its pitch
    /// class that sounds above the previous mapped slot. So a final C♭ in a C-to-C layout is C♭5, and
    /// a key spells exactly as ``AbsoluteToStandardPitchConverter`` spells it with the same layout
    /// and tuning system. No frequencies are produced, so no pitch standard is needed. A key whose
    /// octave lies outside the range of ``Pitch/Octave`` converts to `nil`.
    ///
    /// - Parameter keyboardLayout: A pitch-class layout, of any size.
    /// - Parameter tuningSystem:   The tuning system that places the keys. Must support standard
    ///                             pitch notation.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `keyboardLayout` is not a
    ///             pitch-class layout (``KeyboardLayout/Problem/pitchClassLayoutRequired``) or is
    ///             invalid in `tuningSystem`, or ``TuningError/unsupportedStandardConversion`` if
    ///             `tuningSystem` does not support standard pitch notation.
    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem) throws(TuningError) {
        guard case .pitchClasses = keyboardLayout.definition
        else { throw .invalidKeyboardLayout(.pitchClassLayoutRequired) }

        // Placement doesn't depend on the pitch standard, so any one will do.
        let pitches = try KeyboardMap(keyboardLayout: keyboardLayout,
                                      tuningSystem: tuningSystem,
                                      pitchStandard: .a440).pitches.require()

        self.init(mappedKeys: pitches.map { $0 != nil },
                  pitchSpeller: KeyboardLayoutSpeller(pitches: pitches))
    }
}

// MARK: - PitchConverter

extension KeyboardToStandardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    /// Returns the spelled pitch of the given key, with no musical context.
    ///
    /// A context-aware speller sees only this one note, so prefer
    /// ``convert(_:)-([NoteNumber])`` for a passage.
    ///
    /// - Parameter noteNumber: The MIDI note number to convert.
    ///
    /// - Returns:  The spelled pitch, or `nil` if the key is unmapped.
    public func convert(_ noteNumber: NoteNumber) -> Pitch? {
        convert([noteNumber])[0]
    }

    /// Returns the spelled pitch of each key, spelling the whole sequence together.
    ///
    /// - Parameter noteNumbers:    The MIDI note numbers to convert, in performance order: by
    ///                             onset time, then from low to high within a chord.
    ///
    /// - Returns:  The spelled pitches, index-aligned with `noteNumbers`. An element is `nil` if
    ///             its key is unmapped.
    public func convert(_ noteNumbers: [NoteNumber]) -> [Pitch?] {
        pitchSpeller.spellMapped(noteNumbers.map { mappedKeys[Int($0.uintValue)] ? $0 : nil })
    }
}
