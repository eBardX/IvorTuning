// © 2026 John Gary Pusey (see LICENSE.md)

extension Key {

    // MARK: Public Nested Types

    /// A diatonic key: one of the 15 diatonic signatures, from seven flats to seven sharps, with
    /// a mode or without one.
    ///
    /// A diatonic signature’s seven pitch classes form a diatonic collection: seven adjacent
    /// places on the line of fifths. The mode, when known, picks the tonic from that collection.
    /// With no mode the signature is known but the tonic isn't: one sharp with no mode is
    /// neither G major nor E minor.
    ///
    /// A diatonic key’s signature always follows convention. A signature written any other way,
    /// such as D harmonic minor written with `B♭ C♯`, is a custom key (see ``Key/Signature``).
    public struct Diatonic {

        // MARK: Public Initializers

        /// Creates a diatonic key from its number of fifths and its mode.
        ///
        /// - Parameter fifths: The number of sharps (when positive) or flats (when negative),
        ///                     from −7 to +7.
        /// - Parameter mode:   The mode, or `nil` if it isn't known.
        ///
        /// - Returns:  `nil` if `fifths` is outside −7…+7.
        public init?(fifths: Int,
                     mode: Mode?) {
            guard (-7...7) ~= fifths
            else { return nil }

            self.fifths = fifths
            self.mode = mode
        }

        /// Creates a diatonic key from its tonic and mode.
        ///
        /// - Parameter tonic:  The tonic (e.g., `.fSharp` for F♯ minor).
        /// - Parameter mode:   The mode.
        ///
        /// - Returns:  `nil` if the key’s signature would need more than seven sharps or flats,
        ///             as E♯ minor or F𝄪 major would.
        public init?(tonic: PitchClass,
                     mode: Mode) {
            self.init(fifths: tonic.fifthChainPosition - mode.diatonicIndex + 1,
                      mode: mode)
        }

        // MARK: Public Instance Properties

        /// The number of sharps (when positive) or flats (when negative) of this key’s
        /// signature, from −7 to +7.
        public let fifths: Int

        /// The mode of this key, or `nil` if it isn't known.
        public let mode: Mode?
    }
}

// MARK: -

extension Key.Diatonic {

    // MARK: Public Instance Properties

    /// The altered pitch classes of this key’s signature, in the usual order: flats in the order
    /// of flats (B E A D G C F), or sharps in the order of sharps (F C G D A E B).
    ///
    /// Empty when the signature has no sharps or flats.
    public var accidentals: [PitchClass] {
        LineOfFifths.canonicalAccidentals(of: diatonicCollection)
    }

    /// The seven pitch classes of this key’s signature, in order of ascending fifths.
    ///
    /// The collection runs from one fifth below the major tonic to five fifths above it (for one
    /// flat: B♭ F C G D A E). A mode is an index into it: lydian 0, major 1, mixolydian 2,
    /// dorian 3, minor 4, phrygian 5 and locrian 6.
    public var diatonicCollection: [PitchClass] {
        LineOfFifths.pitchClasses(atPositions: positions) ?? []
    }

    /// The tonic of this key, or `nil` if its mode isn't known.
    public var tonic: PitchClass? {
        guard let mode
        else { return nil }

        let collection = diatonicCollection

        guard collection.indices ~= mode.diatonicIndex
        else { return nil }

        return collection[mode.diatonicIndex]
    }

    // MARK: Internal Instance Properties

    //
    // The places on the line of fifths of this key’s diatonic collection, in ascending order.
    //
    internal var positions: [Int] {
        Array((fifths - 1)...(fifths + 5))
    }
}

// MARK: - Codable

extension Key.Diatonic: Codable {

    // MARK: Public Initializers

    /// Creates a diatonic key by decoding from the provided decoder.
    ///
    /// The key is decoded from its number of fifths and, if present, its mode.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the number of fifths is outside
    ///             −7…+7, or another `DecodingError` if the data is malformed.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fifths = try container.decode(Int.self,
                                          forKey: .fifths)
        let mode = try container.decodeIfPresent(Key.Mode.self,
                                                 forKey: .mode)

        guard let diatonic = Self(fifths: fifths,
                                  mode: mode)
        else { throw DecodingError.dataCorruptedError(forKey: .fifths,
                                                      in: container,
                                                      debugDescription: "Invalid number of fifths: \(fifths)") }

        self = diatonic
    }

    // MARK: Public Instance Methods

    /// Encodes this diatonic key into the provided encoder.
    ///
    /// The key is encoded as its number of fifths and, if known, its mode. The tonic isn't
    /// encoded, since it follows from the two.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(fifths,
                             forKey: .fifths)
        try container.encodeIfPresent(mode,
                                      forKey: .mode)
    }

    // MARK: Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case fifths
        case mode
    }
}

// MARK: - CustomStringConvertible

extension Key.Diatonic: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The full name of this key (e.g., `"F♯ minor"`, or `"F♯ C♯"` with no mode).
    public var description: String {
        Key.diatonic(self).description
    }
}

// MARK: - Equatable

extension Key.Diatonic: Equatable {
}

// MARK: - Hashable

extension Key.Diatonic: Hashable {
}

// MARK: - Sendable

extension Key.Diatonic: Sendable {
}
