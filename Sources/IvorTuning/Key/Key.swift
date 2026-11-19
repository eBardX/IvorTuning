// © 2026 John Gary Pusey (see LICENSE.md)

/// A musical key: atonal, diatonic (with or without a known mode), or custom.
///
/// A key is descriptive: it says what key the music is in, and the signature it's written with
/// follows from it. It never decides how a note is spelled.
///
/// - An ``atonal`` key says there's no key, and is written with no signature.
/// - A ``diatonic(_:)`` key is one of the 15 diatonic signatures, with a mode (`"F♯ minor"`) or
///   without one (`"F♯ C♯ G♯"`, the signature known but not the tonic).
/// - A ``custom(_:)`` key is any other signature built from single sharps and flats
///   (`"B♭ F♯"`). It has no tonic.
///
/// No illegal key can be built: ``Diatonic`` and ``Signature`` check every rule in their
/// failable initializers, so a diatonic set of accidentals is always a diatonic key, never a
/// custom one.
public enum Key {

    /// No key: the music is written with no signature.
    case atonal

    /// A custom key: a signature whose pitch classes don't form a diatonic collection.
    case custom(Signature)

    /// A diatonic key, with or without a mode.
    case diatonic(Diatonic)
}

// MARK: -

extension Key {

    // MARK: Public Initializers

    /// Creates the key a written signature gives, with no mode.
    ///
    /// A diatonic set of accidentals, including an empty one, gives a diatonic key with no mode;
    /// any other set gives a custom key. The order of `accidentals` doesn't matter, and naturals
    /// may be given and are ignored.
    ///
    /// - Parameter accidentals:    The altered pitch classes of the signature (e.g.,
    ///                             `[.fSharp, .cSharp]`).
    ///
    /// - Returns:  `nil` if `accidentals` mentions a letter more than once, or has a double sharp
    ///             or double flat.
    public init?(accidentals: some Sequence<PitchClass>) {
        guard let alterations = LineOfFifths.alterations(of: accidentals)
        else { return nil }

        let pitchClasses = LineOfFifths.pitchClasses(of: alterations)

        if let fifths = LineOfFifths.diatonicFifths(of: pitchClasses.map(\.fifthChainPosition)),
           let diatonic = Diatonic(fifths: fifths,
                                   mode: nil) {
            self = .diatonic(diatonic)
        } else if let signature = Signature(accidentals: pitchClasses) {
            self = .custom(signature)
        } else {
            return nil
        }
    }

    // MARK: Public Type Methods

    /// Returns a diatonic key from its number of fifths and its mode.
    ///
    /// - Parameter fifths: The number of sharps (when positive) or flats (when negative), from
    ///                     −7 to +7.
    /// - Parameter mode:   The mode, or `nil` if it isn't known.
    ///
    /// - Returns:  `nil` if `fifths` is outside −7…+7.
    public static func diatonic(fifths: Int,
                                mode: Mode?) -> Self? {
        Diatonic(fifths: fifths,
                 mode: mode).map { .diatonic($0) }
    }

    /// Returns a diatonic key from its tonic and mode.
    ///
    /// - Parameter tonic:  The tonic (e.g., `.fSharp` for F♯ minor).
    /// - Parameter mode:   The mode.
    ///
    /// - Returns:  `nil` if the key’s signature would need more than seven sharps or flats.
    public static func diatonic(tonic: PitchClass,
                                mode: Mode) -> Self? {
        Diatonic(tonic: tonic,
                 mode: mode).map { .diatonic($0) }
    }

    // MARK: Public Instance Properties

    /// The altered pitch classes of this key’s written signature, in canonical order: flats in
    /// the order of flats (B E A D G C F), then sharps in the order of sharps (F C G D A E B).
    ///
    /// Empty for an atonal key and for a diatonic key with no sharps or flats.
    public var accidentals: [PitchClass] {
        switch self {
        case .atonal:
            []

        case let .custom(signature):
            signature.accidentals

        case let .diatonic(diatonic):
            diatonic.accidentals
        }
    }

    /// The number of sharps (when positive) or flats (when negative) of a diatonic key’s
    /// signature, from −7 to +7, or `nil` for an atonal or custom key.
    public var fifths: Int? {
        guard case let .diatonic(diatonic) = self
        else { return nil }

        return diatonic.fifths
    }

