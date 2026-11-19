// © 2026 John Gary Pusey (see LICENSE.md)

extension Key {

    // MARK: Public Nested Types

    /// A custom key signature: one alteration per letter, each flat, natural or sharp, whose
    /// seven pitch classes don't form a diatonic collection.
    ///
    /// A custom signature can be mixed (`{B♭, F♯}`), partial (`{F♯, G♯}`) or otherwise unusual.
    /// The 15 diatonic signatures, including the one with no sharps or flats, are never custom:
    /// they're diatonic keys (see ``Key/Diatonic``). So a custom signature is never empty.
    ///
    /// A custom signature is a set: the order in which its accidentals were written doesn't
    /// matter, so `{F♯, G♯}` and `{G♯, F♯}` are equal. Its ``accidentals`` are given in a
    /// canonical order. Enharmonic duplicates such as `{A♯, B♭}` are allowed, since they alter
    /// different letters.
    ///
    /// Double sharps and flats, microtonal alterations and placement by octave can't be
    /// represented.
    public struct Signature {

        // MARK: Public Type Aliases

        /// A type alias for ``Pitch/Accidental``.
        public typealias Accidental = Pitch.Accidental

        /// A type alias for ``Pitch/Letter``.
        public typealias Letter = Pitch.Letter

        // MARK: Public Initializers

        /// Creates a custom signature from its altered pitch classes.
        ///
        /// The order of `accidentals` doesn't matter. Any letter not mentioned is natural; a
        /// natural pitch class may be given explicitly, and says the same.
        ///
        /// - Parameter accidentals:    The altered pitch classes of the signature (e.g.,
        ///                             `[.bFlat, .fSharp]`).
        ///
        /// - Returns:  `nil` if `accidentals` forms a diatonic signature (including none at all),
        ///             mentions a letter more than once, or has a double sharp or double flat.
        public init?(accidentals: some Sequence<PitchClass>) {
            guard let alterations = LineOfFifths.alterations(of: accidentals)
            else { return nil }

            self.alterations = alterations

            guard LineOfFifths.diatonicFifths(of: fifthChainPositions) == nil
            else { return nil }
        }

        // MARK: Private Instance Properties

        private let alterations: [Accidental]    // indexed by letter, from C to B
    }
}

// MARK: -

extension Key.Signature {

    // MARK: Public Instance Properties

    /// The altered pitch classes of this signature, in canonical order: flats in the order of
    /// flats (B E A D G C F), then sharps in the order of sharps (F C G D A E B).
    ///
    /// Never empty.
    public var accidentals: [PitchClass] {
        LineOfFifths.canonicalAccidentals(of: pitchClasses)
    }

    /// The number of sharps (when positive) or flats (when negative) of the diatonic signature
    /// nearest this one.
    ///
    /// This is the diatonic signature that differs from this one in the fewest letters. Ties go
    /// to the one with fewer accidentals, then to the side this signature leans to (sharps when
    /// it has more sharps than flats, flats when it has more flats than sharps), then to sharps.
    /// For example, `{F♯, G♯}` differs in one letter from both one sharp and three sharps, and
    /// its nearest is one sharp.
    ///
    /// MIDI can only express diatonic signatures, so this is what a custom key becomes in a MIDI
    /// file.
    public var nearestDiatonicFifths: Int {
        let sharpCount = alterations.count { $0 == .sharp }
        let flatCount = alterations.count { $0 == .flat }
        let leanSign = flatCount > sharpCount ? -1 : 1

        let ranked = (-7...7).map { fifths in
            let candidate = LineOfFifths.diatonicAlterations(fifths: fifths)
            let differences = zip(alterations, candidate).count { $0 != $1 }
            let sideRank = fifths.signum() == leanSign ? 0 : 1

            return (fifths, (differences, abs(fifths), sideRank))
        }

        return ranked.min { $0.1 < $1.1 }?.0 ?? 0
    }

    /// The seven pitch classes of this signature, one per letter, from C to B.
    public var pitchClasses: [PitchClass] {
        LineOfFifths.pitchClasses(of: alterations)
    }

    // MARK: Public Instance Methods

    /// Returns the alteration this signature gives a letter.
    ///
    /// - Parameter letter: The diatonic letter.
    ///
    /// - Returns:  `.flat`, `.natural` or `.sharp`.
    public func accidental(for letter: Letter) -> Accidental {
        alterations[LineOfFifths.index(of: letter)]
    }

    /// Returns the string representation of this signature: its ``accidentals``, in canonical
    /// order (`"B♭ F♯"`).
    ///
    /// - Parameter ascii:  When `true`, accidentals are rendered using their ASCII
    ///                     representations (`"Bb F#"`) instead of their Unicode symbols.
    ///                     Defaults to `false`.
    ///
    /// - Returns:  The string representation of the signature.
    public func stringValue(ascii: Bool = false) -> String {
        accidentals
            .map { $0.stringValue(ascii: ascii) }
            .joined(separator: " ")
    }

    // MARK: Internal Instance Properties

    //
    // The places on the line of fifths of this signature’s seven pitch classes, from C to B.
    //
    internal var fifthChainPositions: [Int] {
        pitchClasses.map(\.fifthChainPosition)
    }
}

// MARK: - Codable

extension Key.Signature: Codable {

    // MARK: Public Initializers

    /// Creates a custom signature by decoding from the provided decoder.
    ///
    /// The signature is decoded from its altered pitch classes.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded pitch classes don't form a
    ///             valid custom signature, including when they form a diatonic one.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let accidentals = try container.decode([PitchClass].self)

        guard let signature = Self(accidentals: accidentals)
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid custom signature: \(accidentals)") }

        self = signature
    }

    // MARK: Public Instance Methods

    /// Encodes this custom signature into the provided encoder.
    ///
    /// The signature is encoded as its altered pitch classes, in canonical order.
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

extension Key.Signature: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The string representation of this signature (e.g., `"B♭ F♯"`).
    public var description: String {
        stringValue()
    }
}

// MARK: - Equatable

extension Key.Signature: Equatable {
}

// MARK: - Hashable

extension Key.Signature: Hashable {
}

// MARK: - Sendable

extension Key.Signature: Sendable {
}
