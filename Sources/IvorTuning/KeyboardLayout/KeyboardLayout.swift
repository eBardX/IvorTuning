// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

private import XestiNumbers

/// The arrangement of pitches across the keys of a MIDI keyboard.
///
/// A layout describes only which element of a tuning system each key plays. The scale comes from
/// a ``TuningSystem`` and the tuning anchor from a ``PitchStandard``, both supplied to the
/// converter that uses the layout, so the three can’t disagree.
///
/// There are four kinds of layout, one per initializer:
///
/// - **Pitch-class layouts** (``init(pitchClasses:anchorNote:anchorOctave:)``) name each key by
///   its spelled pitch class, for tuning systems that support standard notation.
/// - **Degree layouts** (``init(degrees:anchorNote:referenceNote:)``) name each key by a degree
///   of the tuning system, for tuning systems without standard notation.
/// - **Raw-ratio layouts** (``init(ratios:equivalenceRatio:anchorNote:referenceNote:referenceFrequency:)``)
///   give each key an explicit ratio and tune themselves. They are intended for `.kbm`/`.scl`
///   import.
/// - **Frequency layouts** (``init(frequencies:)``) give every MIDI note number an explicit
///   frequency, with no repeating pattern. They are intended for per-key tuning tables.
///
/// Raw-ratio and frequency layouts together are the *raw* layouts: they hold frequencies
/// themselves rather than taking them from a tuning system and pitch standard.
///
/// In the three patterned kinds, slot `i` is key `anchorNote + i` in every period, so the list
/// order is the keyboard’s physical left-to-right order, and the pattern repeats outward from
/// `anchorNote`. A `nil` slot is an unmapped key. Slot 0 must be mapped, because it defines the
/// anchor.
///
/// Every initializer validates what it can without a tuning system and throws
/// ``TuningError/invalidKeyboardLayout(_:)`` on failure. Checks that depend on the tuning system
/// run when a converter is created.
public struct KeyboardLayout {

    // MARK: Public Initializers

    /// Creates a layout from a definition, with the same validation as the other initializers.
    ///
    /// - Parameter definition: The definition of the layout.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `definition` is invalid.
    public init(_ definition: Definition) throws(TuningError) {
        if let problem = Self._problem(in: definition) {
            throw .invalidKeyboardLayout(problem)
        }

        self.definition = definition
    }

    /// Creates a layout whose keys are described by degrees of the tuning system, for tuning
    /// systems without standard notation.
    ///
    /// Each element is the degree of the tuning system its key plays, counted from 0 (the unison)
    /// within one period. Key `anchorNote` sounds `degrees[0]`, and each later mapped slot takes
    /// the lowest period of its degree that sounds above the previous mapped slot. Key
    /// `referenceNote` sounds the pitch standard’s frequency; the pitch standard’s pitch is
    /// ignored.
    ///
    /// `degrees[0]` may be any degree, not only 0, and the layout need not contain degree 0 at
    /// all. For example, `[5, 7, 9, 0, 2]` puts degree 5 on `anchorNote`, and degree 0 three keys
    /// higher, in the next period.
    ///
    /// - Parameter degrees:        One degree per key in a period, in ascending order of sound,
    ///                             wrapping at most once. `nil` means the key is unmapped.
    /// - Parameter anchorNote:     The MIDI note number that sounds `degrees[0]`. Defaults to 60.
    /// - Parameter referenceNote:  The MIDI note number that sounds the pitch standard’s
    ///                             frequency. Must fall on a mapped key. Defaults to 69.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `degrees[0]` is unmapped, a degree
    ///             is negative or appears twice, the degrees don’t ascend, or `referenceNote`
    ///             falls on an unmapped key.
    public init(degrees: [Int?],
                anchorNote: NoteNumber = 60,
                referenceNote: NoteNumber = 69) throws(TuningError) {
        try self.init(.degrees(degrees,
                               anchorNote: anchorNote,
                               referenceNote: referenceNote))
    }

    /// Low level: creates a layout with an explicit frequency for every MIDI note number, with no
    /// repeating pattern.
    ///
    /// Element `n` is the frequency of MIDI note number `n`. The frequencies need not ascend, and
    /// two keys may sound the same pitch. Intended for per-key tuning tables, such as a MIDI
    /// Tuning Standard bulk dump.
    ///
    /// - Parameter frequencies:    Exactly 128 frequencies, one per MIDI note number. `nil` means
    ///                             the key is unmapped.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `frequencies` does not have exactly
    ///             128 elements, or if every element is `nil`.
    public init(frequencies: [Frequency?]) throws(TuningError) {
        try self.init(.frequencies(frequencies))
    }

