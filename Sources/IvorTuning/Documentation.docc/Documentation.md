# ``IvorTuning``

@Metadata {
    @PageColor(blue)
}

Musical pitch, interval, and tuning system types.

## Overview

The IvorTuning framework provides musical pitch, interval, and tuning system
types written in Swift. Pitches and intervals are each available in standard,
keyboard, and absolute (frequency) representations. Several tuning systems are
provided, including equal temperament, just intonation, meantone temperament,
Pythagorean tuning, and well temperament.

```swift
import IvorTuning

let a4 = Pitch(plain: "A4")!

// Standard pitch to frequency, in quarter-comma meantone at A4 = 415 Hz.
let toFrequency = try StandardToAbsolutePitchConverter(tuningSystem: LinearTemperament.quarterCommaMeantone,
                                                       pitchStandard: .a415)

toFrequency.convert(a4)                     // 415 Hz

// Standard pitch to MIDI note number, on a 12-tone equal-tempered piano.
StandardToKeyboardPitchConverter().convert(a4)              // 69

// Spell a passage of MIDI note numbers in context.
KeyboardToStandardPitchConverter().convert([60, 63, 67, 70])    // C4, E♭4, G4, B♭4

// Intervals in standard notation.
a4.interval(to: Pitch(plain: "C#5")!)       // an ascending major third
```

See <doc:UsingIvorTuning> for a full guide to the pitch and interval types,
tuning systems, conversion between notations, keyboard layouts, and spelling.

## Topics

### Guides

- <doc:UsingIvorTuning>

### Standard notation

- ``Pitch``
- ``PitchClass``
- ``Interval``

### Absolute notation

- ``Frequency``
- ``Ratio``

### Keyboard notation

- ``NoteNumber``
- ``NoteDistance``

### Pitches and intervals in general

- ``PitchNotation``
- ``PitchProtocol``
- ``PitchDirection``
- ``IntervalProtocol``
- ``DirectedInterval``

### Tuning systems

- ``TuningSystem``
- ``EqualTemperament``
- ``JustIntonation``
- ``LinearTemperament``
- ``WellTemperament``
- ``PitchStandard``

### Converting between notations

- ``PitchConverter``
- ``StandardToAbsolutePitchConverter``
- ``StandardToKeyboardPitchConverter``
- ``AbsoluteToKeyboardPitchConverter``
- ``KeyboardToAbsolutePitchConverter``
- ``KeyboardToStandardPitchConverter``
- ``AbsoluteToStandardPitchConverter``

### Keyboard layouts

- ``KeyboardLayout``
- ``KeyMatching``

### Spelling

- ``PitchSpeller``
- ``MeredithPitchSpeller``
- ``KeyboardLayoutSpeller``

### Errors

- ``TuningError``
- ``ParseError``
