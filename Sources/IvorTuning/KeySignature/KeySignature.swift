// © 2026 John Gary Pusey (see LICENSE.md)

/// A key signature in standard notation: one alteration per letter, each flat, natural or sharp.
///
/// A key signature covers the 15 usual signatures and every custom one built from single sharps
/// and flats, such as mixed (`{B♭, F♯}`), partial (`{F♯, G♯}`) or out-of-order ones. The usual
/// ones are the *diatonic* signatures, whose seven pitch classes form a diatonic collection
/// (seven adjacent places on the line of fifths); only they have a number of ``fifths``. All
/// others are *custom* signatures.
///
/// A key signature is a set: the order in which its accidentals were written doesn't matter, so
/// `{F♯, G♯}` and `{G♯, F♯}` are equal. Its ``accidentals`` are given in a canonical order.
///
/// Double sharps and flats, microtonal alterations and placement by octave can't be represented.
public struct KeySignature {

    // MARK: Public Type Aliases

    /// A type alias for ``Pitch/Accidental``.
    public typealias Accidental = Pitch.Accidental

    /// A type alias for ``Pitch/Letter``.
    public typealias Letter = Pitch.Letter

    // MARK: Public Initializers

    /// Creates a key signature from its altered pitch classes.
    ///
    /// The order of `accidentals` doesn't matter. Any letter not mentioned is natural; a natural
    /// pitch class may be given explicitly, and says the same.
    ///
    /// - Parameter accidentals:    The altered pitch classes of the key signature (e.g., `[.bFlat,
    ///                             .fSharp]`).
    ///
    /// - Returns:  `nil` if `accidentals` mentions a letter more than once, or has a double sharp
    ///             or double flat.
    public init?(accidentals: some Sequence<PitchClass>) {
        var alterations = Array(repeating: Accidental.natural,
                                count: Self.letters.count)
        var seen: Set<Letter> = []

        for pitchClass in accidentals {
            guard seen.insert(pitchClass.letter).inserted,
                  Self.allowedAccidentals.contains(pitchClass.accidental)
            else { return nil }

            alterations[Self._index(of: pitchClass.letter)] = pitchClass.accidental
        }

        self.init(alterations: alterations)
    }

    /// Creates a diatonic key signature from its number of fifths.
    ///
    /// - Parameter fifths: The number of sharps (when positive) or flats (when negative), from −7
    ///                     to +7.
    ///
    /// - Returns:  `nil` if `fifths` is outside −7…+7.
    public init?(fifths: Int) {
        guard (-7...7) ~= fifths
        else { return nil }

        let alterations = Self.letters.map { letter in
            let position = PitchClass(letter: letter,
                                      accidental: .natural).fifthChainPosition

            if position < fifths - 1 {
                return Accidental.sharp
            } else if position > fifths + 5 {
                return Accidental.flat
            } else {
                return Accidental.natural
            }
        }

        self.init(alterations: alterations)
    }

    // MARK: Private Initializers

    private init(alterations: [Accidental]) {
        self.alterations = alterations
    }

    // MARK: Private Instance Properties

    private let alterations: [Accidental]    // indexed by letter, from C to B
}

// MARK: -

extension KeySignature {

    // MARK: Public Instance Properties

    /// The altered pitch classes of this key signature, in canonical order: flats in the order of
    /// flats (B E A D G C F), then sharps in the order of sharps (F C G D A E B).
    ///
    /// For a diatonic signature this is the usual order. Empty when no letter is altered.
    public var accidentals: [PitchClass] {
        let pitchClasses = pitchClasses

        let flats = pitchClasses
            .filter { $0.accidental == .flat }
            .sorted { $0.fifthChainPosition > $1.fifthChainPosition }

        let sharps = pitchClasses
            .filter { $0.accidental == .sharp }
            .sorted { $0.fifthChainPosition < $1.fifthChainPosition }

        return flats + sharps
    }

    /// The diatonic collection of this key signature: its seven pitch classes in order of
    /// ascending fifths, or `nil` for a custom signature.
    ///
    /// The collection runs from one fifth below the major tonic to five fifths above it (for one
    /// flat: B♭ F C G D A E). A mode is an index into it: lydian 0, major 1, mixolydian 2,
    /// dorian 3, minor 4, phrygian 5 and locrian 6.
    public var diatonicCollection: [PitchClass]? {
        guard isDiatonic
        else { return nil }

        return pitchClasses.sorted { $0.fifthChainPosition < $1.fifthChainPosition }
    }

    /// The number of sharps (when positive) or flats (when negative) of this key signature, from
    /// −7 to +7, or `nil` for a custom signature.
    public var fifths: Int? {
        let positions = fifthChainPositions

        guard let lowest = positions.min(),
              let highest = positions.max(),
              highest - lowest == 6
        else { return nil }

        return lowest + 1
    }

    /// A Boolean value indicating whether this key signature is diatonic: whether its seven pitch
    /// classes form a diatonic collection.
    public var isDiatonic: Bool {
        fifths != nil
    }

