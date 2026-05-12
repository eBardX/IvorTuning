public import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    public struct Octave: IntRepresentable {

        // MARK: Public Type Methods

        public static func isValid(_ intValue: Int) -> Bool {
            (-1...9) ~= intValue
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
