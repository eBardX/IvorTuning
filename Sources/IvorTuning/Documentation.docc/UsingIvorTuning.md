# Using IvorTuning

Represent pitches and intervals in standard, keyboard, and absolute notation,
and convert between them in any tuning system.

## Overview

IvorTuning has three pitch notations, each with a pitch type and an interval
type:

 Notation                       | Pitch type        | Interval type      | Represents
:-------                        |:----------        |:-------------      |:----------
 ``PitchNotation/standard``     | ``Pitch``         | ``Interval``       | Letter, accidental, and octave
 ``PitchNotation/absolute``     | ``Frequency``     | ``Ratio``          | Frequency in hertz, and frequency ratio
 ``PitchNotation/keyboard``     | ``NoteNumber``    | ``NoteDistance``   | MIDI note number, and semitone distance

A ``TuningSystem`` says how standard pitches sound, a ``PitchStandard`` anchors
it to a frequency, and a ``KeyboardLayout`` says what each key of a keyboard
plays. One ``PitchConverter`` converts each of the six directions between the
notations.

## Pitches

A ``Pitch`` is a ``PitchClass`` — one of 7 letters with one of 5 accidentals,
35 pitch classes in all — in a scientific pitch notation octave from −1 to 9.
The octave number goes up at C, so B3 is just below C4. Enharmonic spellings
are distinct values: C♯4 and D♭4 are different pitches.

```swift
let a4      = Pitch(plain: "A4")!
let cSharp5 = try Pitch(stringValue: "C#5")

cSharp5.stringValue()               // "C♯5"
cSharp5.plain                       // "C#5"
```

Every pitch and pitch class also has a constant, such as `Pitch.c4` and
`PitchClass.bFlat`. Pitches sort by their notation — octave, then letter, then
accidental — which is a consistent order, not a comparison of how high they
sound: that depends on the tuning system.

A ``Frequency`` is a positive number of hertz, kept as an exact whole number of
microhertz; an integer literal is a number of hertz. A ``NoteNumber`` is a MIDI
note number from 0 to 127. ``Frequency/Reference`` measures frequencies on a
logarithmic scale, such as absolute cents, where 440 Hz is 6900.

## Intervals

Each pitch type measures the interval to another pitch with `interval(to:)`,
and moves by one with `transposed(by:)`. Both use a ``DirectedInterval``: an
interval and a ``PitchDirection``, which is ascending, descending, or the same.

```swift
let third = a4.interval(to: cSharp5)!       // ascending M3

a4.transposed(by: DirectedInterval(interval: .perfect5, direction: .ascending))  // E5
```

- An ``Interval`` is a quality and a diatonic size, such as `M3` or `P5`. Like
  pitches, intervals are enharmonically distinct: an augmented unison is not a
  minor second. Intervals invert, simplify to within an octave, and have
  constants such as `Interval.major3`. ``Interval/init(quality:size:)`` throws
  an `Interval.InvalidCombinationError` for a quality that doesn’t fit the
  size, such as a major fifth.
- A ``Ratio`` is a frequency ratio of at least 1:1, held exactly where
  possible. It converts to and from cents, millioctaves, savarts, and hekts
  (``Ratio/Unit``), and has the constants ``Ratio/unison``, ``Ratio/octave``,
  and ``Ratio/tritave``.
- A ``NoteDistance`` is a number of semitones from 0 to 127.

`transposed(by:)` returns `nil` when the result leaves the pitch type’s range.

## Tuning systems

A ``TuningSystem`` has an interval of equivalence — usually the octave — and
may support two things: **standard notation**, through
``TuningSystem/standardConversion(for:)``, and **degrees**, numbered from 0
within one period, through ``TuningSystem/ratio(forDegree:)``.

 Family                    | Presets                                                                                   | Standard notation         | Degrees
:-----                     |:-------                                                                                   |:-----------------         |:-------
 ``EqualTemperament``      | `edo12`, `edo19`, `edo22`, `edo24`, `edo31`, `edo53`, `bohlenPierce`, `carlosAlpha`, `carlosBeta`, `carlosGamma` | Octave periods of at most 35 steps | Yes
 ``LinearTemperament``     | `pythagorean`, `quarterCommaMeantone`, `thirdCommaMeantone`, `sixthCommaMeantone`, `twoSeventhCommaMeantone` | Yes                       | No
 ``WellTemperament``       | `kellner`, `kirnbergerII`, `kirnbergerIII`, `neidhardtI`, `neidhardtII`, `neidhardtIII`, `vallotti`, `werckmeisterIII`, `youngI`, `youngII` | Yes                       | Yes (12)
 ``JustIntonation``        | `fiveLimitJI`, `sevenLimitJI`, `partch43`                                                 | No                        | Yes

