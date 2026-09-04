// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct IntervalInvalidCombinationErrorTests {
}

// MARK: -

extension IntervalInvalidCombinationErrorTests {
    @Test
    func description() {
        let error = Interval.InvalidCombinationError(quality: .diminished, size: 1)

        #expect(error.description == "Quality \"d\" is not valid for size 1")
    }

    @Test
    func init_storesProperties() {
        let error = Interval.InvalidCombinationError(quality: .major, size: 4)

        #expect(error.quality == .major)
        #expect(error.size == 4)
    }
}
