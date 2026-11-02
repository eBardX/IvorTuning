// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that converts pitches from one notation to another.
public protocol PitchConverter: Equatable,
                                Sendable {

    // MARK: Public Associated Types

    /// The source pitch type.
    associatedtype FromPitchType: PitchProtocol

    /// The target pitch type.
    associatedtype ToPitchType: PitchProtocol

    // MARK: Public Instance Methods

    /// Converts the given pitch to the target notation.
    ///
    /// - Parameter pitch:  The source pitch to convert.
    ///
    /// - Returns:  The converted pitch in the target notation, or `nil` if `pitch` has no
    ///             counterpart in the target notation.
    func convert(_ pitch: FromPitchType) -> ToPitchType?

    /// Converts a sequence of pitches to the target notation.
    ///
    /// Pass the pitches in performance order: by onset time, then from low to high within a chord.
    /// Converters whose results depend on context, such as the spelling converters, use the whole
    /// sequence; the others convert each pitch on its own. The default implementation maps
    /// ``convert(_:)-(FromPitchType)`` over the sequence.
    ///
    /// - Parameter pitches:    The source pitches to convert, in performance order.
    ///
    /// - Returns:  The converted pitches, index-aligned with `pitches`. An element is `nil` if its
    ///             pitch has no counterpart in the target notation.
    func convert(_ pitches: [FromPitchType]) -> [ToPitchType?]
}

// MARK: -

extension PitchConverter {

    // MARK: Public Instance Methods

    /// Converts each pitch of the sequence on its own, with ``convert(_:)-(FromPitchType)``.
    ///
    /// - Parameter pitches:    The source pitches to convert.
    ///
    /// - Returns:  The converted pitches, index-aligned with `pitches`.
    public func convert(_ pitches: [FromPitchType]) -> [ToPitchType?] {
        pitches.map { convert($0) }
    }
}
