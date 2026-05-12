private import XestiTools

internal enum PerfectFifths {

    // MARK: Internal Type Methods

    internal static func fifths(for interval: Interval) -> Int? {
        intervalToFifths[interval]
    }

    internal static func fifths(for pitchClass: PitchClass) -> Int? {
        guard let fifths = letterToFifths[pitchClass.letter]
        else { return nil }

        switch pitchClass.accidental {
        case .doubleFlat:
            return fifths - 14

        case .doubleSharp:
            return fifths + 14

        case .flat:
            return fifths - 7

        case .natural:
            return fifths

        case .sharp:
            return fifths + 7
        }
    }

    internal static func interval(for fifths: Int) -> Interval? {
        guard (-33...33) ~= fifths
        else { return nil }

        return fifthsToInterval[fifths + 33]
    }

    internal static func pitchClass(for fifths: Int) -> PitchClass? {
        guard (-14...20) ~= fifths
        else { return nil }

        let letter = fifthsToLetter[(fifths + 14) % 7]

        if fifths < -7 {
            return PitchClass(letter: letter,
                              accidental: .doubleFlat)
        } else if fifths < 0 {
            return PitchClass(letter: letter,
                              accidental: .flat)
        } else if fifths > 13 {
            return PitchClass(letter: letter,
                              accidental: .doubleSharp)
        } else if fifths > 6 {
            return PitchClass(letter: letter,
                              accidental: .sharp)
        } else {
            return PitchClass(letter: letter,
                              accidental: .natural)
        }
    }

    // MARK: Private Type Properties

    private static let fifthsToInterval: [Interval] = [.quadruplyDiminished2,
                                                       .quadruplyDiminished6,
                                                       .quadruplyDiminished3,
                                                       .quadruplyDiminished7,
                                                       .quadruplyDiminished4,
                                                       .quadruplyDiminished1,
                                                       .quadruplyDiminished5,
                                                       .triplyDiminished2,
                                                       .triplyDiminished6,
                                                       .triplyDiminished3,
                                                       .triplyDiminished7,
                                                       .triplyDiminished4,
                                                       .triplyDiminished1,
                                                       .triplyDiminished5,
                                                       .doublyDiminished2,
                                                       .doublyDiminished6,
                                                       .doublyDiminished3,
                                                       .doublyDiminished7,
                                                       .doublyDiminished4,
                                                       .doublyDiminished1,
                                                       .doublyDiminished5,
                                                       .diminished2,
                                                       .diminished6,
                                                       .diminished3,
                                                       .diminished7,
                                                       .diminished4,
                                                       .diminished1,
                                                       .diminished5,
                                                       .minor2,
                                                       .minor6,
                                                       .minor3,
                                                       .minor7,
                                                       .perfect4,
                                                       .perfect1,
                                                       .perfect5,
                                                       .major2,
                                                       .major6,
                                                       .major3,
                                                       .major7,
                                                       .augmented4,
                                                       .augmented1,
                                                       .augmented5,
                                                       .augmented2,
                                                       .augmented6,
                                                       .augmented3,
                                                       .augmented7,
                                                       .doublyAugmented4,
                                                       .doublyAugmented1,
                                                       .doublyAugmented5,
                                                       .doublyAugmented2,
                                                       .doublyAugmented6,
                                                       .doublyAugmented3,
                                                       .doublyAugmented7,
                                                       .triplyAugmented4,
                                                       .triplyAugmented1,
                                                       .triplyAugmented5,
                                                       .triplyAugmented2,
                                                       .triplyAugmented6,
                                                       .triplyAugmented3,
                                                       .triplyAugmented7,
                                                       .quadruplyAugmented4,
                                                       .quadruplyAugmented1,
                                                       .quadruplyAugmented5,
                                                       .quadruplyAugmented2,
                                                       .quadruplyAugmented6,
                                                       .quadruplyAugmented3,
                                                       .quadruplyAugmented7]

    private static let fifthsToLetter: [Pitch.Letter] = [.f, .c, .g, .d, .a, .e, .b]

    private static let intervalToFifths: [Interval: Int] = {
        var dict: [Interval: Int] = [:]

        for (idx, interval) in fifthsToInterval.enumerated() {
            dict[interval] = idx - 33
        }

        dict[.perfect8] = dict[.perfect1]                           // treat P8 same as P1
        dict[.diminished8] = dict[.diminished1]                     // ditto d8/d1
        dict[.doublyDiminished8] = dict[.doublyDiminished1]         // ditto dd8/dd1
        dict[.triplyDiminished8] = dict[.triplyDiminished1]         // ditto ddd8/ddd1
        dict[.quadruplyDiminished8] = dict[.quadruplyDiminished1]   // ditto dddd8/dddd1

        return dict
    }()

    private static let letterToFifths: [Pitch.Letter: Int] = {
        var dict: [Pitch.Letter: Int] = [:]

        for (idx, letter) in fifthsToLetter.enumerated() {
            dict[letter] = idx
        }

        return dict
    }()
}

// MARK: - Fileprivate Intervals

extension Interval {
    fileprivate static let quadruplyDiminished1 = Interval(.quadruplyDiminished, 1)
    fileprivate static let triplyDiminished1    = Interval(.triplyDiminished, 1)
    fileprivate static let doublyDiminished1    = Interval(.doublyDiminished, 1)
    fileprivate static let diminished1          = Interval(.diminished, 1)
}
