import IvorTuning
import Testing
import XestiNumbers

struct PitchStandardTests {
}

// MARK: -

extension PitchStandardTests {
    @Test
    func a415() {
        #expect(PitchStandard.a415.pitch == .a4)
        #expect(PitchStandard.a415.frequency == 415)
    }

    @Test
    func a432() {
        #expect(PitchStandard.a432.pitch == .a4)
        #expect(PitchStandard.a432.frequency == 432)
    }

    @Test
    func a435() {
        #expect(PitchStandard.a435.pitch == .a4)
        #expect(PitchStandard.a435.frequency == 435)
    }

    @Test
    func a440() {
        #expect(PitchStandard.a440.pitch == .a4)
        #expect(PitchStandard.a440.frequency == 440)
    }

    @Test
    func c256() {
        #expect(PitchStandard.c256.pitch == .c4)
        #expect(PitchStandard.c256.frequency == 256)
    }
}
