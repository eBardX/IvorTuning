// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct IntervalSizeTests {
}

// MARK: -

extension IntervalSizeTests {

    @Test
    func init_invalid() {
        #expect(Interval.Size(intValue: 0) == nil)
        #expect(Interval.Size(intValue: -1) == nil)
    }

    @Test
    func init_valid() {
        #expect(Interval.Size(intValue: 1) != nil)
        #expect(Interval.Size(intValue: 8) != nil)
    }

    @Test
    func intValue() {
        #expect(Interval.Size(intValue: 5)?.intValue == 5)
    }

    @Test
    func isValid() {
        #expect(Interval.Size.isValid(1))
        #expect(!Interval.Size.isValid(0))
        #expect(!Interval.Size.isValid(-3))
    }
}
