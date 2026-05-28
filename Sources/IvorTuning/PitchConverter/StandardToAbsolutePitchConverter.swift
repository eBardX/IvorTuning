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
    /// - Parameter tuningSystem:   The tuning system to use. Must support standard pitch notation.
    /// - Parameter pitchStandard:  The reference pitch and its frequency. Defaults to `.a440`.
    ///
    /// - Throws:   `TuningError.unsupportedStandardConversion` if `tuningSystem` does not support
    ///             standard pitch notation.
    public init(tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440) throws {
        guard let conv = tuningSystem.standardConversion(for: pitchStandard),
              conv.count == 35
        else { throw TuningError.unsupportedStandardConversion }

        self.conversion = conv
        self.referenceFrequency = pitchStandard.frequency
        self.referenceOctave = pitchStandard.pitch.octave
    }

    // MARK: Private Instance Properties

    private let conversion: [PitchClass: DirectedInterval<Ratio>]
    private let referenceFrequency: Frequency
    private let referenceOctave: Pitch.Octave
}

// MARK: -

extension StandardToAbsolutePitchConverter: PitchConverter {

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