    /// The diatonic key signature nearest this one.
    ///
    /// A diatonic signature is its own nearest. For a custom signature, this is the diatonic
    /// signature that differs from it in the fewest letters. Ties go to the one with fewer
    /// accidentals, then to the side this signature leans to (sharps when it has more sharps than
    /// flats, flats when it has more flats than sharps), then to sharps. For example, `{F♯, G♯}`
    /// differs in one letter from both one sharp and three sharps, and its nearest is one sharp.
    ///
    /// MIDI can only express diatonic signatures, so this is what a custom signature becomes in a
    /// MIDI file.
    public var nearestDiatonic: Self {
        guard !isDiatonic
        else { return self }

        let sharpCount = alterations.count { $0 == .sharp }
        let flatCount = alterations.count { $0 == .flat }
        let leanSign = flatCount > sharpCount ? -1 : 1

        let candidates = Self.diatonicSignatures.map { candidate in
            let differences = zip(alterations, candidate.alterations).count { $0 != $1 }
            let accidentalCount = candidate.alterations.count { $0 != .natural }
            let fifths = candidate.fifths ?? 0
            let sideRank = fifths.signum() == leanSign ? 0 : 1

            return (candidate, (differences, accidentalCount, sideRank))
        }

        // swiftlint:disable:next force_unwrapping
        return candidates.min { $0.1 < $1.1 }!.0
    }

    /// The seven pitch classes of this key signature, one per letter, from C to B.
    public var pitchClasses: [PitchClass] {
        zip(Self.letters, alterations).map {
            PitchClass(letter: $0,
                       accidental: $1)
        }
    }

    // MARK: Public Instance Methods

    /// Returns the alteration this key signature gives a letter.
    ///
    /// - Parameter letter: The diatonic letter.
    ///
    /// - Returns:  `.flat`, `.natural` or `.sharp`.
    public func accidental(for letter: Letter) -> Accidental {
        alterations[Self._index(of: letter)]
    }

    /// Returns the short string representation of this key signature.
    ///
    /// A diatonic signature is shown as its number of sharps or flats (`"3♯"`, `"2♭"`), or as
    /// `"no ♯/♭"` when it has neither. A custom signature is shown as its ``accidentals``, in
    /// canonical order (`"B♭ F♯"`).
    ///
    /// - Parameter ascii:  When `true`, accidentals are rendered using their ASCII
    ///                     representations (`"3#"`, `"2b"`, `"no #/b"`, `"Bb F#"`) instead of
    ///                     their Unicode symbols. Defaults to `false`.
    ///
    /// - Returns:  The short string representation of the key signature.
    public func stringValue(ascii: Bool = false) -> String {
        let flat = Accidental.flat.stringValue(ascii: ascii)
        let sharp = Accidental.sharp.stringValue(ascii: ascii)

        guard let fifths
        else { return accidentals.map { $0.stringValue(ascii: ascii) }.joined(separator: " ") }

        if fifths > 0 {
            return "\(fifths)\(sharp)"
        } else if fifths < 0 {
            return "\(-fifths)\(flat)"
        } else {
            return "no \(sharp)/\(flat)"
        }
    }

    // MARK: Internal Instance Properties

    /// The places on the line of fifths of this key signature’s seven pitch classes, from C to B,
    /// with C at 0.
    internal var fifthChainPositions: [Int] {
        pitchClasses.map(\.fifthChainPosition)
    }

    // MARK: Private Type Properties

    private static let allowedAccidentals: [Accidental] = [.flat, .natural, .sharp]

    private static let diatonicSignatures: [Self] = (-7...7).compactMap { Self(fifths: $0) }

    private static let letters: [Letter] = [.c, .d, .e, .f, .g, .a, .b]

    // MARK: Private Type Methods

    private static func _index(of letter: Letter) -> Int {
        letter.order - 1
    }
}

// MARK: - Codable

extension KeySignature: Codable {

    // MARK: Public Initializers

    /// Creates a key signature by decoding from the provided decoder.
    ///
    /// The key signature is decoded from its altered pitch classes.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded pitch classes don't form a
    ///             valid key signature.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let accidentals = try container.decode([PitchClass].self)

        guard let keySignature = Self(accidentals: accidentals)
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid key signature: \(accidentals)") }

        self = keySignature
    }

    // MARK: Public Instance Methods

    /// Encodes this key signature into the provided encoder.
    ///
    /// The key signature is encoded as its altered pitch classes, in canonical order.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(accidentals)
    }
}

// MARK: - CustomStringConvertible

extension KeySignature: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The short string representation of this key signature (e.g., `"3♯"`, `"no ♯/♭"`,
    /// `"B♭ F♯"`).
    public var description: String {
        stringValue()
    }
}

// MARK: - Equatable

extension KeySignature: Equatable {
}

// MARK: - Hashable

extension KeySignature: Hashable {
}

// MARK: - Sendable

extension KeySignature: Sendable {
}
