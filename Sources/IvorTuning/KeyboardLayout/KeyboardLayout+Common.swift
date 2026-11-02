// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension KeyboardLayout {

    // MARK: Public Type Properties

    /// Bohlen-Pierce on 13 keys per tritave: degrees 0–12, one per key, with degree 0 on MIDI note
    /// number 60.
    ///
    /// MIDI note number 69 (degree 9) is the reference key, so with ``PitchStandard/a440`` it
    /// sounds 440 Hz, and key 60 sounds about 205.7 Hz. No established Bohlen-Pierce reference
    /// pitch exists; keeping MIDI note number 69 at the pitch standard’s frequency follows the MIDI
    /// tuning convention. Use it with ``EqualTemperament/bohlenPierce``.
    public static let bohlenPierce = (try? KeyboardLayout(degrees: Array(0..<13))).require()

    /// The piano keyboard: 12 keys per octave, spelled C C♯ D E♭ E F F♯ G G♯ A B♭ B, with C4 on
    /// MIDI note number 60.
    ///
    /// The spelling doesn’t matter in 12-tone equal temperament. With a meantone tuning, it gives
    /// the historical E♭–G♯ keyboard. This layout works with every tuning system that supports
    /// standard notation.
    public static let piano = (try? KeyboardLayout(pitchClasses: [.c,
                                                                  .cSharp,
                                                                  .d,
                                                                  .eFlat,
                                                                  .e,
                                                                  .f,
                                                                  .fSharp,
                                                                  .g,
                                                                  .gSharp,
                                                                  .a,
                                                                  .bFlat,
                                                                  .b])).require()
}
