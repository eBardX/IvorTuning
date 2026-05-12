@testable import IvorTuning
import Testing

struct IntervalQualityTests {
}

// MARK: -

extension IntervalQualityTests {
    @Test
    func description() {
        #expect(Interval.Quality.augmented.description == "A")
        #expect(Interval.Quality.diminished.description == "d")
        #expect(Interval.Quality.doublyAugmented.description == "AA")
        #expect(Interval.Quality.doublyDiminished.description == "dd")
        #expect(Interval.Quality.major.description == "M")
        #expect(Interval.Quality.minor.description == "m")
        #expect(Interval.Quality.perfect.description == "P")
        #expect(Interval.Quality.quadruplyAugmented.description == "AAAA")
        #expect(Interval.Quality.quadruplyDiminished.description == "dddd")
        #expect(Interval.Quality.triplyAugmented.description == "AAA")
        #expect(Interval.Quality.triplyDiminished.description == "ddd")
    }

    @Test
    func inverted() {
        #expect(Interval.Quality.augmented.inverted() == .diminished)
        #expect(Interval.Quality.diminished.inverted() == .augmented)
        #expect(Interval.Quality.doublyAugmented.inverted() == .doublyDiminished)
        #expect(Interval.Quality.doublyDiminished.inverted() == .doublyAugmented)
        #expect(Interval.Quality.major.inverted() == .minor)
        #expect(Interval.Quality.minor.inverted() == .major)
        #expect(Interval.Quality.perfect.inverted() == .perfect)
        #expect(Interval.Quality.quadruplyAugmented.inverted() == .quadruplyDiminished)
        #expect(Interval.Quality.quadruplyDiminished.inverted() == .quadruplyAugmented)
        #expect(Interval.Quality.triplyAugmented.inverted() == .triplyDiminished)
        #expect(Interval.Quality.triplyDiminished.inverted() == .triplyAugmented)
    }
}
