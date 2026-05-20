// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    /// An octave number in scientific pitch notation.
    public struct Octave: IntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given integer is a valid octave number.
        ///
        /// - Parameter intValue:   The integer to validate.
        ///
        /// - Returns:  `true` if `intValue` is in the range `-1...9`; otherwise, `false`.
        public static func isValid(_ intValue: Int) -> Bool {
            (-1...9) ~= intValue
        }

        // MARK: Public Initializers

        /// Creates an octave from its integer value.
        ///
        /// - Parameter intValue:   The octave number, in the range `-1...9`.
        ///
        /// - Returns:  `nil` if `intValue` is outside the valid range.
        public init?(intValue: Int) {
            guard Self.isValid(intValue)
            else { return nil }

            self.intValue = intValue
        }

        // MARK: Public Instance Properties

        /// The integer value of this octave number.
        public let intValue: Int
    }
}