Standard notation needs an octave period and at most 35 distinct pitch
classes, so Bohlen-Pierce (which repeats at the tritave) and 53-EDO cannot
use it. Just intonation never does: even a 5-limit scale has enharmonic pairs
that sound different but share one spelling. A few other equal temperaments
that pass the checks, such as 17-EDO, may spell unexpectedly. A linear
temperament has an open chain of fifths, so it gives each of the 35 spellings
its own pitch — in quarter-comma meantone, G♯ lies about 41¢ below A♭ — but
has no finite set of degrees.

A ``PitchStandard`` ties one pitch to a frequency. The presets are `a415`
(Baroque pitch), `a432`, `a435`, `a440` (concert pitch), and `c256`.

## Converting between notations

There is one converter for each direction:

 From          | To            | Converter                                     | Built from
:---           |:--            |:---------                                     |:----------
 standard      | absolute      | ``StandardToAbsolutePitchConverter``          | Tuning system, pitch standard
 standard      | keyboard      | ``StandardToKeyboardPitchConverter``          | Tuning system, pitch standard, layout
 absolute      | keyboard      | ``AbsoluteToKeyboardPitchConverter``          | Layout (plus tuning system and pitch standard, unless the layout is raw)
 keyboard      | absolute      | ``KeyboardToAbsolutePitchConverter``          | Layout (plus tuning system and pitch standard, unless the layout is raw)
 keyboard      | standard      | ``KeyboardToStandardPitchConverter``          | Layout, plus a speller or the layout’s own spelling
 absolute      | standard      | ``AbsoluteToStandardPitchConverter``          | Layout, plus a speller or the layout’s own spelling

Every converter except the first has a non-throwing `init()` for the usual
12-tone equal-tempered piano at A4 = 440 Hz; the two spelling converters’
defaults spell with a ``MeredithPitchSpeller``. The other initializers throw a
``TuningError`` if the configuration can’t work — a tuning system without
standard notation where one is needed, or a layout that is invalid in the
given tuning — so `convert(_:)` never fails because of the configuration.

`convert(_:)` returns `nil` only when a pitch has no counterpart in the target
notation: a written pitch beyond MIDI’s 0–127, a key the layout leaves
unmapped, or a frequency too far from every key. Converters whose conversion
always succeeds, such as ``StandardToAbsolutePitchConverter``, document that
they never return `nil`. ``PitchNotation/isConversionSupported(to:)`` is `true`
for every pair of distinct notations.

### Standard to absolute

``StandardToAbsolutePitchConverter`` tunes each written pitch in the tuning
system, relative to the pitch standard:

```swift
let meantone = try StandardToAbsolutePitchConverter(tuningSystem: LinearTemperament.quarterCommaMeantone)

meantone.convert(Pitch(plain: "G#4")!)      // about 411.2 Hz
meantone.convert(Pitch(plain: "Ab4")!)      // about 421.1 Hz
```

It throws ``TuningError/unsupportedStandardConversion`` for a tuning system
that does not support standard notation. Each spelling keeps the octave of its
letter, not of its sound: C♭4 sounds just below C4, and B♯4 just above B4.

### Converting a passage

``PitchConverter`` has two forms of `convert(_:)`: one pitch, and an array of
pitches in performance order — by onset, then from low to high within a chord.
Most converters treat each pitch on its own, but spelling depends on context,
so the two spelling converters use the whole passage. Convert a passage with
the array form; a spelling converter’s single-pitch form gives a lone note no
context.

## Keyboard layouts

A ``KeyboardLayout`` says which keys of a keyboard are mapped and what each
one plays. It holds no frequencies of its own, except in its two low-level
forms: the frequencies come from the tuning system and pitch standard the
converter is given, so the three can never disagree. There are four kinds,
one per initializer:

 Kind           | Initializer                                                                        | Each slot holds           | Keys tuned by
:---            |:----------                                                                         |:--------------            |:------------
 Pitch class    | ``KeyboardLayout/init(pitchClasses:anchorNote:anchorOctave:)``                    | A spelled pitch class     | Tuning system and pitch standard
 Degree         | ``KeyboardLayout/init(degrees:anchorNote:referenceNote:)``                        | A tuning-system degree    | Tuning system and pitch standard
 Raw ratio      | ``KeyboardLayout/init(ratios:equivalenceRatio:anchorNote:referenceNote:referenceFrequency:)`` | A ratio above the anchor | The layout itself
 Frequency      | ``KeyboardLayout/init(frequencies:)``                                             | One key’s frequency       | The layout itself

