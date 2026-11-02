// © 2026 John Gary Pusey (see LICENSE.md)

extension KeyboardLayout {

    // MARK: Internal Instance Properties

    // Indexed by MIDI note number. Structural: it doesn’t depend on any tuning system.
    internal var mappedKeys: [Bool] {
        switch definition {
        case let .degrees(degrees, anchorNote, _):
            Self._mappedKeys(degrees, anchorNote: anchorNote)

        case let .frequencies(frequencies):
            frequencies.map { $0 != nil }

        case let .pitchClasses(pitchClasses, anchorNote, _):
            Self._mappedKeys(pitchClasses, anchorNote: anchorNote)

        case let .ratios(ratios, _, anchorNote, _, _):
            Self._mappedKeys(ratios, anchorNote: anchorNote)
        }
    }

    // MARK: Internal Instance Methods

    // Whether this layout has the shape a `PitchSpeller` assumes: 12 slots per period, with an
    // octave period. `period` is a degree layout’s period (its tuning system’s equivalence ratio),
    // or `nil` if it isn’t known; it is ignored for other layouts.
    internal func hasTwelveKeysPerOctave(period: Ratio?) -> Bool {
        switch definition {
        case let .degrees(degrees, _, _):
            degrees.count == 12 && (period ?? .octave) == .octave

        case .frequencies:
            false

        case let .pitchClasses(pitchClasses, _, _):
            pitchClasses.count == 12

        case let .ratios(ratios, equivalenceRatio, _, _, _):
            ratios.count == 12 && equivalenceRatio == .octave
        }
    }

    // MARK: Private Type Methods

    private static func _mappedKeys(_ slots: [(some Any)?],
                                    anchorNote: NoteNumber) -> [Bool] {
        let count = slots.count
        let anchor = Int(anchorNote.uintValue)

        return (0..<128).map { note in
            let offset = note - anchor

            return slots[((offset % count) + count) % count] != nil
        }
    }
}
