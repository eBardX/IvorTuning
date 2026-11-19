// © 2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiNumbers

//
// Shared support for keys: per-letter alterations, canonical order, and the transforms, which
// all work on places on the line of fifths (C at 0, G at 1, F at −1, and so on).
//
// A transform shifts or reflects every place by the same amount, so the span of a set of places
// is kept: seven adjacent places (a diatonic collection) stay adjacent, and any other set stays
// non-adjacent.
//
internal enum LineOfFifths {
}

// MARK: -

extension LineOfFifths {

    // MARK: Internal Type Aliases

    internal typealias Accidental = Pitch.Accidental

    internal typealias Letter = Pitch.Letter

    // MARK: Internal Type Properties

    internal static let letters: [Letter] = [.c, .d, .e, .f, .g, .a, .b]

    // MARK: Internal Type Methods

    //
    // The alterations given by a set of pitch classes, indexed by letter from C to B. `nil` if a
    // letter appears twice or for a double sharp or flat. Naturals may be given.
    //
    internal static func alterations(of accidentals: some Sequence<PitchClass>) -> [Accidental]? {
        var alterations = Array(repeating: Accidental.natural,
                                count: letters.count)
        var seen: Set<Letter> = []

        for pitchClass in accidentals {
            guard seen.insert(pitchClass.letter).inserted,
                  allowedAccidentals.contains(pitchClass.accidental)
            else { return nil }

            alterations[index(of: pitchClass.letter)] = pitchClass.accidental
        }

        return alterations
    }

    //
    // The altered pitch classes among `pitchClasses`, in canonical order: flats in the order of
    // flats (B E A D G C F), then sharps in the order of sharps (F C G D A E B).
    //
    internal static func canonicalAccidentals(of pitchClasses: [PitchClass]) -> [PitchClass] {
        let flats = pitchClasses
            .filter { $0.accidental == .flat }
            .sorted { $0.fifthChainPosition > $1.fifthChainPosition }

        let sharps = pitchClasses
            .filter { $0.accidental == .sharp }
            .sorted { $0.fifthChainPosition < $1.fifthChainPosition }

        return flats + sharps
    }

    //
    // The alterations of the diatonic signature with `fifths` sharps or flats, indexed by letter
    // from C to B.
    //
    internal static func diatonicAlterations(fifths: Int) -> [Accidental] {
        letters.map { letter in
            let position = PitchClass(letter: letter,
                                      accidental: .natural).fifthChainPosition

            if position < fifths - 1 {
                return .sharp
            } else if position > fifths + 5 {
                return .flat
            } else {
                return .natural
            }
        }
    }

    //
    // The number of sharps or flats of the diatonic signature whose places these are, or `nil`
    // if they aren't seven adjacent places.
    //
    internal static func diatonicFifths(of positions: [Int]) -> Int? {
        guard positions.count == letters.count,
              Set(positions).count == letters.count,
              let lowest = positions.min(),
              let highest = positions.max(),
              highest - lowest == 6
        else { return nil }

        return lowest + 1
    }

    internal static func index(of letter: Letter) -> Int {
        letter.order - 1
    }

    //
    // Places reflected around a range of pitches. The exact result if it fits in single
    // accidentals, otherwise its enharmonic equivalent with the fewest accidentals.
    //
    internal static func inverted(_ positions: [Int],
                                  around pitchRange: ClosedRange<Pitch>) -> [Int]? {
        let axis = pitchRange.lowerBound.pitchClass.fifthChainPosition
            + pitchRange.upperBound.pitchClass.fifthChainPosition

        return _normalized(positions.map { axis - $0 },
                           preferringExact: true)
    }

    //
    // Places reflected around C, then transposed up by the key steps the range’s bounds add up
    // to. Assumes 12 keys to the octave.
    //
    internal static func inverted(_ positions: [Int],
                                  around noteRange: ClosedRange<NoteNumber>) -> [Int]? {
        let keySteps = Int(noteRange.lowerBound.uintValue + noteRange.upperBound.uintValue)

        return _transposed(positions.map { -$0 },
                           keySteps: keySteps)
    }

    //
    // The pitch classes at these places, in the same order. `nil` if any is out of reach.
    //
    internal static func pitchClasses(atPositions positions: [Int]) -> [PitchClass]? {
        let pitchClasses = positions.compactMap { PerfectFifths.pitchClass(for: $0 + 1) }  // F is 0 there

        guard pitchClasses.count == positions.count
        else { return nil }

        return pitchClasses
    }

