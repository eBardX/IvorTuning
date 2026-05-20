// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A musical pitch identified by pitch class and octave.
public struct Pitch {

    // MARK: Public Initializers

    /// Creates a pitch from a pitch class and octave.
    ///
    /// - Parameter pitchClass: The pitch class identifying the letter and accidental.
    /// - Parameter octave:     The octave number.
    public init(pitchClass: PitchClass,
                octave: Octave) {
        self.octave = octave
        self.pitchClass = pitchClass
    }

    // MARK: Public Instance Properties

    /// The octave number of this pitch.
    public let octave: Octave

    /// The pitch class (letter and accidental) of this pitch.
    public let pitchClass: PitchClass
}

// MARK: -

extension Pitch {

    // MARK: Public Initializers

    /// Creates a pitch from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the pitch (e.g., `"C♯4"`).
    ///
    /// - Throws:   `ParseError` if `stringValue` cannot be parsed as a valid pitch.
    public init(stringValue: String) throws {
        guard let result = Self._parse(Substring(stringValue))
        else { throw ParseError.invalidPitch(stringValue) }

        self.init(pitchClass: result.pitchClass,
                  octave: result.octave)
    }

    // MARK: Public Instance Properties

    /// The accidental of this pitch.
    public var accidental: Accidental {
        pitchClass.accidental
    }

    /// The diatonic letter name of this pitch.
    public var letter: Letter {
        pitchClass.letter
    }

    // MARK: Public Instance Methods

    /// Returns the string representation of this pitch.
    ///
    /// Renamed to ``stringValue(omitNatural:)``.
    ///
    /// - Parameter omitNatural:    When `true`, the natural accidental symbol is omitted.
    ///
    /// - Returns:  The string representation of the pitch.
    @available(*, deprecated, renamed: "stringValue(omitNatural:)")
    public func description(omitNatural: Bool) -> String {
        stringValue(omitNatural: omitNatural)
    }

    /// Returns the string representation of this pitch.
    ///
    /// - Parameter omitNatural:    When `true`, the natural accidental symbol is omitted.
    ///
    /// - Returns:  The string representation of the pitch.
    public func stringValue(omitNatural: Bool) -> String {
        pitchClass.stringValue(omitNatural: omitNatural) + octave.description
    }

    // MARK: Private Nested Types

    private typealias ParseResult = (pitchClass: PitchClass, octave: Octave)

    // MARK: Private Type Properties

    private static let octaveCharacters: Set<Character> = ["-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    // MARK: Private Type Methods

    private static func _parse(_ input: Substring) -> ParseResult? {
        let result = input.splitBeforeFirst(octaveCharacters)

        guard let otext = result.tail,
              let rawOctave = Int(otext),
              let octave = Octave(intValue: rawOctave),
              let pitchClass = try? PitchClass(stringValue: String(result.head))
        else { return nil }

        return (pitchClass, octave)
    }
}

// MARK: - Codable

extension Pitch: Codable {

    // MARK: Public Initializers

    /// Creates a pitch by decoding from the provided decoder.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded value is
    ///             not a valid pitch string.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let result = Self._parse(Substring(stringValue))
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid pitch value: \(stringValue)") }

        self.init(pitchClass: result.pitchClass,
                  octave: result.octave)
    }

    // MARK: Public Instance Methods

    /// Encodes this pitch into the provided encoder.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - Comparable

extension Pitch: Comparable {

    /// Returns a Boolean value indicating whether the first pitch is lower than the second.
    ///
    /// - Parameter lhs:    The left-hand pitch.
    /// - Parameter rhs:    The right-hand pitch.
    ///
    /// - Returns:  `true` if `lhs` is lower in pitch than `rhs`; otherwise, `false`.
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        _determineDirection(lhs, rhs) == .ascending
    }
}

// MARK: - CustomStringConvertible

extension Pitch: CustomStringConvertible {

    /// The string representation of this pitch, including the natural accidental symbol when present.
    public var description: String {
        stringValue(omitNatural: false)
    }
}

// MARK: - Equatable

extension Pitch: Equatable {
}

// MARK: - ExpressibleByStringLiteral

extension Pitch: ExpressibleByStringLiteral {

