import IvorTuning
import Testing
import XestiNumbers

typealias IntervalResult = (interval: Interval, direction: IntervalDirection)
typealias RatioResult = (interval: Ratio, direction: IntervalDirection)

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

func assertEqual(_ result1: IntervalResult?,
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

func assertEqual(_ result1: RatioResult?,
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

private let epsilon = Number(0.000001)
