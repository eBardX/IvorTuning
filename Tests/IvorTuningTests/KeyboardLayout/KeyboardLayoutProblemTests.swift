// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct KeyboardLayoutProblemTests {
}

// MARK: -

extension KeyboardLayoutProblemTests {
    @Test
    func equality() {
        #expect(KeyboardLayout.Problem.duplicateSlot(index: 3) == .duplicateSlot(index: 3))
        #expect(KeyboardLayout.Problem.duplicateSlot(index: 3) != .duplicateSlot(index: 4))
        #expect(KeyboardLayout.Problem.duplicateSlot(index: 3) != .coincidentSlots(index: 3))
        #expect(KeyboardLayout.Problem.unmappedAnchor != .unmappedReference)
    }

    @Test
    func hashable() {
        let problems: Set<KeyboardLayout.Problem> = [.invalidRatio(index: 1),
                                                     .invalidRatio(index: 1),
                                                     .invalidRatio(index: 2),
                                                     .noMappedKeys]

        #expect(problems.count == 3)
    }

    @Test
    func message_indexedProblems() {
        #expect(KeyboardLayout.Problem.coincidentSlots(index: 4).message
                == "slot 4 sounds the same pitch as an earlier slot")
        #expect(KeyboardLayout.Problem.duplicateSlot(index: 2).message
                == "slot 2 has the same value as an earlier slot")
        #expect(KeyboardLayout.Problem.invalidRatio(index: 7).message
                == "ratio in slot 7 is not less than the equivalence ratio")
        #expect(KeyboardLayout.Problem.slotOutOfOrder(index: 5).message
                == "slot 5 is out of order")
        #expect(KeyboardLayout.Problem.slotOutsidePeriod(index: 11).message
                == "slot 11 lies outside the period")
        #expect(KeyboardLayout.Problem.unsupportedDegree(index: 0).message
                == "degree in slot 0 is not supported")
    }

    @Test
    func message_unindexedProblems() {
        #expect(KeyboardLayout.Problem.invalidEquivalenceRatio.message
                == "equivalence ratio is not greater than 1")
        #expect(KeyboardLayout.Problem.invalidFrequencyCount.message
                == "frequency layout does not have exactly 128 elements")
        #expect(KeyboardLayout.Problem.noMappedKeys.message
                == "no key is mapped")
        #expect(KeyboardLayout.Problem.notTwelveKeysPerOctave.message
                == "layout does not have 12 keys per octave")
        #expect(KeyboardLayout.Problem.pitchClassLayoutRequired.message
                == "a pitch-class layout is required without a pitch speller")
        #expect(KeyboardLayout.Problem.rawLayoutNotAllowed.message
                == "a raw layout cannot be used with a tuning system and pitch standard")
        #expect(KeyboardLayout.Problem.rawLayoutRequired.message
                == "a raw layout is required without a tuning system and pitch standard")
        #expect(KeyboardLayout.Problem.unmappedAnchor.message
                == "anchor slot is unmapped")
        #expect(KeyboardLayout.Problem.unmappedReference.message
                == "reference note is unmapped")
    }
}