Slot `i` is key `anchorNote + i`, and the slots repeat every period — one
interval of equivalence — outward from the anchor; a frequency layout instead
lists all 128 keys. A `nil` slot leaves its keys unmapped. The presets are
``KeyboardLayout/piano`` — 12 keys per octave, C C♯ D E♭ E F F♯ G G♯ A B♭ B,
with C4 on MIDI 60 — and ``KeyboardLayout/bohlenPierce``, which plays degrees
0–12 one per key, with degree 0 on MIDI 60 and MIDI 69 as the reference key.

**Pitch-class and degree layouts** list their slots in ascending order of
sound within one period, starting with slot 0, which must be mapped. Each later
slot takes the lowest octave (or period) of its pitch class (or degree) that
sounds above the previous mapped slot, so spellings that cross the octave keep
their real place: in a C-to-C layout, a final C♭ slot is C♭5. Slot 0 need not
be C. A degree layout names a `referenceNote`, which must be mapped and sounds
the pitch standard’s frequency. A degree layout needs a tuning system with
degrees, so ``LinearTemperament`` supports only pitch-class layouts.

**Raw layouts** — raw-ratio and frequency layouts — tune themselves, for
tunings the library can’t express, such as a Scala `.scl`/`.kbm` pair or a
per-key tuning table. They may go down in pitch from one key to the next, and
two keys may sound the same pitch. The `absolute` converters take a raw layout
only through their short initializer, `init(keyboardLayout:)`, which has no
tuning system or pitch standard to ignore; their full initializers reject a raw
layout.

A ``KeyboardLayout`` stores only the arguments it was made from, as a
``KeyboardLayout/Definition``, which ``KeyboardLayout/init(_:)`` turns back
into a layout. Two layouts are equal when their definitions are, and a decoded
layout is validated exactly like a new one.

### Validation

A layout is checked in two stages, and both throw
``TuningError/invalidKeyboardLayout(_:)`` with a ``KeyboardLayout/Problem``
that names the reason and, where there is one, the slot:

- **When it is made**, for everything that needs no tuning system: slot 0 is
  mapped, no pitch class or degree appears twice, degrees ascend (wrapping at
  most once), the reference note is mapped, and a raw layout’s ratios and
  frequency count are in range.
- **When a converter is made**, for everything that does: a pitch-class
  layout’s slots ascend in sound within one period, and no two sound the same;
  every listed degree exists in the tuning system; and the layout is the right
  kind for that initializer.

Validity can depend on the pairing. A split-key meantone layout that lists G♯
before A♭ is valid in quarter-comma meantone and 19-EDO, where G♯ is the lower,
but not in Pythagorean tuning, where it is the higher. A layout without
enharmonic pairs, such as ``KeyboardLayout/piano``, is valid with every tuning
system that supports standard notation.

### Finding the nearest key

Converting to `keyboard` from a written pitch or a frequency picks the mapped
key that **sounds** nearest. With a 12-tone equal-tempered piano that is the
usual answer — B♯3, C4, and D𝄫4 all go to key 60 — and it generalizes to any
layout. Two consequences follow:

- **The pitch standard tunes the keyboard; it doesn’t transpose.** With
  `.a415`, written A4 still goes to key 69, which now sounds 415 Hz.
- **Other tunings follow the sound, not the spelling.** In quarter-comma
  meantone, ``KeyboardLayout/piano``’s keys are tuned in meantone too, so a
  written D♯4, which has no key of its own, goes to the E♭4 key (63).

**Ties.** Two keys equally near — within 0.001¢ — are a tie. A written pitch’s
tie goes to the key spelled with its letter, if exactly one of them is;
otherwise, and always for a frequency, it goes to the lower key.

**Edges.** Beyond the lowest or highest mapped key, a pitch matches that key
only within half the step to the next distinct pitch inward — 50¢ past MIDI 0
or 127 on a 12-tone equal-tempered piano.

**Key matching.** By default (``KeyMatching/nearest``) a pitch goes to the
nearest key however far away it is. ``KeyMatching/within(_:)`` makes a pitch
farther than a tolerance from every key convert to `nil` instead, which suits
material that should lie entirely on the layout:

```swift
let strict = try AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano,
                                                  tuningSystem: EqualTemperament.edo12,
                                                  keyMatching: .within(Ratio(cents: 5)))

strict.convert(441)     // 69: within 5¢ of A4
strict.convert(445)     // nil: about 20¢ away
```

## Spelling

Converting to `standard` needs a spelling for each key. There are two ways to
get one:

- **A ``PitchSpeller``** spells a passage of note numbers in context.
  ``MeredithPitchSpeller`` implements Meredith’s PS13S1 algorithm: each note
  gets the spelling its surrounding notes most strongly imply. Its context
  windows default to 10 notes before and 42 after, and a lone note gets the
  default spelling — naturals, and B♭, C♯, E♭, F♯, and G♯. It assumes 12-tone
  equal temperament.
