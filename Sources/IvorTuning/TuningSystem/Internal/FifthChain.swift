// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers
private import XestiTools

// MARK: Internal Functions

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
    let refValue = _spnOctaveValue(at: standard.pitch.pitchClass.fifthChainPosition,
                                   ratioAt: ratioAt)

    var result: [PitchClass: DirectedInterval<Ratio>] = [:]

    for letter in Pitch.Letter.allCases {
        for accidental in Pitch.Accidental.allCases {
            let pc = PitchClass(letter: letter,
                                accidental: accidental)
            let pcValue = _spnOctaveValue(at: pc.fifthChainPosition,
                                          ratioAt: ratioAt)

            result[pc] = if pcValue > refValue {
                DirectedInterval(interval: Ratio(pcValue / refValue),
                                 direction: .ascending)
            } else if pcValue < refValue {
                DirectedInterval(interval: Ratio(refValue / pcValue),
                                 direction: .descending)
            } else {
                DirectedInterval(interval: .unison,
                                 direction: .same)
            }
        }
    }

    return result
}

// MARK: Private Functions

// Returns the frequency ratio above C of the pitch class at fifth-chain position idx,
// placed in the SPN octave of its letter rather than octave-reduced by sound: Cb lies
// just below C (< 1) and B# just above B (≥ 2). The pitch class sits nominally
// 7·idx − 12·⌊4·idx/7⌋ semitones above C (Cb = −1, B# = 12, B𝄪 = 13); the octave
// shift that brings the tuned ratio nearest that nominal position is chosen.
private func _spnOctaveValue(at idx: Int,
                             ratioAt: (Int) -> Ratio) -> Number {
    let letterOctaves = (4 * idx - (4 * idx).modulo(7)) / 7
    let nominalSemitones = 7 * idx - 12 * letterOctaves
    let value = ratioAt(idx).numberValue
    let logOctave = log(Number(2))
    let target = logOctave * Number(nominalSemitones) / Number(12)

    let half = Number(1) / Number(2)
    let candidates = [value * half, value, value * Number(2)]

    return candidates.min { abs(log($0) - target) < abs(log($1) - target) }.require()
}
