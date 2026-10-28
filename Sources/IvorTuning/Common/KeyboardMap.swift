// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A map between MIDI note numbers and absolute frequencies.
///
/// `KeyboardMap` is the bridge for the `absolute ↔ keyboard` edge of
/// IvorTuning’s notation conversion graph. It encodes a repeating pitch pattern
/// applied across a MIDI keyboard layout and converts in both directions:
///
/// - ``realize(noteNumber:)`` and ``realize(noteDistance:)`` convert keyboard →
///   absolute.
/// - ``unrealize(frequency:)`` and ``unrealize(ratio:)`` convert absolute →
///   keyboard.
///
/// The keyboard map is defined by two independent anchors:
///
/// - **Intonation anchor** (`referenceNote` + `referenceFrequency`): fixes the
///   actual frequency of a specific MIDI note number.
/// - **Layout anchor** (`middleNote`): identifies the MIDI note number where
///   `ratios[0]` (the unison) is placed. The repeating pattern radiates outward
///   from here.
public struct KeyboardMap {

    // MARK: Public Initializers

    /// Creates a new keyboard map.
    ///
    /// - Parameter referenceNote:      The MIDI note number whose frequency is known.
    /// - Parameter referenceFrequency: The frequency of the reference note.
    /// - Parameter middleNote:         The MIDI note number where `ratios[0]`
    ///                                 (unison) is placed.
    /// - Parameter equivalenceRatio:   The interval of equivalence of the repeating pattern.
    /// - Parameter ratios:             The ratio for each key slot within one interval of
    ///                                 equivalence. `nil` means the key is unmapped.
    public init(referenceNote: NoteNumber,
                referenceFrequency: Frequency,
                middleNote: NoteNumber,
                equivalenceRatio: Ratio,
                ratios: [Ratio?]) {
        self.middleNote = middleNote
        self.equivalenceRatio = equivalenceRatio
        self.ratios = ratios
        self.referenceFrequency = referenceFrequency
        self.referenceNote = referenceNote
    }

    // MARK: Public Instance Properties

    /// The interval of equivalence of the repeating pattern.
    public let equivalenceRatio: Ratio

    /// The MIDI note number where `ratios[0]` (unison) is placed.
    public let middleNote: NoteNumber

    /// The ratio for each key slot within one interval of equivalence. `nil` means the key
    /// is unmapped.
    public let ratios: [Ratio?]

    /// The frequency of the reference note.
    public let referenceFrequency: Frequency

    /// The MIDI note number whose frequency is known.
    public let referenceNote: NoteNumber
}

// MARK: -

extension KeyboardMap {

    // MARK: Public Instance Methods

    /// Returns the frequency ratio for the given note distance, measured from
    /// `middleNote`.
    ///
    /// - Parameter noteDistance:   The distance in semitones above
    ///                             `middleNote`.
    ///
    /// - Returns:  The frequency ratio, or `nil` if the key at that distance is
    ///             unmapped.
    public func realize(noteDistance: NoteDistance) -> Ratio? {
        guard !ratios.isEmpty
        else { return nil }

        let (index, periods) = _decompose(Int(noteDistance.uintValue))

        guard let slotRatio = ratios[index]
        else { return nil }

        return Ratio(slotRatio.numberValue * exp(log(equivalenceRatio.numberValue) * Number(periods)))
    }

    /// Returns the frequency for the given note number.
    ///
    /// - Parameter noteNumber: The MIDI note number to convert.
    ///
    /// - Returns:  The frequency, or `nil` if the note number or the reference
    ///             note is unmapped.
    public func realize(noteNumber: NoteNumber) -> Frequency? {
        guard !ratios.isEmpty
        else { return nil }

        let (refIndex, refPeriods) = _decompose(Int(referenceNote.uintValue) - Int(middleNote.uintValue))

        guard let refSlotRatio = ratios[refIndex]
        else { return nil }

        let (index, periods) = _decompose(Int(noteNumber.uintValue) - Int(middleNote.uintValue))

        guard let slotRatio = ratios[index]
        else { return nil }

        let logPeriod = log(equivalenceRatio.numberValue)
        let targetNum = slotRatio.numberValue * exp(logPeriod * Number(periods))
        let refNum = refSlotRatio.numberValue * exp(logPeriod * Number(refPeriods))

        if targetNum > refNum {
            let ratio = Ratio(targetNum / refNum)

            return referenceFrequency.transposed(by: DirectedInterval(interval: ratio,
                                                                      direction: .ascending))
        } else if targetNum < refNum {
            let ratio = Ratio(refNum / targetNum)

            return referenceFrequency.transposed(by: DirectedInterval(interval: ratio,
                                                                      direction: .descending))
        } else {
            return referenceFrequency
        }
    }

