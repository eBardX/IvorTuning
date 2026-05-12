@testable import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct NoteDistanceTests {
}

// MARK: -

extension NoteDistanceTests {
    @Test
    func adding_overflow() {
        let d: NoteDistance = 120

        #expect(d.adding(10) == nil)
    }

    @Test
    func adding_valid() {
        let d: NoteDistance = 7

        #expect(d.adding(3) == 10)
    }

    @Test
    func comparable() {
        let d1: NoteDistance = 1
        let d2: NoteDistance = 2

        #expect(d1 < d2)
        #expect(d1 == d1) // swiftlint:disable:this identical_operands
        #expect(d2 > d1)
    }

    @Test
    func doubleValue() {
        let d: NoteDistance = 5

        #expect(d.doubleValue == 5.0)
    }

    @Test
    func init_invalid() {
        #expect(NoteDistance(uintValue: 128) == nil)
    }

    @Test
    func init_valid() {
        #expect(NoteDistance(uintValue: 0) != nil)
        #expect(NoteDistance(uintValue: 64) != nil)
        #expect(NoteDistance(uintValue: 127) != nil)
    }

    @Test
    func isUnison() {
        let d: NoteDistance = 1

        #expect(NoteDistance.unison.isUnison)
        #expect(!d.isUnison)
    }

    @Test
    func isValid() {
        #expect(NoteDistance.isValid(0))
        #expect(NoteDistance.isValid(127))
        #expect(!NoteDistance.isValid(128))
    }

    @Test
    func numberValue() {
        let d: NoteDistance = 12

        #expect(d.numberValue == 12)
    }

    @Test
    func subtracting_valid() {
        let d: NoteDistance = 7

        #expect(d.subtracting(3) == 4)
    }

    @Test
    func unison() {
        #expect(NoteDistance.unison == NoteDistance(uintValue: 0))
    }
}
