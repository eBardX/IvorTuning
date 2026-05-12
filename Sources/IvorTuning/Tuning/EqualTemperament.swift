public import XestiNumbers

private import XestiTools

public struct EqualTemperament {

    // MARK: Public Initializers

    public init(divisions: Number,
                period: Ratio = .octave) {
        precondition(divisions > 1)
        precondition(period > 1)

        let stepSize = period.divided(by: divisions).require() // for now

        self.divisions = divisions
        self.perfectFifthSteps = Self._determineStepsInPerfectFifth(stepSize)
        self.period = period
        self.stepSize = stepSize
    }

    public init(stepSize: Ratio) {
        self.divisions = nil
        self.perfectFifthSteps = Self._determineStepsInPerfectFifth(stepSize)
        self.period = nil
        self.stepSize = stepSize
    }

    // MARK: Public Instance Properties

    public let divisions: Number?
    public let perfectFifthSteps: Int
    public let period: Ratio?
    public let stepSize: Ratio
}

// MARK: - TuningSystem

extension EqualTemperament: TuningSystem {

    // MARK: Public Instance Methods

    public func realize(interval: Interval) -> Ratio? {
        guard period == .octave,
              let divisions,
              divisions.isExact,
              divisions.isInteger
        else { return nil }

        let octaveSteps = divisions.intValue
        let commaSteps = (perfectFifthSteps * 7) - (octaveSteps * 4)

        let (simple, extra) = interval.deconstructed()

        guard let formula = Self._formula(for: simple)
        else { return nil }

        let steps = ((perfectFifthSteps * formula.fifths)
                     + (octaveSteps * formula.octaves)
                     + (commaSteps * formula.commas)
                     + (octaveSteps * Int(extra)))

        guard steps >= 0
        else { return nil }

        return stepSize.multiplied(by: Number(steps))
    }

    public func realize(pitch: Pitch,
                        standard: PitchStandard) -> Frequency? {
        guard let result = standard.pitch.interval(to: pitch),
              let ratio = realize(interval: result.interval)
        else { return nil }

        return standard.frequency.transposed(by: ratio,
                                             direction: result.direction)
    }

    // MARK: Private Nested Types

    private typealias BaseQualities = (diminished: Interval.Quality, augmented: Interval.Quality)
    private typealias Formula       = (fifths: Int, octaves: Int, commas: Int)

    // MARK: Private Type Properties

    private static let adjustments: [Interval.Quality: Int] = [.quadruplyDiminished: -4,
                                                               .triplyDiminished: -3,
                                                               .doublyDiminished: -2,
                                                               .diminished: -1,
                                                               .minor: 0,
                                                               .perfect: 0,
                                                               .major: 0,
                                                               .augmented: 1,
                                                               .doublyAugmented: 2,
                                                               .triplyAugmented: 3,
                                                               .quadruplyAugmented: 4]

    private static let baseQualities: [Int: BaseQualities] = [1: (.perfect, .perfect),
                                                              2: (.minor, .major),
                                                              3: (.minor, .major),
                                                              4: (.perfect, .perfect),
                                                              5: (.perfect, .perfect),
                                                              6: (.minor, .major),
                                                              7: (.minor, .major),
                                                              8: (.perfect, .perfect)]

    private static let formulas: [Interval: Formula] = [.perfect1: (0, 0, 0),
                                                        .minor2: (-5, 3, 0),
                                                        .major2: (2, -1, 0),
                                                        .minor3: (-3, 2, 0),
                                                        .major3: (4, -2, 0),
                                                        .perfect4: (-1, 1, 0),
                                                        .perfect5: (1, 0, 0),
                                                        .minor6: (-4, 3, 0),
                                                        .major6: (3, -1, 0),
                                                        .minor7: (-2, 2, 0),
                                                        .major7: (5, -2, 0),
                                                        .perfect8: (0, 1, 0)]

    // MARK: Private Type Methods

    private static func _baseInterval(for interval: Interval) -> Interval? {
        guard let baseQuality = baseQualities[interval.size.intValue]
        else { return nil }

        switch interval.quality {
        case .diminished,
             .doublyDiminished,
             .quadruplyDiminished,
             .triplyDiminished:
            return Interval(quality: baseQuality.diminished,
                            size: interval.size)

        case .augmented,
             .doublyAugmented,
             .quadruplyAugmented,
             .triplyAugmented:
            return Interval(quality: baseQuality.augmented,
                            size: interval.size)

        default:
            return interval
        }
    }

    private static func _formula(for interval: Interval) -> Formula? {
        guard let commas = adjustments[interval.quality]
        else { return nil }

        if commas != 0 {
            guard let baseInterval = _baseInterval(for: interval),
                  let baseFormula = formulas[baseInterval]
            else { return nil }

            return (baseFormula.fifths,
                    baseFormula.octaves,
                    commas)
        }

        return formulas[interval]
    }

    private static func _determineStepsInPerfectFifth(_ stepSize: Ratio) -> Int {
        round(log(1.5,
                  base: stepSize.numberValue)).exact.intValue
    }
}

// MARK: - Sendable

extension EqualTemperament: Sendable {
}
