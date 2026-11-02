// © 2026 John Gary Pusey (see LICENSE.md)

extension KeyboardLayout {

    // MARK: Public Nested Types

    /// The reason a keyboard layout is invalid, reported by
    /// ``TuningError/invalidKeyboardLayout(_:)``.
    ///
    /// Some problems are found when the layout is created; the rest are found when a converter is
    /// created, once the tuning system is known. Slot indexes refer to the array in the layout’s
    /// ``KeyboardLayout/definition``.
    public enum Problem {

        /// Two slots of a pitch-class layout sound the same pitch in the tuning system; `index` is
        /// the later slot.
        case coincidentSlots(index: Int)

        /// Two pitch-class or degree slots name the same value; `index` is the later slot.
        case duplicateSlot(index: Int)

        /// The equivalence ratio of a raw-ratio layout is not greater than 1.
        case invalidEquivalenceRatio

        /// A frequency layout does not have exactly 128 elements.
        case invalidFrequencyCount

        /// A ratio in a raw-ratio layout is not less than the equivalence ratio.
        case invalidRatio(index: Int)

        /// Every element of a frequency layout is `nil`.
        case noMappedKeys

        /// The layout has the wrong shape for a pitch speller: it doesn’t have 12 slots per
        /// period with an octave period, or it is a frequency layout.
        case notTwelveKeysPerOctave

        /// A spelling converter was created without a pitch speller, but the layout is not a
        /// pitch-class layout, so it can’t spell its own keys.
        case pitchClassLayoutRequired

        /// A converter initializer that takes a tuning system was given a raw-ratio or frequency
        /// layout, which would ignore it.
        case rawLayoutNotAllowed

        /// The converter initializer that takes no tuning system was given a layout that isn’t a
        /// raw-ratio or frequency layout.
        case rawLayoutRequired

        /// The degrees of a degree layout don’t ascend, wrapping at most once.
        case slotOutOfOrder(index: Int)

        /// A slot of a pitch-class layout reaches or passes the anchor’s pitch a period up.
        case slotOutsidePeriod(index: Int)

        /// The anchor slot (slot 0) is unmapped or missing.
        case unmappedAnchor

        /// The reference note falls on an unmapped slot.
        case unmappedReference

        /// A degree is negative, or the tuning system has no such degree.
        case unsupportedDegree(index: Int)
    }
}

// MARK: -

extension KeyboardLayout.Problem {

    // MARK: Internal Instance Properties

    internal var message: String {
        switch self {
        case let .coincidentSlots(index):
            "slot \(index) sounds the same pitch as an earlier slot"

        case let .duplicateSlot(index):
            "slot \(index) has the same value as an earlier slot"

        case .invalidEquivalenceRatio:
            "equivalence ratio is not greater than 1"

        case .invalidFrequencyCount:
            "frequency layout does not have exactly 128 elements"

        case let .invalidRatio(index):
            "ratio in slot \(index) is not less than the equivalence ratio"

        case .noMappedKeys:
            "no key is mapped"

        case .notTwelveKeysPerOctave:
            "layout does not have 12 keys per octave"

        case .pitchClassLayoutRequired:
            "a pitch-class layout is required without a pitch speller"

        case .rawLayoutNotAllowed:
            "a raw layout cannot be used with a tuning system and pitch standard"

        case .rawLayoutRequired:
            "a raw layout is required without a tuning system and pitch standard"

        case let .slotOutOfOrder(index):
            "slot \(index) is out of order"

        case let .slotOutsidePeriod(index):
            "slot \(index) lies outside the period"

        case .unmappedAnchor:
            "anchor slot is unmapped"

        case .unmappedReference:
            "reference note is unmapped"

        case let .unsupportedDegree(index):
            "degree in slot \(index) is not supported"
        }
    }
}

// MARK: - Equatable

extension KeyboardLayout.Problem: Equatable {
}

// MARK: - Hashable

extension KeyboardLayout.Problem: Hashable {
}

// MARK: - Sendable

extension KeyboardLayout.Problem: Sendable {
}
