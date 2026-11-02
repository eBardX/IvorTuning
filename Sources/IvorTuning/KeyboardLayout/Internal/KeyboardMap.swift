// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiNumbers
private import XestiTools

// The table of key frequencies a converter builds from a `KeyboardLayout`, plus the nearest-key
// search. It is built once, when a converter is created, resolving every MIDI note number to a
// frequency (or to nothing, for an unmapped key) — for pitch-class and degree layouts, using a
// tuning system and pitch standard. Building it runs the layout checks that need the tuning
// system. For a pitch-class layout, it also records each key’s spelled pitch, for tie-breaking
// and spelling.
internal struct KeyboardMap {

    // MARK: Internal Initializers

    // A raw layout (raw-ratio or frequency) tunes itself, so `tuningSystem` and `pitchStandard`
    // are not used for it.
    internal init(keyboardLayout: KeyboardLayout,
                  tuningSystem: some TuningSystem,
                  pitchStandard: PitchStandard) throws(TuningError) {
        switch keyboardLayout.definition {
        case let .degrees(degrees, anchorNote, referenceNote):
            let ratios = try Self._ratios(forDegrees: degrees,
                                          in: tuningSystem)

            self.init(frequencies: Self._patternTable(positions: Self._ascendingPositions(ratios,
                                                                                          period: tuningSystem.equivalenceRatio),
                                                      period: tuningSystem.equivalenceRatio,
                                                      anchorNote: anchorNote,
                                                      referenceNote: referenceNote,
                                                      referenceFrequency: pitchStandard.frequency),
                      pitches: nil)

        case let .pitchClasses(pitchClasses, anchorNote, anchorOctave):
            let table = try Self._pitchClassTable(pitchClasses,
                                                  anchorNote: anchorNote,
                                                  anchorOctave: anchorOctave,
                                                  tuningSystem: tuningSystem,
                                                  pitchStandard: pitchStandard)

            self.init(frequencies: table.frequencies,
                      pitches: table.pitches)

        case .frequencies,
             .ratios:
            try self.init(rawLayout: keyboardLayout)
        }
    }

    internal init(rawLayout: KeyboardLayout) throws(TuningError) {
        switch rawLayout.definition {
        case let .frequencies(frequencies):
            self.init(frequencies: frequencies,
                      pitches: nil)

        case let .ratios(ratios, equivalenceRatio, anchorNote, referenceNote, referenceFrequency):
            self.init(frequencies: Self._patternTable(positions: ratios.map { $0.map { Self._log($0.numberValue) } },
                                                      period: equivalenceRatio,
                                                      anchorNote: anchorNote,
                                                      referenceNote: referenceNote,
                                                      referenceFrequency: referenceFrequency),
                      pitches: nil)

        case .degrees,
             .pitchClasses:
            throw .invalidKeyboardLayout(.rawLayoutRequired)
        }
    }

    // MARK: Internal Instance Properties

    // Indexed by MIDI note number; `nil` for an unmapped key.
    internal let frequencies: [Frequency?]

    // For a pitch-class layout only; otherwise `nil`. Indexed by MIDI note number, with `nil` for
    // an unmapped key or for a key whose octave lies outside the range of `Pitch.Octave`.
    internal let pitches: [Pitch?]?

    // MARK: Private Initializers

    private init(frequencies: [Frequency?],
                 pitches: [Pitch?]?) {
        let logValues = frequencies.map { $0.map { Self._log($0.numberValue) } }

        self.distinctLogValues = Self._distinct(logValues.compactMap(\.self))
        self.frequencies = frequencies
        self.logValues = logValues
        self.pitches = pitches
    }

    // MARK: Private Instance Properties

    // The distinct mapped pitches, as natural logs of frequency, in ascending order.
    private let distinctLogValues: [Double]

    // Indexed by MIDI note number.
    private let logValues: [Double?]
}

// MARK: -

extension KeyboardMap {

    // MARK: Internal Type Properties

    // Two pitches whose distance is within this tolerance (0.001 cent, as a natural log) are
    // treated as equal: far smaller than any real keyboard step, far larger than floating-point
    // error.
    internal static let tolerance = 0.001 / 1_200 * Foundation.log(2.0)

