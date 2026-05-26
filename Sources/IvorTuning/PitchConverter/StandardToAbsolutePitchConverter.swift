// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// Converts pitches in standard notation (``Pitch``) to absolute frequencies (``Frequency``)
/// using a pre-computed tuning table.
///
/// The converter is initialized from a ``TuningSystem`` that supports standard pitch notation
/// and a ``PitchStandard`` that anchors the conversion. The tuning system maps all 35 standard
/// pitch classes to frequency ratios relative to the reference pitch; the converter then applies
/// those ratios and adjusts for SPN octave to produce an absolute frequency.
public struct StandardToAbsolutePitchConverter {

    // MARK: Public Initializers

    /// Creates a converter for the given tuning system and pitch standard.
    ///
    /// - Parameter tuning:     The tuning system to use. Must support standard pitch notation.
    /// - Parameter standard:   The reference pitch and its frequency. Defaults to `.a440`.
    ///
    /// - Throws:   `TuningError.unsupportedStandardConversion` if `tuning` does not support
    ///             standard pitch notation.
    public init(tuning: some TuningSystem,
                standard: PitchStandard = .a440) throws {
        guard let conv = tuning.standardConversion(for: standard),
              conv.count == 35
        else { throw TuningError.unsupportedStandardConversion }

        self.conversion = conv
        self.referenceFrequency = standard.frequency
        self.referenceOctave = standard.pitch.octave
    }

    // MARK: Private Instance Properties

    private let conversion: [PitchClass: DirectedInterval<Ratio>]
    private let referenceFrequency: Frequency
    private let referenceOctave: Pitch.Octave
}

// MARK: -

extension StandardToAbsolutePitchConverter {

    // MARK: Public Instance Methods

    /// Returns the absolute frequency of the given pitch.
    ///
    /// - Parameter pitch:  The pitch to convert.
    ///
    /// - Returns:  The frequency of `pitch` in the tuning system used to initialize this converter.
    public func convert(_ pitch: Pitch) -> Frequency {
        let directedInterval = conversion[pitch.pitchClass].require()
        let baseFrequency = referenceFrequency.transposed(by: directedInterval).require()
        let octaveShift = pitch.octave.intValue - referenceOctave.intValue

        guard octaveShift != 0
        else { return baseFrequency }

        let octaveRatio = Ratio.octave.mul(octaveShift > 0
                                           ? octaveShift
                                           : -octaveShift)
        let octaveInterval = DirectedInterval(interval: octaveRatio,
                                              direction: octaveShift > 0
                                                          ? .ascending
                                                          : .descending)

        return baseFrequency.transposed(by: octaveInterval).require()
    }
}

// MARK: - Sendable

extension StandardToAbsolutePitchConverter: Sendable {
}
