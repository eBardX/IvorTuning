// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers
import XestiTools

typealias IntervalResult = (interval: Interval, direction: PitchDirection)
typealias RatioResult = (interval: Ratio, direction: PitchDirection)

func assertEqual(_ freq1: Frequency?,
                 _ freq2: Frequency,
                 sourceLocation: SourceLocation = #_sourceLocation) {
    if let rv1 = freq1?.numberValue {
        let rv2 = freq2.numberValue

        if abs(rv1 - rv2) > epsilon {
            Issue.record("\(rv1) is not equal to \(rv2)",
                         sourceLocation: sourceLocation)
        }
    } else {
        #expect(freq1 == freq2,
                sourceLocation: sourceLocation)
    }
}

func assertEqual(_ result1: DirectedInterval<Interval>?,
                 _ result2: IntervalResult,
                 sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(result1?.interval == result2.interval,
            sourceLocation: sourceLocation)

    #expect(result1?.direction == result2.direction,
            sourceLocation: sourceLocation)
}

func assertEqual(_ ratio1: Ratio?,
                 _ ratio2: Ratio,
                 sourceLocation: SourceLocation = #_sourceLocation) {
    if let rv1 = ratio1?.numberValue {
        let rv2 = ratio2.numberValue

        if abs(rv1 - rv2) > epsilon {
            Issue.record("\(rv1) is not equal to \(rv2)",
                         sourceLocation: sourceLocation)
        }
    } else {
        #expect(ratio1 == ratio2,
                sourceLocation: sourceLocation)
    }
}

func assertEqual(_ result1: DirectedInterval<Ratio>?,
                 _ result2: RatioResult,
                 sourceLocation: SourceLocation = #_sourceLocation) {
    assertEqual(result1?.interval,
                result2.interval,
                sourceLocation: sourceLocation)

    #expect(result1?.direction == result2.direction,
            sourceLocation: sourceLocation)
}

func assertEqual(_ real1: Number?,
                 _ real2: Number?,
                 sourceLocation: SourceLocation = #_sourceLocation) {
    if let rv1 = real1,
       let rv2 = real2 {
        if abs(rv1 - rv2) > epsilon {
            Issue.record("\(rv1) is not equal to \(rv2)",
                         sourceLocation: sourceLocation)
        }
    } else {
        #expect(real1 == real2,
                sourceLocation: sourceLocation)
    }
}

// The frequency of Bohlen-Pierce degree 1 in the given layout’s tuning: the geometric mean of its
// keys for degrees 0 (key 60) and 2 (key 62).
func bohlenPierceDegree1(on layout: KeyboardLayout) throws -> Frequency {
    let toFrequency = try KeyboardToAbsolutePitchConverter(keyboardLayout: layout,
                                                           tuningSystem: EqualTemperament.bohlenPierce)
    let degree0 = try #require(toFrequency.convert(60)).numberValue
    let degree2 = try #require(toFrequency.convert(62)).numberValue

    return Frequency(sqrt(degree0 * degree2))
}

func circleCloses(_ wt: WellTemperament) -> Bool {
    guard let pure = Ratio(numberValue: Number(3) / Number(2))
    else {
        return false
    }

    let product = Fixtures.wellTemperamentFifths
        .map { wt.fifths[$0] ?? pure }
        .map(\.numberValue)
        .reduce(Number(1), *)

    return abs(product.doubleValue - 128) < 1e-6
}

// Calls the sequence form of `convert(_:)` through a generic `PitchConverter`, so that dispatch
// goes through the protocol rather than the concrete type.
func convertGenerically<C: PitchConverter>(_ converter: C,
                                           _ pitches: [C.FromPitchType]) -> [C.ToPitchType?] {
    converter.convert(pitches)
}

// Checks the documented contract of `ratio(forDegree:)`: degrees are `0..<count`, degree 0 is the
// unison, degrees ascend strictly within one period, and every other degree returns `nil`.
func expectDegreeContract(_ system: some TuningSystem,
                          count: Int,
                          sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(system.ratio(forDegree: 0) == .unison,
            sourceLocation: sourceLocation)
    #expect(system.ratio(forDegree: -1) == nil,
            sourceLocation: sourceLocation)
    #expect(system.ratio(forDegree: count) == nil,
            sourceLocation: sourceLocation)

    var previous: Ratio?

    for degree in 0..<count {
        guard let ratio = system.ratio(forDegree: degree)
        else {
            Issue.record("degree \(degree) has no ratio",
                         sourceLocation: sourceLocation)
            return
        }

        #expect(ratio < system.equivalenceRatio,
                sourceLocation: sourceLocation)

        if let previous {
            #expect(ratio > previous,
                    "degree \(degree) does not ascend",
                    sourceLocation: sourceLocation)
        }

        previous = ratio
    }
}

// The frequency of the given pitch class in a standard conversion anchored at A4 = 440 Hz,
// shifted by the given number of octaves.
func frequency(of pitchClass: PitchClass,
               in conversion: [PitchClass: DirectedInterval<Ratio>],
               octaveShift: Int = 0) throws -> Frequency {
    let entry = try #require(conversion[pitchClass])
    let frequency = try #require(PitchStandard.a440.frequency.transposed(by: entry))

    guard octaveShift != 0
    else { return frequency }

    let octave = DirectedInterval(interval: Ratio.octave,
                                  direction: octaveShift > 0 ? .ascending : .descending)

    return try #require(frequency.transposed(by: octave))
}

func makeKeyboardMap(_ layout: KeyboardLayout,
                     _ tuningSystem: some TuningSystem = EqualTemperament.edo12,
                     _ pitchStandard: PitchStandard = .a440) throws -> KeyboardMap {
    try KeyboardMap(keyboardLayout: layout,
                    tuningSystem: tuningSystem,
                    pitchStandard: pitchStandard)
}

private let epsilon = Number(0.000001)
