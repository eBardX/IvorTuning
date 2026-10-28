// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers
private import XestiTools

extension KeyboardMap {

    // MARK: Public Type Properties

    /// The usual piano key assignments in 12-tone equal temperament, with A4 (MIDI note number
    /// 69) tuned to 415 Hz — the (modern) Baroque pitch standard.
    ///
    /// Pairs with ``PitchStandard/a415``.
    public static let a415 = _twelveTone(referenceNote: 69,
                                         referenceFrequency: 415)

    /// The usual piano key assignments in 12-tone equal temperament, with A4 (MIDI note number
    /// 69) tuned to 432 Hz — the Verdi pitch standard.
    ///
    /// Pairs with ``PitchStandard/a432``.
    public static let a432 = _twelveTone(referenceNote: 69,
                                         referenceFrequency: 432)

    /// The usual piano key assignments in 12-tone equal temperament, with A4 (MIDI note number
    /// 69) tuned to 435 Hz — the diapason normal pitch standard.
    ///
    /// Pairs with ``PitchStandard/a435``.
    public static let a435 = _twelveTone(referenceNote: 69,
                                         referenceFrequency: 435)

    /// The usual piano key assignments in 12-tone equal temperament, with A4 (MIDI note number
    /// 69) tuned to 440 Hz — the international concert pitch standard.
    ///
    /// The unison is placed on middle C (MIDI note number 60), and every MIDI note number is
    /// mapped. Pairs with ``PitchStandard/a440``.
    public static let a440 = _twelveTone(referenceNote: 69,
                                         referenceFrequency: 440)

    /// Bohlen-Pierce equal temperament: 13 keys per tritave (3:1), each step ¹³√3 ≈ 146.304
    /// cents.
    ///
    /// The unison is placed on middle C (MIDI note number 60) and tuned to that key’s frequency
    /// in ``a440`` (≈ 261.626 Hz), so the tritave pattern starts from conventional middle C. Every
    /// MIDI note number is mapped; MIDI note number 73 sounds a tritave above 60.
    public static let bohlenPierce = KeyboardMap(referenceNote: 60,
                                                 referenceFrequency: a440.realize(noteNumber: 60).require(),
                                                 middleNote: 60,
                                                 equivalenceRatio: .tritave,
                                                 ratios: (0..<13).map { Ratio.tritave.mul($0, 13) })

    /// The usual piano key assignments in 12-tone equal temperament, with C4 (MIDI note number
    /// 60) tuned to 256 Hz — the philosophical (scientific) pitch standard.
    ///
    /// Pairs with ``PitchStandard/c256``.
    public static let c256 = _twelveTone(referenceNote: 60,
                                         referenceFrequency: 256)

    // MARK: Private Type Methods

    private static func _twelveTone(referenceNote: NoteNumber,
                                    referenceFrequency: Frequency) -> KeyboardMap {
        KeyboardMap(referenceNote: referenceNote,
                    referenceFrequency: referenceFrequency,
                    middleNote: 60,
                    equivalenceRatio: .octave,
                    ratios: twelveToneRatios)
    }
}

// MARK: - Private Constants

private let twelveToneRatios: [Ratio?] = (0..<12).map { Ratio(cents: Number(100 * $0)) }
