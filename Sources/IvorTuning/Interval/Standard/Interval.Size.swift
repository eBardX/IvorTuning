// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension Interval {

    // MARK: Public Nested Types

    /// The diatonic size of a musical interval, expressed as a positive integer.
    public struct Size: IntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given integer is a valid interval size.
        ///
        /// - Parameter intValue:   The integer to validate.
        ///
        /// - Returns:  `true` if `intValue` is greater than zero; otherwise, `false`.
        public static func isValid(_ intValue: Int) -> Bool {
            intValue > 0
        }

        // MARK: Public Initializers

        /// Creates an interval size from a positive integer.
        ///
        /// - Parameter intValue:   A positive integer representing the diatonic size.
        ///
        /// - Returns:  `nil` if `intValue` is not positive.
        public init?(intValue: Int) {
            guard Self.isValid(intValue)
            else { return nil }

            self.intValue = intValue
        }

        // MARK: Public Instance Properties

        /// The integer value of this interval size.
        public let intValue: Int
    }
}