    /// The mode of a diatonic key, or `nil` if it isn't known or the key isn't diatonic.
    public var mode: Mode? {
        guard case let .diatonic(diatonic) = self
        else { return nil }

        return diatonic.mode
    }

    /// The number of sharps (when positive) or flats (when negative) of the diatonic signature
    /// nearest this key’s: its own for a diatonic key, the nearest for a custom key (see
    /// ``Signature/nearestDiatonicFifths``), and 0 for an atonal key.
    ///
    /// MIDI can only express diatonic signatures, so this is what MIDI writes.
    public var nearestDiatonicFifths: Int {
        switch self {
        case .atonal:
            0

        case let .custom(signature):
            signature.nearestDiatonicFifths

        case let .diatonic(diatonic):
            diatonic.fifths
        }
    }

    /// The tonic of a diatonic key with a mode, or `nil` otherwise.
    public var tonic: PitchClass? {
        guard case let .diatonic(diatonic) = self
        else { return nil }

        return diatonic.tonic
    }

    // MARK: Internal Instance Methods

    //
    // The full name of this key: the tonic and mode of a diatonic key with a mode ("F♯ minor"),
    // otherwise its accidentals ("F♯ C♯ G♯", "B♭ F♯"), "no accidentals" for a diatonic key with
    // none, or "Atonal".
    //
    internal func name(ascii: Bool) -> String {
        switch self {
        case .atonal:
            return "Atonal"

        case let .custom(signature):
            return signature.stringValue(ascii: ascii)

        case let .diatonic(diatonic):
            if let mode = diatonic.mode,
               let tonic = diatonic.tonic {
                return "\(tonic.stringValue(ascii: ascii, omitNatural: true)) \(mode.rawValue)"
            }

            let accidentals = diatonic.accidentals

            guard !accidentals.isEmpty
            else { return "(no accidentals)" }

            return accidentals
                .map { $0.stringValue(ascii: ascii) }
                .joined(separator: " ")
        }
    }
}

// MARK: - Codable

extension Key: Codable {

    // MARK: Public Initializers

    /// Creates a key by decoding from the provided decoder.
    ///
    /// An atonal key is decoded from the string `"atonal"`; a diatonic key from its number of
    /// fifths and, if present, its mode (`{"fifths": 3, "mode": "minor"}`); and a custom key from
    /// its altered pitch classes (`{"custom": ["B♭", "F♯"]}`).
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the data doesn't describe a valid key,
    ///             or another `DecodingError` if the data is malformed.
    public init(from decoder: any Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let string = try? container.decode(String.self) {
            guard string == Self.atonalValue
            else { throw DecodingError.dataCorruptedError(in: container,
                                                          debugDescription: "Invalid key: \(string)") }

            self = .atonal

            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.contains(.custom)
        else { self = try .diatonic(Diatonic(from: decoder)); return }

        guard !container.contains(.fifths),
              !container.contains(.mode)
        else { throw DecodingError.dataCorruptedError(forKey: .custom,
                                                      in: container,
                                                      debugDescription: "A custom key has no fifths or mode") }

        self = try .custom(container.decode(Signature.self,
                                            forKey: .custom))
    }

    // MARK: Public Instance Methods

    /// Encodes this key into the provided encoder.
    ///
    /// An atonal key is encoded as the string `"atonal"`; a diatonic key as its number of fifths
    /// and, if known, its mode; and a custom key as its altered pitch classes, in canonical
    /// order, under `"custom"`.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .atonal:
            var container = encoder.singleValueContainer()

            try container.encode(Self.atonalValue)

        case let .custom(signature):
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(signature,
                                 forKey: .custom)

        case let .diatonic(diatonic):
            try diatonic.encode(to: encoder)
        }
    }

    // MARK: Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case custom
        case fifths
        case mode
    }

    // MARK: Private Type Properties

    private static let atonalValue = "atonal"
}

// MARK: - CustomStringConvertible

extension Key: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The full name of this key (e.g., `"F♯ minor"`, `"F♯ C♯ G♯"`, `"no accidentals"`,
    /// `"B♭ F♯"`, `"Atonal"`).
    public var description: String {
        name(ascii: false)
    }
}

// MARK: - Equatable

extension Key: Equatable {
}

// MARK: - Hashable

extension Key: Hashable {
}

// MARK: - Sendable

extension Key: Sendable {
}