    /// Creates a layout whose keys are described by spelled pitch class, for tuning systems that
    /// support standard notation.
    ///
    /// Key `anchorNote` sounds `pitchClasses[0]` in SPN octave `anchorOctave`. Each later mapped
    /// slot takes the lowest octave of its pitch class that sounds above the previous mapped slot,
    /// in the tuning system the layout is used with, so a final C♭ slot in a C-to-C layout sounds
    /// in the octave above.
    ///
    /// `pitchClasses[0]` may be any pitch class, not only C, and the layout need not contain C at
    /// all. For example, `[.a, .bFlat, .b, .c, …]` with `anchorNote: 57` and `anchorOctave: 3`
    /// puts A3 on key 57, and C4 three keys higher.
    ///
    /// Whether the slots ascend in sound depends on the tuning system, so it is checked when a
    /// converter is created, not here.
    ///
    /// - Parameter pitchClasses:   One pitch class per key in a period, in ascending order of
    ///                             sound. `nil` means the key is unmapped.
    /// - Parameter anchorNote:     The MIDI note number that sounds `pitchClasses[0]`. Defaults
    ///                             to 60.
    /// - Parameter anchorOctave:   The SPN octave of `pitchClasses[0]` on `anchorNote`. Defaults
    ///                             to 4.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `pitchClasses[0]` is unmapped or a
    ///             pitch class appears twice.
    public init(pitchClasses: [PitchClass?],
                anchorNote: NoteNumber = 60,
                anchorOctave: Pitch.Octave = 4) throws(TuningError) {
        try self.init(.pitchClasses(pitchClasses,
                                    anchorNote: anchorNote,
                                    anchorOctave: anchorOctave))
    }

    /// Low level: creates a layout whose keys are described by explicit ratios, tuned
    /// independently of any tuning system or pitch standard.
    ///
    /// Each element is the position of its key within one period, in [1, `equivalenceRatio`).
    /// Slot `i` in period `p` sounds `ratios[i] × equivalenceRatio^p`, and key `referenceNote`
    /// sounds `referenceFrequency`. Only the ratios’ relative values matter, so `ratios[0]` need
    /// not be the unison, and the layout need not contain the unison at all. The ratios need not
    /// ascend, and two keys may sound the same pitch. Intended for `.kbm`/`.scl` import.
    ///
    /// - Parameter ratios:             One ratio per key in a period. `nil` means the key is
    ///                                 unmapped.
    /// - Parameter equivalenceRatio:   The period of the pattern. Must be greater than 1.
    /// - Parameter anchorNote:         The MIDI note number that sounds `ratios[0]`. Defaults to
    ///                                 60.
    /// - Parameter referenceNote:      The MIDI note number that sounds `referenceFrequency`. Must
    ///                                 fall on a mapped key. Defaults to 69.
    /// - Parameter referenceFrequency: The frequency of `referenceNote`.
    ///
    /// - Throws:   ``TuningError/invalidKeyboardLayout(_:)`` if `ratios[0]` is unmapped,
    ///             `equivalenceRatio` is not greater than 1, a ratio is not less than
    ///             `equivalenceRatio`, or `referenceNote` falls on an unmapped key.
    public init(ratios: [Ratio?],
                equivalenceRatio: Ratio,
                anchorNote: NoteNumber = 60,
                referenceNote: NoteNumber = 69,
                referenceFrequency: Frequency) throws(TuningError) {
        try self.init(.ratios(ratios,
                              equivalenceRatio: equivalenceRatio,
                              anchorNote: anchorNote,
                              referenceNote: referenceNote,
                              referenceFrequency: referenceFrequency))
    }

    // MARK: Public Instance Properties

    /// The definition this layout was created from: exactly the arguments of one of its
    /// initializers.
    public let definition: Definition
}

// MARK: -

extension KeyboardLayout {

    // MARK: Public Instance Properties

    /// The number of keys in one period: the definition’s array count, or 128 for a frequency
    /// layout.
    public var keysPerPeriod: Int {
        switch definition {
        case let .degrees(degrees, _, _):
            degrees.count

        case let .frequencies(frequencies):
            frequencies.count

        case let .pitchClasses(pitchClasses, _, _):
            pitchClasses.count

        case let .ratios(ratios, _, _, _, _):
            ratios.count
        }
    }

    // MARK: Internal Instance Properties

    // A raw layout (raw-ratio or frequency) holds frequencies itself rather than taking them from
    // a tuning system and pitch standard.
    internal var isRaw: Bool {
        switch definition {
        case .degrees,
             .pitchClasses:
            false

        case .frequencies,
             .ratios:
            true
        }
    }

    // MARK: Private Type Methods