- **A pitch-class layout’s own spelling.** Without a speller, the spelling
  converters spell each key as the layout names it — on a 12-key meantone
  keyboard, the black key between G and A *is* G♯ — in the octave the
  placement rule gave it. That spelling is fixed: ``KeyboardLayout/piano``
  always spells key 63 as E♭4. Because placement depends on how the spellings
  sound, ``KeyboardToStandardPitchConverter/init(keyboardLayout:tuningSystem:)``
  takes a tuning system even though it produces no frequencies.

A speller wins when one is given. A speller may be used only with a layout of
the shape it assumes — 12 keys per octave — and otherwise the initializer
throws ``KeyboardLayout/Problem/notTwelveKeysPerOctave``; a degree or raw
layout without a speller throws
``KeyboardLayout/Problem/pitchClassLayoutRequired``.

```swift
let speller = KeyboardToStandardPitchConverter()    // Meredith, on a piano

speller.convert([60, 63, 67, 70])       // C4, E♭4, G4, B♭4
```

## Worked examples

### A 12-key subset of 19-EDO

```swift
let layout = try KeyboardLayout(pitchClasses: [.c, .cSharp, .d, .eFlat, .e, .f,
                                               .fSharp, .g, .gSharp, .a, .bFlat, .b])

let converter = try StandardToKeyboardPitchConverter(keyboardLayout: layout,
                                                     tuningSystem: EqualTemperament.edo19)
```

Key 69 sounds A4 at 440 Hz, and its neighbors sound 19-EDO’s G♯4 and B♭4. Each
of the seven spellings the layout leaves out lies exactly one 19-EDO step from
the keys on either side, so a written A♭4 is a tie between the G♯4 and A4 keys.
It goes to the A4 key, the one spelled with its letter, and every other missing
spelling likewise goes to the natural key of its own letter. With
`keyMatching: .within(Ratio(cents: 5))`, a written A♭4 converts to `nil`
instead.

### The Bohlen-Pierce Lambda scale on 12 keys

```swift
//                          C   C♯   D  D♯  E  F   F♯   G  G♯  A   A♯   B
let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])

let converter = try KeyboardToAbsolutePitchConverter(keyboardLayout: lambda,
                                                     tuningSystem: EqualTemperament.bohlenPierce)
```

The period is the tuning system’s interval of equivalence, so the 12-key
pattern spans a tritave: key 72 sounds 3:1 above key 60. The default reference
note, 69, falls on degree 10 and sounds 440 Hz. The unmapped C♯, F♯, and A♯ keys
convert to `nil`.

### 7-TET on the white keys, 5-TET on the black keys

Two tunings interleaved on one keyboard need a raw-ratio layout, since neither
supports standard notation and a degree layout uses a single tuning system:

```swift
let white = (0..<7).map { Ratio(cents: Number($0) * 1200 / 7) }
let black = (0..<5).map { Ratio(cents: Number($0) * 1200 / 5) }

let layout = try KeyboardLayout(ratios: [white[0], black[0], white[1], black[1], white[2],
                                         white[3], black[2], white[4], black[3], white[5],
                                         black[4], white[6]],
                                equivalenceRatio: .octave,
                                referenceFrequency: 440)

let converter = try AbsoluteToKeyboardPitchConverter(keyboardLayout: layout)
```

Both scales start on C, so the C and C♯ keys sound the same pitch, and a
frequency near it always ties and goes to C, the lower key.

## Error handling

Thrown errors conform to `EnhancedError` (from
[XestiTools](https://github.com/eBardX/XestiTools)): each has a `category` of
`"IvorTuning"` and a human-readable `message`.

 Type               | Thrown by
:----               |:---------
 ``TuningError``    | The `KeyboardLayout` initializers and every throwing converter initializer
 ``ParseError``     | The `init(stringValue:)` initializers of the pitch, pitch class, interval, and notation types

``TuningError`` has two cases:
``TuningError/unsupportedStandardConversion``, when the conversion needs
standard notation and the tuning system can’t express it, and
``TuningError/invalidKeyboardLayout(_:)``, whose ``KeyboardLayout/Problem``
gives the reason. ``Interval/init(quality:size:)`` throws its own
`Interval.InvalidCombinationError`, a plain `Error` that names the quality and
size.

The `init?(plain:)` initializers return `nil` rather than throwing, and
`convert(_:)` returns `nil` for a pitch with no counterpart in the target
notation.

## Concurrency

IvorTuning is built for Swift 6 strict concurrency. Every public type is a
`Sendable` value type, so instances can be freely shared across tasks and actor
boundaries.