    // MARK: Internal Instance Methods

    internal func frequency(of noteNumber: NoteNumber) -> Frequency? {
        frequencies[Int(noteNumber.uintValue)]
    }

    // A tie, two keys equally near within `tolerance`, goes to the key whose spelling has
    // `letter`, if exactly one of the tied keys does; otherwise to the lower key. A frequency
    // beyond the lowest or highest key matches that key only if it lies within half the step to
    // the nearest *distinct* inner pitch; a map with only one distinct pitch has no outer limit.
    internal func nearestKey(to frequency: Frequency,
                             letter: Pitch.Letter? = nil,
                             keyMatching: KeyMatching = .nearest) -> NoteNumber? {
        let target = Self._log(frequency.numberValue)
        let tolerance = Self.tolerance

        guard !_isOutOfRange(target),
              let nearest = logValues.compactMap({ $0.map { abs($0 - target) } }).min()
        else { return nil }

        if case let .within(ratio) = keyMatching,
           nearest > Self._log(ratio.numberValue) + tolerance {
            return nil
        }

        let tied = logValues.indices.filter {
            guard let value = logValues[$0]
            else { return false }

            return abs(value - target) <= nearest + tolerance
        }

        var chosen = tied[0]

        if tied.count > 1,
           let letter,
           let pitches {
            let lettered = tied.filter { pitches[$0]?.letter == letter }

            if lettered.count == 1 {
                chosen = lettered[0]
            }
        }

        return NoteNumber(uintValue: UInt(chosen))
    }

    // MARK: Private Type Methods

    // Places each mapped ratio in the lowest period that sounds above the previous mapped slot,
    // and returns the resulting positions as natural logs relative to the unison.
    private static func _ascendingPositions(_ ratios: [Ratio?],
                                            period: Ratio) -> [Double?] {
        let logPeriod = _log(period.numberValue)
        var periods = 0
        var previous: Double?

        return ratios.map { ratio -> Double? in
            guard let ratio
            else { return nil }

            let value = _log(ratio.numberValue)

            if let previous,
               value <= previous {
                periods += 1
            }

            previous = value

            return value + (Double(periods) * logPeriod)
        }
    }

    private static func _decompose(_ offset: Int,
                                   count: Int) -> (index: Int, periods: Int) {
        let index = ((offset % count) + count) % count

        return (index, (offset - index) / count)
    }

    private static func _distinct(_ values: [Double]) -> [Double] {
        var result: [Double] = []

        for value in values.sorted() {
            if let last = result.last,
               value - last <= tolerance {
                continue
            }

            result.append(value)
        }

        return result
    }

    private static func _frequency(_ logValue: Double) -> Frequency? {
        Frequency(numberValue: Number(Foundation.exp(logValue)))
    }

    private static func _log(_ value: Number) -> Double {
        Foundation.log(value.doubleValue)
    }

    // Builds the 128-key table for a degree or raw-ratio layout: key `referenceNote` sounds
    // `referenceFrequency`, and every other key is tuned from its position relative to it.
    private static func _patternTable(positions: [Double?],
                                      period: Ratio,
                                      anchorNote: NoteNumber,
                                      referenceNote: NoteNumber,
                                      referenceFrequency: Frequency) -> [Frequency?] {
        let logPeriod = _log(period.numberValue)
        let anchor = Int(anchorNote.uintValue)
        let reference = Int(referenceNote.uintValue)

        func position(_ note: Int) -> Double? {
            let (index, periods) = _decompose(note - anchor,
                                              count: positions.count)

            return positions[index].map { $0 + (Double(periods) * logPeriod) }
        }

        // KeyboardLayout guarantees that the reference key is mapped.
        let referencePosition = position(reference).require()
        let referenceLog = _log(referenceFrequency.numberValue)

        return (0..<128).map { note in
            guard note != reference
            else { return referenceFrequency }

            return position(note).flatMap { _frequency(referenceLog + $0 - referencePosition) }
        }
    }

