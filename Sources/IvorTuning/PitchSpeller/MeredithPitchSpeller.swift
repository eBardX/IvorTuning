// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A pitch speller that applies the PS13S1 algorithm from Meredith (2006).
///
/// PS13S1 assigns each note the pitch name most strongly implied by the local
/// tonal context, modelled as the frequency distribution of chromas within a
/// sliding window surrounding each note.
public struct MeredithPitchSpeller {

    // MARK: Public Initializers

    /// Creates a pitch speller with the given context window sizes.
    ///
    /// - Parameter contextBefore:  The number of preceding notes to include in
    ///                             the context window for each note. Defaults to
    ///                             the paper's recommended value of 10.
    /// - Parameter contextAfter:   The number of following notes to include in
    ///                             the context window for each note. Defaults to
    ///                             the paper's recommended value of 42.
    public init(contextBefore: Int = 10,
                contextAfter: Int = 42) {
        self.contextAfter = contextAfter
        self.contextBefore = contextBefore
    }

    // MARK: Public Instance Properties

    /// The number of following notes included in the context window.
    public let contextAfter: Int

    /// The number of preceding notes included in the context window.
    public let contextBefore: Int
}

// MARK: - PitchSpeller

extension MeredithPitchSpeller: PitchSpeller {

    // MARK: Public Instance Methods

    public func spell(_ noteNumbers: [NoteNumber]) -> [Pitch] {
        _applyPS13S1(to: noteNumbers.map { Int($0.uintValue) - 21 })
    }

    // MARK: Private Type Aliases

    private typealias Chroma = Int          // chromatic pitch mod 12
    private typealias ChromaticPitch = Int  // A0 == 0, C4 == 39, MIDI note number == chromatic pitch + 21
    private typealias Morph = Int           // morphetic pitch mod 7
    private typealias MorpheticPitch = Int  // A0 == 0, Ab0 == 0, C4 == 23, C#4 == 23

    // MARK: Private Type Properties

    private static let accidentalByDisplacement: [Int: Pitch.Accidental] = [-2: .doubleFlat,
                                                                            -1: .flat,
                                                                            0: .natural,
                                                                            1: .sharp,
                                                                            2: .doubleSharp]

    private static let defaultChromaToMorph: [Int] = [0, 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 6]

    private static let letters: [Pitch.Letter] = [.a, .b, .c, .d, .e, .f, .g]

    private static let naturalChromas: [Int] = [0, 2, 3, 5, 7, 8, 10]

    private static let semitonesToMorphInterval: [Int] = [0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6]

    private static let zeros12: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    // MARK: Private Instance Methods

    private func _applyPS13S1(to pitches: [ChromaticPitch]) -> [Pitch] {
        guard !pitches.isEmpty
        else { return [] }

        let chromas = _computeChromas(pitches)
        let chromaFrequencies = _computeChromaFrequencies(chromas, contextBefore, contextAfter)
        let morphs = _computeMorphs(chromas, chromaFrequencies)
        let morpheticPitches = _computeMorpheticPitches(pitches, morphs)

        return _computePitches(pitches, morpheticPitches)
    }

    private func _computeChromaFrequencies(_ chromas: [Chroma],
                                           _ contextBefore: Int,
                                           _ contextAfter: Int) -> [[Int]] {
        let count = chromas.count

        var windowCounts = Self.zeros12

        for idx in 0..<min(count, contextAfter) {
            windowCounts[chromas[idx]] += 1
        }

        var frequencyList = [windowCounts]

        for idx in 1..<count {
            if idx + contextAfter <= count {
                windowCounts[chromas[idx + contextAfter - 1]] += 1
            }

            if idx - contextBefore > 0 {
                windowCounts[chromas[idx - contextBefore - 1]] -= 1
            }

            frequencyList.append(windowCounts)
        }

        return frequencyList
    }

    private func _computeChromas(_ pitches: [ChromaticPitch]) -> [Chroma] {
        pitches.map { $0.modulo(12) }
    }