    /// Creates a pitch from a string literal.
    ///
    /// - Parameter value:  The string literal representing the pitch (e.g., `"C♯4"`).
    ///
    /// - Precondition: `value` must be a valid pitch string.
    public init(stringLiteral value: String) {
        let result = Self._parse(Substring(value)).require()

        self.init(pitchClass: result.pitchClass,
                  octave: result.octave)
    }
}

// MARK: - Hashable

extension Pitch: Hashable {
}

// MARK: - PitchProtocol

extension Pitch: PitchProtocol {

    // MARK: Public Instance Methods

    /// Returns the directed interval from this pitch to another pitch.
    ///
    /// - Parameter pitch:  The target pitch.
    ///
    /// - Returns:  The directed interval, or `nil` if the interval cannot be determined.
    public func interval(to pitch: Self) -> DirectedInterval<Interval>? {
        let direction = Self._determineDirection(self, pitch)

        switch direction {
        case .ascending:
            guard let interval = Self._determineInterval(self, pitch)
            else { return nil }

            return DirectedInterval(interval: interval, direction: direction)

        case .descending:
            guard let interval = Self._determineInterval(pitch, self)
            else { return nil }

            return DirectedInterval(interval: interval, direction: direction)

        case .same:
            return DirectedInterval(interval: .unison, direction: direction)
        }
    }

    /// Returns this pitch transposed by the given directed interval.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed pitch, or `nil` if the result is out of range.
    public func transposed(by directedInterval: DirectedInterval<Interval>) -> Self? {
        let interval = directedInterval.interval
        let direction = directedInterval.direction

        guard let pc = Self._determinePitchClass(pitchClass,
                                                 interval,
                                                 direction)
        else { return nil }

        var rawOctave = octave.intValue

        switch direction {
        case .ascending:
            rawOctave += interval.octaveSpan

            if pc.letter.order < letter.order {
                rawOctave += 1
            }

        case .descending:
            rawOctave -= interval.octaveSpan

            if pc.letter.order > letter.order {
                rawOctave -= 1
            }

        case .same:
            break
        }

        guard let octave = Octave(intValue: rawOctave)
        else { return nil }

        return Self(pitchClass: pc,
                    octave: octave)
    }

    // MARK: Private Type Methods

    private static func _determineDirection(_ pitch1: Self,
                                            _ pitch2: Self) -> PitchDirection {
        if pitch1.octave < pitch2.octave {
            return .ascending
        }

        if pitch1.octave > pitch2.octave {
            return .descending
        }

        if pitch1.letter.order < pitch2.letter.order {
            return .ascending
        }

        if pitch1.letter.order > pitch2.letter.order {
            return .descending
        }

        if pitch1.accidental.order < pitch2.accidental.order {
            return .ascending
        }

        if pitch1.accidental.order > pitch2.accidental.order {
            return .descending
        }

        return .same
    }

    private static func _determineInterval(_ loPitch: Self,
                                           _ hiPitch: Self) -> Interval? {
        guard let loFifths = PerfectFifths.fifths(for: loPitch.pitchClass),
              let hiFifths = PerfectFifths.fifths(for: hiPitch.pitchClass),
              let interval = PerfectFifths.interval(for: hiFifths - loFifths)
        else { return nil }

        var rawOctave = hiPitch.octave.intValue - loPitch.octave.intValue

        if rawOctave > 0, loPitch.letter.order > hiPitch.letter.order {
            rawOctave -= 1
        }

        if rawOctave > 0 {
            guard let size = Interval.Size(intValue: interval.size.intValue + (rawOctave * 7))
            else { return nil }

            return Interval(interval.quality,
                            size)
        }

        return interval
    }

    private static func _determinePitchClass(_ pc: PitchClass,
                                             _ interval: Interval,
                                             _ direction: PitchDirection) -> PitchClass? {
        guard var pcFifths = PerfectFifths.fifths(for: pc),
              let iFifths = PerfectFifths.fifths(for: interval.simplified())
        else { return nil }

        switch direction {
        case .ascending:
            pcFifths += iFifths

        case .descending:
            pcFifths -= iFifths

        case .same:
            guard interval == .perfect1
            else { return nil }
        }

        return PerfectFifths.pitchClass(for: pcFifths)
    }
}

// MARK: - Sendable

extension Pitch: Sendable {
}