    //
    // The seven pitch classes these alterations give, one per letter, from C to B.
    //
    internal static func pitchClasses(of alterations: [Accidental]) -> [PitchClass] {
        zip(letters, alterations).map {
            PitchClass(letter: $0,
                       accidental: $1)
        }
    }

    //
    // Places moved by a directed interval: the exact result if it fits in single accidentals,
    // otherwise its enharmonic equivalent with the fewest accidentals. `nil` if the interval
    // has no fifths equivalent or nothing fits.
    //
    internal static func transposed(_ positions: [Int],
                                    by directedInterval: DirectedInterval<Interval>) -> [Int]? {
        guard let fifths = PerfectFifths.fifths(for: directedInterval.interval.simplified())
        else { return nil }

        let shift = _signed(fifths,
                            directedInterval.direction)

        return _normalized(positions.map { $0 + shift },
                           preferringExact: true)
    }

    //
    // Places moved by a number of key steps, each as its usual interval, then replaced by an
    // enharmonic equivalent if that has strictly fewer accidentals. Assumes 12 keys to the
    // octave.
    //
    internal static func transposed(_ positions: [Int],
                                    by directedInterval: DirectedInterval<NoteDistance>) -> [Int]? {
        let keySteps = _signed(Int(directedInterval.interval.uintValue),
                               directedInterval.direction)

        return _transposed(positions,
                           keySteps: keySteps)
    }

    //
    // Places moved by a ratio within ±25 cents of a whole number of semitones, as that many key
    // steps. `nil` for a ratio further off.
    //
    internal static func transposed(_ positions: [Int],
                                    by directedInterval: DirectedInterval<Ratio>) -> [Int]? {
        let cents = directedInterval.interval.cents.doubleValue
        let semitones = (cents / 100).rounded()

        guard abs(cents - (semitones * 100)) <= semitoneTolerance,
              semitones.isFinite
        else { return nil }

        let keySteps = _signed(Int(semitones),
                               directedInterval.direction)

        return _transposed(positions,
                           keySteps: keySteps)
    }

    // MARK: Private Type Properties

    private static let allowedAccidentals: [Accidental] = [.flat, .natural, .sharp]

    // The usual interval for each number of key steps within an octave, as fifths.
    private static let keyStepFifths: [Int] = keyStepIntervals.map { PerfectFifths.fifths(for: $0) ?? 0 }

    // The usual interval for each number of key steps within an octave.
    private static let keyStepIntervals: [Interval] = [.perfect1,
                                                       .minor2,
                                                       .major2,
                                                       .minor3,
                                                       .major3,
                                                       .perfect4,
                                                       .augmented4,
                                                       .perfect5,
                                                       .minor6,
                                                       .major6,
                                                       .minor7,
                                                       .major7]

    private static let semitoneTolerance = 25.0 + 1e-9     // cents, allowing for rounding error

    private static let validPositions = -8...12     // F♭ to B♯

    // MARK: Private Type Methods

    private static func _accidentalCount(_ positions: [Int]) -> Int {
        positions.count { !((-1...5) ~= $0) }       // F to B are natural
    }

    private static func _normalized(_ positions: [Int],
                                    preferringExact: Bool) -> [Int]? {
        if preferringExact,
           positions.allSatisfy({ validPositions ~= $0 }) {
            return positions
        }

        // Shifting every pitch class by 12 fifths gives an enharmonic equivalent. At most two
        // shifts can fit in single accidentals, so ties go to the smaller shift.
        let candidates = (-5...5).compactMap { shift -> (positions: [Int], rank: (Int, Int))? in
            let shifted = positions.map { $0 + (shift * 12) }

            guard shifted.allSatisfy({ validPositions ~= $0 })
            else { return nil }

            return (shifted, (_accidentalCount(shifted), abs(shift)))
        }

        return candidates.min { $0.rank < $1.rank }?.positions
    }

    private static func _signed(_ value: Int,
                                _ direction: PitchDirection) -> Int {
        switch direction {
        case .ascending:
            value

        case .descending:
            -value

        case .same:
            0
        }
    }

    private static func _transposed(_ positions: [Int],
                                    keySteps: Int) -> [Int]? {
        let magnitude = keyStepFifths[abs(keySteps) % 12]
        let shift = keySteps < 0 ? -magnitude : magnitude

        return _normalized(positions.map { $0 + shift },
                           preferringExact: false)
    }
}