    private func _computeMorpheticPitches(_ pitches: [ChromaticPitch],
                                          _ morphs: [Morph]) -> [MorpheticPitch] {
        (0..<pitches.count).map { idx in
            let chromaticPitch = pitches[idx]
            let morph = morphs[idx]
            let baseOctave = (chromaticPitch - chromaticPitch.modulo(12)) / 12
            let chroma = Double(chromaticPitch.modulo(12))

            // Continuous position of the chromatic pitch within its octave
            let chromaticPosition = Double(baseOctave) + chroma / 12.0

            // Candidate morphetic pitches in adjacent octaves
            let candidates = [baseOctave, baseOctave + 1, baseOctave - 1].map { octave in
                (octave: octave, position: Double(octave) + Double(morph) / 7.0)
            }

            // Choose the octave whose morphetic position is closest to the
            // chromatic position
            let bestOctave = candidates.min {
                abs($0.position - chromaticPosition) < abs($1.position - chromaticPosition)
            }.require().octave

            return morph + 7 * bestOctave
        }
    }

    private func _computeMorphs(_ chromas: [Chroma],
                                _ chromaFrequencies: [[Int]]) -> [Morph] {
        let count = chromas.count

        // Bootstrap: assign a morph to the first note arbitrarily
        let firstChroma = chromas[0]
        let firstMorph = Self.defaultChromaToMorph[firstChroma]

        // For each possible tonic chroma, compute which morph it implies for
        // the first note, then store the tonic's own morph
        var tonicMorph = Self.zeros12

        for tonicChroma in 0...11 {
            tonicMorph[tonicChroma] = (firstMorph - Self.semitonesToMorphInterval[(firstChroma - tonicChroma).modulo(12)]).modulo(7)
        }

        var morphStrengths: [Int] = [0, 0, 0, 0, 0, 0, 0]
        var impliedMorphForTonic = Self.zeros12
        var morphs = [Morph](repeating: 0,
                             count: count)

        for noteIndex in 0..<count {
            let chroma = chromas[noteIndex]

            // For each tonic chroma, compute which morph it implies for this note
            for tonicChroma in 0...11 {
                impliedMorphForTonic[tonicChroma] = (Self.semitonesToMorphInterval[(chroma - tonicChroma).modulo(12)] +
                                                     tonicMorph[tonicChroma]).modulo(7)
            }

            // Sum the frequency of each tonic chroma in the context window
            // to get the total strength of implication for each morph
            for morph in 0...6 {
                morphStrengths[morph] = 0
            }

            for tonicChroma in 0...11 {
                morphStrengths[impliedMorphForTonic[tonicChroma]] += chromaFrequencies[noteIndex][tonicChroma]
            }

            // Assign the most strongly implied morph
            morphs[noteIndex] = morphStrengths.indices.max { morphStrengths[$0] < morphStrengths[$1] }.require()
        }

        return morphs
    }

    private func _computePitches(_ pitches: [ChromaticPitch],
                                 _ morpheticPitches: [MorpheticPitch]) -> [Pitch] {
        (0..<pitches.count).map {
            _pitchFrom(chromatic: pitches[$0],
                       morphetic: morpheticPitches[$0])
        }
    }

    private func _pitchFrom(chromatic chromaticPitch: ChromaticPitch,
                            morphetic morpheticPitch: MorpheticPitch) -> Pitch {
        let morph = morpheticPitch.modulo(7)
        let displacement = chromaticPitch - (12 * (morpheticPitch / 7)) - Self.naturalChromas[morph]

        let accidental = Self.accidentalByDisplacement[displacement]
            .require(hint: "Unexpected PS13S1 displacement: \(displacement)")

        var octave = morpheticPitch / 7

        if morph > 1 {
            octave += 1
        }

        return Pitch(pitchClass: PitchClass(letter: Self.letters[morph],
                                            accidental: accidental),
                     octave: Pitch.Octave(intValue: octave).require())
    }
}

// MARK: - Sendable

extension MeredithPitchSpeller: Sendable {
}
