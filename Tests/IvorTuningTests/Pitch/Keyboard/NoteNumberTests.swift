// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct NoteNumberTests {
}

// MARK: -

extension NoteNumberTests {
    @Test
    func comparable() {
        let n1: NoteNumber = 60
        let n2: NoteNumber = 72

        #expect(n1 < n2)
        #expect(n1 == n1)   // swiftlint:disable:this identical_operands
        #expect(n2 > n1)
    }

    @Test
    func doubleValue() {
        let n: NoteNumber = 60

        #expect(n.doubleValue == 60.0)
    }

    @Test
    func init_invalid() {
        #expect(NoteNumber(uintValue: 128) == nil)
    }

    @Test
    func init_valid() {
        #expect(NoteNumber(uintValue: 0) != nil)
        #expect(NoteNumber(uintValue: 64) != nil)
        #expect(NoteNumber(uintValue: 127) != nil)
    }

    @Test
    func interval_ascending() {
        let n60: NoteNumber = 60
        let n72: NoteNumber = 72
        let result = n60.interval(to: n72)

        #expect(result?.interval == 12)
        #expect(result?.direction == .ascending)
    }

    @Test
    func interval_descending() {
        let n60: NoteNumber = 60
        let n48: NoteNumber = 48
        let result = n60.interval(to: n48)

        #expect(result?.interval == 12)
        #expect(result?.direction == .descending)
    }

    @Test
    func interval_same() {
        let n60: NoteNumber = 60
        let result = n60.interval(to: n60)

        #expect(result?.interval == .unison)
        #expect(result?.direction == .same)
    }

    @Test
    func isValid() {
        #expect(NoteNumber.isValid(0))
        #expect(NoteNumber.isValid(127))
        #expect(!NoteNumber.isValid(128))
    }

    @Test
    func numberValue() {
        let n: NoteNumber = 60

        #expect(n.numberValue == 60)
    }

    @Test
    func transposed_ascending() {
        let n: NoteNumber = 60
        let d: NoteDistance = 12

        #expect(n.transposed(by: DirectedInterval(interval: d, direction: .ascending)) == 72)
    }

    @Test
    func transposed_descending() {
        let n: NoteNumber = 60
        let d: NoteDistance = 12

        #expect(n.transposed(by: DirectedInterval(interval: d, direction: .descending)) == 48)
    }

    @Test
    func transposed_same_unison() {
        let n: NoteNumber = 60

        #expect(n.transposed(by: DirectedInterval(interval: .unison, direction: .same)) == n)
    }
}
