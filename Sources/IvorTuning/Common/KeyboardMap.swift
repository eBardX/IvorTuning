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

    /// The MIDI note number where `ratios[0]` (unison) is placed.
    public let middleNote: NoteNumber

    /// The interval of equivalence of the repeating pattern.
    public let equivalenceRatio: Ratio

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

    /// Returns the nearest mapped note number for the given frequency.
    ///
    /// - Parameter frequency:  The frequency to match.
    ///
    /// - Returns:  The nearest mapped note number, or `nil` if no note is
    ///             mapped.
    public func unrealize(frequency: Frequency) -> NoteNumber? {
        let target = frequency.numberValue
        var bestNote: NoteNumber?
        var bestErr: Number?

        for i: UInt in 0...127 {
            guard let note = NoteNumber(uintValue: i),
                  let realized = realize(noteNumber: note)
            else { continue }

            let a = realized.numberValue
            let err = a >= target ? a / target : target / a

            if let current = bestErr, err >= current { continue }

            bestErr = err
            bestNote = note
        }

        return bestNote
    }

    /// Returns the nearest mapped note distance for the given frequency ratio.
    ///
    /// - Parameter ratio:  The frequency ratio to match.
    ///
    /// - Returns:  The nearest mapped note distance, or `nil` if no distance is
    ///             mapped.
    public func unrealize(ratio: Ratio) -> NoteDistance? {
        let target = ratio.numberValue
        var bestDistance: NoteDistance?
        var bestErr: Number?

        for i: UInt in 0...127 {
            guard let distance = NoteDistance(uintValue: i),
                  let realized = realize(noteDistance: distance)
            else { continue }

            let a = realized.numberValue
            let err = a >= target ? a / target : target / a

            if let current = bestErr, err >= current { continue }

            bestErr = err
            bestDistance = distance
        }

        return bestDistance
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
