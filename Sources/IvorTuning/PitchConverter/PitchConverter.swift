// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that converts pitches from one notation to another.
public protocol PitchConverter: Equatable,
                                Sendable {

    // MARK: Associated Types

    /// The source pitch type.
    associatedtype FromPitchType: PitchProtocol

    /// The target pitch type.
    associatedtype ToPitchType: PitchProtocol

    // MARK: Instance Methods

    /// Converts the given pitch to the target notation.
    ///
    /// - Parameter pitch:  The source pitch to convert.
    ///
    /// - Returns:  The converted pitch in the target notation.
    func convert(_ pitch: FromPitchType) -> ToPitchType
}
