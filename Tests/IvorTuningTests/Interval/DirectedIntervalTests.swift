// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct DirectedIntervalTests {
}

// MARK: -

extension DirectedIntervalTests {
    @Test
    func codable_ascending() throws {
        let original = DirectedInterval(interval: Interval.major2, direction: .ascending)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DirectedInterval<Interval>.self, from: data)

        #expect(decoded.direction == original.direction)
        #expect(decoded.interval == original.interval)
    }

    @Test
    func codable_descending() throws {
        let original = DirectedInterval(interval: Interval.minor3, direction: .descending)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DirectedInterval<Interval>.self, from: data)

        #expect(decoded.direction == original.direction)
        #expect(decoded.interval == original.interval)
    }

    @Test
    func codable_same() throws {
        let original = DirectedInterval(interval: Interval.perfect1, direction: .same)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DirectedInterval<Interval>.self, from: data)

        #expect(decoded.direction == original.direction)
        #expect(decoded.interval == original.interval)
    }

    @Test
    func init_ascending() {
        let di = DirectedInterval(interval: Interval.major2, direction: .ascending)

        #expect(di.direction == .ascending)
        #expect(di.interval == Interval.major2)
    }

    @Test
    func init_descending() {
        let di = DirectedInterval(interval: Interval.minor3, direction: .descending)

        #expect(di.direction == .descending)
        #expect(di.interval == Interval.minor3)
    }

    @Test
    func init_same() {
        let di = DirectedInterval(interval: Interval.perfect1, direction: .same)

        #expect(di.direction == .same)
        #expect(di.interval == Interval.perfect1)
    }
}
