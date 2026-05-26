// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// Walks the chain from C outward with a single repeated fifth, then delegates to
// buildStandardConversion(for:ratioAt:). Suitable for ET and LT (uniform fifth).
// Descending steps use downFifth = octave/fifth to keep all intermediate ratios ≥ 1.
internal func buildStandardConversion(for standard: PitchStandard,
                                      fifthRatio: Ratio) -> [PitchClass: DirectedInterval<Ratio>] {
    let downFifth = Ratio.octave.sub(fifthRatio)

    var chainRatios: [Int: Ratio] = [0: .unison]

    for idx in 0..<19 {
        let next = chainRatios[idx].require().add(fifthRatio)

        chainRatios[idx + 1] = next >= .octave ? next.sub(.octave) : next
    }

    for idx in stride(from: 0, through: -14, by: -1) {
        let prev = chainRatios[idx].require().add(downFifth)

        chainRatios[idx - 1] = prev >= .octave ? prev.sub(.octave) : prev
    }

    return buildStandardConversion(for: standard) { chainRatios[$0].require() }
}

// Builds the 35-entry standard conversion from a chain-position-to-ratio mapping.
// ratioAt(idx) must return the octave-reduced ratio at fifth-chain position idx (C=0 = unison).
internal func buildStandardConversion(for standard: PitchStandard,
                                      ratioAt: (Int) -> Ratio) -> [PitchClass: DirectedInterval<Ratio>] {
    let refRatio = ratioAt(standard.pitch.pitchClass.fifthChainPosition)

    var result: [PitchClass: DirectedInterval<Ratio>] = [:]

    for letter in Pitch.Letter.allCases {
        for accidental in Pitch.Accidental.allCases {
            let pc = PitchClass(letter: letter,
                                accidental: accidental)
            let pcRatio = ratioAt(pc.fifthChainPosition)

            result[pc] = if pcRatio > refRatio {
                DirectedInterval(interval: pcRatio.sub(refRatio),
                                 direction: .ascending)
            } else if pcRatio < refRatio {
                DirectedInterval(interval: refRatio.sub(pcRatio),
                                 direction: .descending)
            } else {
                DirectedInterval(interval: .unison,
                                 direction: .same)
            }
        }
    }

    return result
}