    /// Returns the nearest mapped note number for the given frequency.
    ///
    /// A frequency below the lowest mapped note, or above the highest, still
    /// matches that note if it lies within half the step to the note’s inner
    /// neighbor; farther out, it matches nothing.
    ///
    /// - Parameter frequency:  The frequency to match.
    ///
    /// - Returns:  The nearest mapped note number, or `nil` if no note is
    ///             mapped or `frequency` is out of range.
    public func unrealize(frequency: Frequency) -> NoteNumber? {
        let candidates = (UInt(0)...127).compactMap { uintValue -> (NoteNumber, Number)? in
            guard let note = NoteNumber(uintValue: uintValue),
                  let realized = realize(noteNumber: note)
            else { return nil }

            return (note, realized.numberValue)
        }

        return Self._nearest(to: frequency.numberValue,
                             in: candidates)
    }

    /// Returns the nearest mapped note distance for the given frequency ratio.
    ///
    /// A ratio below the smallest mapped distance, or above the largest, still
    /// matches that distance if it lies within half the step to the distance’s
    /// inner neighbor; farther out, it matches nothing.
    ///
    /// - Parameter ratio:  The frequency ratio to match.
    ///
    /// - Returns:  The nearest mapped note distance, or `nil` if no distance is
    ///             mapped or `ratio` is out of range.
    public func unrealize(ratio: Ratio) -> NoteDistance? {
        let candidates = (UInt(0)...127).compactMap { uintValue -> (NoteDistance, Number)? in
            guard let distance = NoteDistance(uintValue: uintValue),
                  let realized = realize(noteDistance: distance)
            else { return nil }

            return (distance, realized.numberValue)
        }

        return Self._nearest(to: ratio.numberValue,
                             in: candidates)
    }

    // MARK: Internal Instance Properties

    /// A Boolean value indicating whether at least one MIDI note number is
    /// mapped to a frequency.
    internal var hasMappedNotes: Bool {
        (UInt(0)...127).contains {
            guard let note = NoteNumber(uintValue: $0)
            else { return false }

            return realize(noteNumber: note) != nil
        }
    }

    // MARK: Private Type Methods

    private static func _nearest<T>(to target: Number,
                                    in candidates: [(T, Number)]) -> T? {
        var best: (item: T, error: Number)?

        for (item, value) in candidates {
            let error = value >= target ? value / target : target / value

            if let current = best, error >= current.error { continue }

            best = (item, error)
        }

        guard let best
        else { return nil }

        let values = candidates.map(\.1).sorted()

        guard values.count > 1
        else { return best.item }

        // Beyond the outermost value, the catchment extends half a step
        // (geometrically) toward the outside: t² · inner ≥ outer³ below, and
        // t² · inner ≤ outer³ above.
        let lowest = values[0]
        let highest = values[values.count - 1]

        if target < lowest,
           target * target * values[1] < lowest * lowest * lowest {
            return nil
        }

        if target > highest,
           target * target * values[values.count - 2] > highest * highest * highest {
            return nil
        }

        return best.item
    }

    // MARK: Private Instance Methods

    private func _decompose(_ offset: Int) -> (index: Int, periods: Int) {
        let count = ratios.count
        let index = ((offset % count) + count) % count
        let periods = (offset - index) / count

        return (index, periods)
    }
}

// MARK: - Equatable

extension KeyboardMap: Equatable {
}

// MARK: - Sendable

extension KeyboardMap: Sendable {
}
