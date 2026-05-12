public import XestiTools

extension Interval {

    // MARK: Public Nested Types

    public struct Size: IntRepresentable {

        // MARK: Public Type Methods

        public static func isValid(_ intValue: Int) -> Bool {
            intValue > 0
        }

        // MARK: Public Initializers

        public init?(intValue: Int) {
            guard Self.isValid(intValue)
            else { return nil }

            self.intValue = intValue
        }

        // MARK: Public Instance Methods

        public let intValue: Int
    }
}