    private static func _anchorProblem(in slots: [(some Any)?]) -> Problem? {
        guard !slots.isEmpty,
              slots[0] != nil
        else { return .unmappedAnchor }

        return nil
    }

    private static func _degreeOrderProblem(in degrees: [Int?]) -> Problem? {
        var first: Int?
        var previous: Int?
        var wrapped = false

        for (index, degree) in degrees.enumerated() {
            guard let degree
            else { continue }

            if let previous {
                if degree < previous {
                    if wrapped {
                        return .slotOutOfOrder(index: index)
                    }

                    wrapped = true
                }

                // After the wrap, a degree at or above the first one reaches the anchor a period
                // up.
                if wrapped,
                   let first,
                   degree >= first {
                    return .slotOutOfOrder(index: index)
                }
            } else {
                first = degree
            }

            previous = degree
        }

        return nil
    }

    private static func _degreesProblem(in degrees: [Int?],
                                        anchorNote: NoteNumber,
                                        referenceNote: NoteNumber) -> Problem? {
        if let problem = _anchorProblem(in: degrees) {
            return problem
        }

        if let index = degrees.firstIndex(where: { ($0 ?? 0) < 0 }) {
            return .unsupportedDegree(index: index)
        }

        return _duplicateProblem(in: degrees)
            ?? _degreeOrderProblem(in: degrees)
            ?? _referenceProblem(in: degrees,
                                 anchorNote: anchorNote,
                                 referenceNote: referenceNote)
    }

    private static func _duplicateProblem<T: Hashable>(in slots: [T?]) -> Problem? {
        var seen = Set<T>()

        for (index, slot) in slots.enumerated() {
            guard let slot
            else { continue }

            if !seen.insert(slot).inserted {
                return .duplicateSlot(index: index)
            }
        }

        return nil
    }

    private static func _frequenciesProblem(in frequencies: [Frequency?]) -> Problem? {
        guard frequencies.count == 128
        else { return .invalidFrequencyCount }

        guard frequencies.contains(where: { $0 != nil })
        else { return .noMappedKeys }

        return nil
    }

    private static func _problem(in definition: Definition) -> Problem? {
        switch definition {
        case let .degrees(degrees, anchorNote, referenceNote):
            _degreesProblem(in: degrees,
                            anchorNote: anchorNote,
                            referenceNote: referenceNote)

        case let .frequencies(frequencies):
            _frequenciesProblem(in: frequencies)

        case let .pitchClasses(pitchClasses, _, _):
            _anchorProblem(in: pitchClasses)
                ?? _duplicateProblem(in: pitchClasses)

        case let .ratios(ratios, equivalenceRatio, anchorNote, referenceNote, _):
            _ratiosProblem(in: ratios,
                           equivalenceRatio: equivalenceRatio,
                           anchorNote: anchorNote,
                           referenceNote: referenceNote)
        }
    }

    private static func _ratiosProblem(in ratios: [Ratio?],
                                       equivalenceRatio: Ratio,
                                       anchorNote: NoteNumber,
                                       referenceNote: NoteNumber) -> Problem? {
        if let problem = _anchorProblem(in: ratios) {
            return problem
        }

        guard equivalenceRatio > .unison
        else { return .invalidEquivalenceRatio }

        if let index = ratios.firstIndex(where: { $0.map { $0 >= equivalenceRatio } ?? false }) {
            return .invalidRatio(index: index)
        }

        return _referenceProblem(in: ratios,
                                 anchorNote: anchorNote,
                                 referenceNote: referenceNote)
    }

    private static func _referenceProblem(in slots: [(some Any)?],
                                          anchorNote: NoteNumber,
                                          referenceNote: NoteNumber) -> Problem? {
        let count = slots.count
        let offset = Int(referenceNote.uintValue) - Int(anchorNote.uintValue)
        let index = ((offset % count) + count) % count

        return slots[index] == nil ? .unmappedReference : nil
    }
}

// MARK: - Codable

extension KeyboardLayout: Codable {

    // MARK: Public Initializers

    /// Creates a layout by decoding its definition from the provided decoder.
    ///
    /// The decoded definition is validated exactly as ``init(_:)`` validates it.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorrupted` if the decoded definition is not a valid layout.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let definition = try container.decode(Definition.self)

        do {
            try self.init(definition)
        } catch {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid keyboard layout: \(error.message)")
        }
    }

    // MARK: Public Instance Methods

    /// Encodes this layout’s definition into the provided encoder.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(definition)
    }
}

// MARK: - Equatable

extension KeyboardLayout: Equatable {
}

// MARK: - Hashable

extension KeyboardLayout: Hashable {
}

// MARK: - Sendable

extension KeyboardLayout: Sendable {
}