    private static func _pitchClassTable(_ pitchClasses: [PitchClass?],
                                         anchorNote: NoteNumber,
                                         anchorOctave: Pitch.Octave,
                                         tuningSystem: some TuningSystem,
                                         pitchStandard: PitchStandard) throws(TuningError) -> (frequencies: [Frequency?],
                                                                                               pitches: [Pitch?]) {
        let converter = try StandardToAbsolutePitchConverter(tuningSystem: tuningSystem,
                                                             pitchStandard: pitchStandard)
        let logOctave = Foundation.log(2.0)
        let octave4 = Pitch.Octave(intValue: 4).require()

        // Natural log of the frequency of the pitch class in octave `anchorOctave`.
        func logInAnchorOctave(_ pitchClass: PitchClass) -> Double {
            let frequency = converter.convert(Pitch(pitchClass: pitchClass,
                                                    octave: octave4)).require()

            return _log(frequency.numberValue) + (Double(anchorOctave.intValue - 4) * logOctave)
        }

        // Resolve one period: each slot’s octave offset from `anchorOctave` and its position.
        // KeyboardLayout guarantees that slot 0 is mapped.
        let anchorLog = logInAnchorOctave(pitchClasses[0].require())
        var offsets: [Int?] = [0]
        var positions: [Double?] = [anchorLog]
        var previous = anchorLog

        for index in pitchClasses.indices.dropFirst() {
            guard let pitchClass = pitchClasses[index]
            else {
                offsets.append(nil)
                positions.append(nil)
                continue
            }

            let base = logInAnchorOctave(pitchClass)

            // The lowest octave of this pitch class that sounds above the previous mapped slot.
            let offset = Int(Foundation.floor((previous + tolerance - base) / logOctave)) + 1
            let position = base + (Double(offset) * logOctave)

            if position - logOctave >= previous - tolerance {
                throw .invalidKeyboardLayout(.coincidentSlots(index: index))
            }

            if position >= anchorLog + logOctave - tolerance {
                throw .invalidKeyboardLayout(.slotOutsidePeriod(index: index))
            }

            offsets.append(offset)
            positions.append(position)
            previous = position
        }

        var frequencies: [Frequency?] = []
        var pitches: [Pitch?] = []

        for note in 0..<128 {
            let (index, periods) = _decompose(note - Int(anchorNote.uintValue),
                                              count: pitchClasses.count)

            guard let pitchClass = pitchClasses[index],
                  let offset = offsets[index],
                  let position = positions[index]
            else {
                frequencies.append(nil)
                pitches.append(nil)
                continue
            }

            let pitch = Pitch.Octave(intValue: anchorOctave.intValue + offset + periods).map {
                Pitch(pitchClass: pitchClass,
                      octave: $0)
            }

            // Use the converter’s own frequency where the pitch is spellable, so a key sounds
            // exactly what standard → absolute gives for its pitch.
            frequencies.append(pitch.flatMap(converter.convert)
                               ?? _frequency(position + (Double(periods) * logOctave)))
            pitches.append(pitch)
        }

        return (frequencies, pitches)
    }

    private static func _ratios(forDegrees degrees: [Int?],
                                in tuningSystem: some TuningSystem) throws(TuningError) -> [Ratio?] {
        var ratios: [Ratio?] = []

        for (index, degree) in degrees.enumerated() {
            guard let degree
            else {
                ratios.append(nil)
                continue
            }

            guard let ratio = tuningSystem.ratio(forDegree: degree)
            else { throw .invalidKeyboardLayout(.unsupportedDegree(index: index)) }

            ratios.append(ratio)
        }

        return ratios
    }

    // MARK: Private Instance Methods

    // Whether `target` lies beyond the lowest or highest distinct pitch by more than half the step
    // to that pitch{A}s inner neighbor.
    private func _isOutOfRange(_ target: Double) -> Bool {
        let values = distinctLogValues

        guard values.count > 1
        else { return false }

        let lowest = values[0]
        let highest = values[values.count - 1]

        if target < lowest,
           lowest - target > ((values[1] - lowest) / 2) + Self.tolerance {
            return true
        }

        if target > highest,
           target - highest > ((highest - values[values.count - 2]) / 2) + Self.tolerance {
            return true
        }

        return false
    }
}

// MARK: - Equatable

extension KeyboardMap: Equatable {
}

// MARK: - Sendable

extension KeyboardMap: Sendable {
}
