# Notation Conversion Design

This document describes how IvorTuning converts between its three `PitchNotation`
systems: how each conversion works, and why it was designed that way. All six
conversions are implemented. The document began as a design brainstorm; the original
proposal, and the public `KeyboardMap` that keyboard layouts replaced, are preserved in
git history.

---

## The Three Systems

Each notation system has a concrete pitch type and a concrete interval type:

| Notation   | Pitch Type   | Interval Type  | What it represents                   |
|------------|--------------|----------------|--------------------------------------|
| `standard` | `Pitch`      | `Interval`     | Letter name + accidental + octave    |
| `absolute` | `Frequency`  | `Ratio`        | Frequency in Hz / frequency ratio    |
| `keyboard` | `NoteNumber` | `NoteDistance` | MIDI note number / semitone distance |

---

## Status at a Glance

**Status:** all six conversions implemented, as of 2026-11-02.

Conversions are exposed through two layers:

- **Building blocks**: the types that hold the musical facts. `TuningSystem` and
  `PitchStandard` tune standard pitches, `KeyboardLayout` describes a keyboard, and
  `PitchSpeller` spells keys. Each keyboard converter also builds an internal
  `KeyboardMap` once, from its layout: the table of key frequencies and the
  nearest-key search. See
  [Keyboards](#keyboards-keyboardlayout-and-the-internal-keyboardmap).
- **Converters**: one `PitchConverter` type per directed edge, each wrapping the
  building blocks that edge needs.

| From       | To         | Converter                                   | Built from                                                                      |
|------------|------------|---------------------------------------------|---------------------------------------------------------------------------------|
| `standard` | `absolute` | `StandardToAbsolutePitchConverter`          | `TuningSystem`, `PitchStandard`                                                 |
| `standard` | `keyboard` | `StandardToKeyboardPitchConverter`          | `TuningSystem`, `PitchStandard`, `KeyboardLayout`, `KeyMatching`                |
| `absolute` | `keyboard` | `AbsoluteToKeyboardPitchConverter`          | `KeyboardLayout`¹, `KeyMatching`                                                |
| `keyboard` | `absolute` | `KeyboardToAbsolutePitchConverter`          | `KeyboardLayout`¹                                                               |
| `keyboard` | `standard` | `KeyboardToStandardPitchConverter<Speller>` | `KeyboardLayout`, plus a `PitchSpeller` or the layout's own spelling²           |
| `absolute` | `standard` | `AbsoluteToStandardPitchConverter<Speller>` | `KeyboardLayout`¹, `KeyMatching`, plus a `PitchSpeller` or the layout's own spelling² |

1. Plus a `TuningSystem` and a `PitchStandard`, unless the layout is raw (raw-ratio
   or frequency). A raw layout tunes its own keys; see [Raw layouts](#keyboardlayout).
2. A pitch-class layout spells each key itself, through `KeyboardLayoutSpeller`. Its
   octaves come from the layout's placement in a `TuningSystem`; see
   [Spelling](#spelling).

Every converter has a non-throwing `init()` for the usual 12-TET piano at
A4 = 440 Hz. The spelling converters' `init()` uses `MeredithPitchSpeller`. The other
initializers are listed under [Converters](#converters).

`PitchNotation.isConversionSupported(to:)` returns `true` for every pair of distinct
notations, and `false` for a notation converted to itself.

The two spelling converters need a whole passage to spell in context, so callers
convert a sequence with the array form of `convert(_:)`; see
[Decision: Sequence-Based Spelling](#decision-sequence-based-spelling).

---

## The `PitchConverter` Protocol

```swift
public protocol PitchConverter: Equatable, Sendable {
    associatedtype FromPitchType: PitchProtocol
    associatedtype ToPitchType: PitchProtocol

    func convert(_ pitch: FromPitchType) -> ToPitchType?

    func convert(_ pitches: [FromPitchType]) -> [ToPitchType?]
}
```

The array form converts a passage in performance order. A default implementation maps
the single-pitch form over the array, and the two spelling converters override it; see
[Decision: Sequence-Based Spelling](#decision-sequence-based-spelling).

`convert(_:)` returns `nil` when the pitch has no counterpart in the target notation.
For example, `Pitch` reaches C𝄫−1 and B𝄪9 but MIDI stops at 0 and 127, a keyboard
layout may leave keys unmapped, and `KeyMatching.within(_:)` rejects a pitch that is
too far from every key. Clamping would silently give a wrong answer, and trapping
would crash on valid input. The optional also matches the library's existing style:
`transposed(by:)` returns an optional too. Converters whose conversion always succeeds, such as
`StandardToAbsolutePitchConverter`, document that they never return `nil`.

Checks that depend only on the configuration belong in the converter's throwing
initializer, not in `convert`. Two errors can come out of a converter initializer:

- `TuningError.unsupportedStandardConversion`: the conversion needs standard
  notation, but the given tuning system cannot express it.
- `TuningError.invalidKeyboardLayout(_:)`: the layout can't be used with this
  initializer, or is invalid in the given tuning system. It carries a
  `KeyboardLayout.Problem`; see [Error reporting](#validation).

`TuningError.unsupportedConversion(from:to:)` remains, but no converter throws it now
that every edge is implemented.

There are no interval converters, and no public interval conversion involving
`keyboard`; see [Future Work](#future-work).

---

## `standard → absolute`: `TuningSystem` + `StandardToAbsolutePitchConverter`

### Protocol hook: `TuningSystem.standardConversion(for:)`

Each supporting tuning system provides its own pitch-class mapping:

```swift
func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]?
```

The default implementation returns `nil`, meaning the tuning system does not support
standard notation. For example, its interval of equivalence may not be 2:1, or it may
have more than 35 distinct pitch classes per octave. Otherwise, it returns exactly 35
entries, one per pitch class (7 letters × 5 accidentals).

**Convention for each entry:** the directed frequency ratio from the reference pitch
to the instance of that pitch class within the **same SPN octave** as the reference.
Direction is `.ascending` if that same-octave instance lies above the reference,
`.descending` if below, and `.same` if it is the reference (or enharmonically
equivalent).

For example, with A4 as the reference, every entry corresponds to a pitch spelled in
octave 4. B maps to the ascending ratio to B4, not to the nearer descending ratio to
B3. The SPN octave follows the letter, not the sound. C♭4 sounds just below C4
(enharmonic to B3), and B♯4 and B𝄪4 sound just above B4 (enharmonic to C5 and C♯5).
Their entries reflect that.

All built-in tuning systems share one implementation (`buildStandardConversion` in
`FifthChain.swift`). It places each pitch class in its letter's octave using the
nominal 12-EDO position of its fifth-chain index, 7p − 12⌊4p/7⌋ semitones above C
(C♭ = −1, B♯ = 12, B𝄪 = 13). It then picks the octave of the tuned ratio nearest that
position. An earlier version reduced every ratio to [C, C′) by sound, which put
C♭, C𝄫, B♯, B𝄪 and D𝄫 an octave off.

### `StandardToAbsolutePitchConverter`

```swift
public struct StandardToAbsolutePitchConverter: PitchConverter {
    public init(tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440) throws(TuningError)

    public func convert(_ pitch: Pitch) -> Frequency?   // never nil
}
```

`init` throws `TuningError.unsupportedStandardConversion` if `standardConversion(for:)`
returns `nil` or does not return exactly 35 entries. It stores the table and the
reference octave. `convert` looks up the pitch class, transposes the reference
frequency by that entry, then shifts by whole octaves for the pitch's SPN octave.

`PitchStandard` anchors the conversion by associating a `Pitch` with a `Frequency`.
Predefined constants: `a415`, `a432`, `a435`, `a440`, `c256`.

### Scope and limitations

The following tuning systems support `standardConversion(for:)`:

- Well temperaments and linear temperaments (meantone, Pythagorean)
- EDOs with at most 35 divisions and a 2:1 period (12-EDO, 19-EDO, 31-EDO)

The following return `nil`:

- Non-octave period systems (e.g., Bohlen-Pierce), because standard notation
  assumes 2:1
- Tuning systems with more than 35 distinct pitch classes (e.g., 53-EDO)
- Extended linear temperaments
- Every just intonation (e.g., `fiveLimitJI`, `sevenLimitJI`, `partch43`): even
  5-limit scales have enharmonic pairs that are distinct in just intonation but
  share one spelling, and higher limits diverge further from Pythagorean or exceed
  the 35-class limit

Some other EDOs that pass these checks may still produce unexpected spellings
(e.g., 17-EDO).

### Proposal: restricted gamut for linear temperaments

**Status:** deferred 2026-10-28; **withdrawn 2026-11-02** in favor of
[Decision: Keyboard Layouts](#decision-keyboard-layouts). A 12-key pitch-class layout
used with a meantone tuning models the instrument directly, and
`standard → keyboard → absolute` gives the restricted-gamut result. The proposal is
kept below for reference only.

#### Problem

A linear temperament gives each of the 35 spellings its own pitch. In quarter-comma
meantone, G♯ lies about 41¢ (a diesis, 128:125) below A♭. That is right for voices,
strings and winds, which tune each spelling as written, and it is what
`LinearTemperament` does today. A historical keyboard instrument tuned in meantone
has only 12 keys per octave, though. It can sound only a 12-note window of the chain
of fifths, usually E♭–G♯. A score that asks for D♯ on that instrument gets the E♭
key, a diesis off. Some instruments add split keys for a few extra spellings
(commonly D♯/E♭ and G♯/A♭). There is currently no way to model these limits.

A plain limit on the number of distinct pitches is not enough. The model needs three
things:

1. **Size.** How many chain positions the instrument has: 12, or 14 with two split
   keys, and so on.
2. **Placement.** Where the window sits on the chain of fifths: E♭–G♯ (positions −3
   to 8, with C = 0), A♭–C♯ (−4 to 7), A♭–D♯ with split keys (−4 to 9), etc.
3. **Folding.** What happens to a spelling outside the window: it takes the pitch of
   its enharmonic inside the window, a multiple of 12 fifths away (D♯ takes E♭'s
   pitch in an E♭–G♯ window).

Limits of 19 or 31 pitches would rarely matter: third-comma meantone is close to
19-EDO and quarter-comma to 31-EDO, and scores seldom use spellings that far out on
the chain. The useful cases are 12 keys, perhaps plus a few split keys. Well
temperaments need nothing: they already fold every spelling onto their 12-note
circle (`circleRatios[idx mod 12]`), so their window is fixed by definition.

#### Sketch

Add an optional gamut to `LinearTemperament`, given as a range of fifth-chain
positions:

```swift
public struct LinearTemperament {
    public init(narrowingRatio: Ratio = .unison,
                gamut: ClosedRange<Int>? = nil)   // nil: every spelling its own pitch

    public let gamut: ClosedRange<Int>?
    public let narrowingRatio: Ratio
}
```

`standardConversion(for:)` would still return 35 entries. The only change is the
`ratioAt` closure it passes to `buildStandardConversion(for:ratioAt:)`: it folds each
position into the gamut by multiples of 12 before looking up the chain ratio, the
same way `WellTemperament` folds onto its circle. `_spnOctaveValue` still places each
spelling by its own letter's octave, so a folded B♯4 sounds as the C5 key, not C4.

Predefined windows could be named for the instruments they model, such as E♭–G♯,
A♭–C♯ and A♭–D♯ with split keys.

#### Questions to settle

- **Minimum size.** A gamut shorter than 12 positions leaves some spellings with no
  enharmonic in the window. Reject it with a precondition, or return `nil` from
  `standardConversion(for:)`?
- **Folding in windows longer than 12.** A spelling may then have two enharmonics
  in the window. In A♭–D♯ (−4 to 9), F𝄫 (−15) could fold to E♭ (−3) or D♯ (9).
  Pick the one with the fewest 12-fifth shifts?
- **Where it belongs.** A property on `LinearTemperament` (as sketched), or a
  wrapper that applies a gamut to any fifth-based tuning system. The wrapper needs
  a way to reach the underlying chain ratios, and today `LinearTemperament` is the
  only such system with an open chain.
- **Equality and coding.** Adding a stored property changes `LinearTemperament`'s
  `Equatable`/`Hashable` behavior and any coded form. The predefined constants
  would keep `gamut: nil`.

#### Motivating caller

The IvorApp Convert sheet converts standard pitch to absolute pitch with any of the
predefined linear temperaments. With a gamut available, it would offer a Gamut
picker (Full, or one of the named windows) shown only for linear temperaments.

---

## `standard → keyboard`: `StandardToKeyboardPitchConverter`

**Status:** implemented 2026-10-28; moved to keyboard layouts 2026-11-02.

### The default: piano key assignments

```swift
public struct StandardToKeyboardPitchConverter: PitchConverter {
    public init()   // KeyboardLayout.piano, EqualTemperament.edo12, PitchStandard.a440

    public init(keyboardLayout: KeyboardLayout,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440,
                keyMatching: KeyMatching = .nearest) throws(TuningError)

    public func convert(_ pitch: Pitch) -> NoteNumber?
}
```

The no-argument initializer gives the usual piano key assignments: 12-tone equal
temperament, A4 = 440 Hz, and `KeyboardLayout.piano`. It cannot fail. For every
pitch whose key is in 0–127, the result matches the notational formula
`12 × (octave + 1) + letter + accidental`. So B♯3 → 60, C4 → 60, D𝄫4 → 60,
C♭4 → 59, A4 → 69, C−1 → 0 and G9 → 127. A test checks all 385 spellings
(35 pitch classes × 11 octaves) against that formula.

### Semantics: acoustic

Conversion goes through frequency: `StandardToAbsolutePitchConverter.convert`, then
the internal map's `nearestKey(to:letter:keyMatching:)`, with the written pitch's
letter for [tie-breaking](#tie-breaking). The result is the mapped key that *sounds*
nearest the pitch. There is no separate code path for the default: the notational
and acoustic answers coincide there, so a second implementation would be redundant.

Acoustic semantics generalizes to keyboards with other than 12 keys per octave
(e.g., a 19-EDO layout where C♯ and D♭ are different keys). It has two consequences
worth documenting:

- **The pitch standard can't transpose.** It tunes both the written pitches and the
  keys, so with `.a415`, written A4 → 69, and key 69 sounds 415 Hz. (Before keyboard
  layouts, pairing a pitch standard with a keyboard map tuned to another one
  transposed silently.)
- **Non-12-TET tunings follow the sound, not the spelling.** In quarter-comma
  meantone, `.piano`'s keys are tuned C C♯ D E♭ … in meantone too. A written D♯4 has
  no key of its own, and lands on the E♭4 key (63), the one it sounds nearest.

### Why the converter isn't generic

The converter only needs the tuning system at init time, to build its internal
`StandardToAbsolutePitchConverter`, so it takes `some TuningSystem` rather than being
generic over `System`. That lets `init()` live on the type itself. A generic type
would need a constrained extension (`where System == EqualTemperament`), and Swift
does not allow static stored properties on generic types.

### Out-of-range pitches

`Pitch` spans MIDI −2 (C𝄫−1) to 133 (B𝄪9). `convert` returns `nil` for pitches that
lie beyond the lowest or highest mapped key by more than half the step to that key's
inner neighbor; see [The nearest-key search](#the-nearest-key-search). With the default, that
means C♭−1, C𝄫−1, and every octave-9 spelling above G9 (G♯9 onward) return `nil`.

---

## Keyboards: `KeyboardLayout` and the internal `KeyboardMap`

**Status:** implemented 2026-11-02, replacing the public `KeyboardMap`.
[Decision: Keyboard Layouts](#decision-keyboard-layouts) records why and gives the full
design. This section summarizes what was built.

### `KeyboardLayout`

Callers describe a keyboard with a public `KeyboardLayout`: which keys are mapped, and
what each mapped key plays. It has four kinds, one per initializer:

| Kind        | Initializer                                                                    | A slot holds              | Keys tuned by                   |
|-------------|--------------------------------------------------------------------------------|---------------------------|---------------------------------|
| Pitch class | `init(pitchClasses:anchorNote:anchorOctave:)`                                  | A spelled pitch class     | Tuning system + pitch standard  |
| Degree      | `init(degrees:anchorNote:referenceNote:)`                                      | A tuning-system degree    | Tuning system + pitch standard  |
| Raw ratio   | `init(ratios:equivalenceRatio:anchorNote:referenceNote:referenceFrequency:)`   | A ratio above the anchor  | The layout itself               |
| Frequency   | `init(frequencies:)`                                                           | One key's frequency       | The layout itself               |

- **Repetition.** A `nil` slot leaves its keys unmapped. The slots repeat every
  `keysPerPeriod` keys, outward from the anchor key. A frequency layout instead has
  128 slots, one per key.
- **Stored form.** A layout stores only its `definition`, an enum with one case per
  initializer. `init(_:)` rebuilds a layout from a definition, and decoding goes
  through it, so a decoded layout is always valid. Equality is structural.
- **Errors.** The checks that need nothing but the layout run in the initializers.
  A failure throws `TuningError.invalidKeyboardLayout(_:)` with a
  `KeyboardLayout.Problem`. The checks that need a tuning system run when a converter
  is built; see [Validation](#validation).
- **Presets.** There are two, `.piano` and `.bohlenPierce`; see
  [Predefined layouts](#predefined-layouts).

### The internal `KeyboardMap`

Each keyboard converter builds a `KeyboardMap` once, at init. It is internal, so
callers never see it. A pitch-class or degree layout needs a tuning system and pitch
standard to build one. A raw layout needs neither.

```swift
internal struct KeyboardMap {
    init(keyboardLayout: KeyboardLayout,
         tuningSystem: some TuningSystem,
         pitchStandard: PitchStandard) throws(TuningError)
    init(rawLayout: KeyboardLayout) throws(TuningError)

    let frequencies: [Frequency?]   // 128 keys; nil = unmapped
    let pitches: [Pitch?]?          // pitch-class layouts only: each key's spelled pitch

    func frequency(of noteNumber: NoteNumber) -> Frequency?
    func nearestKey(to frequency: Frequency,
                    letter: Pitch.Letter? = nil,
                    keyMatching: KeyMatching = .nearest) -> NoteNumber?
}
```

- **Building the map** runs the layout checks that need the tuning system.
  - **Pitch-class layouts:** each mapped slot takes the lowest octave of its pitch
    class that sounds above the previous mapped slot. A key whose spelling lies within
    `Pitch`'s range gets its frequency exactly from `StandardToAbsolutePitchConverter`,
    and its spelled pitch is recorded in `pitches`.
  - **Degree and raw-ratio layouts:** every key is tuned from its position relative to
    the reference key.
- **`frequency(of:)`** is a table lookup. `KeyboardToAbsolutePitchConverter` uses it.
- **`nearestKey(to:letter:keyMatching:)`** is the search that the three converters
  which search for a key all share.
- **Spelling.** `KeyboardLayoutSpeller` spells keys from `pitches`.

The whole table is computed at init, so `convert` doesn't call `exp` or `log` for
every key.

### The nearest-key search

`nearestKey(to:letter:keyMatching:)` returns the mapped key that sounds nearest the
target. Distances are measured as ratios: natural logs of frequency.

- **Ties.** Two keys whose distances differ by less than 0.001¢ are tied. A tie goes
  to the key whose spelling has `letter`, if exactly one of the tied keys does, and
  otherwise to the lower key. `standard → keyboard` passes the written pitch's letter.
  See [Tie-breaking](#tie-breaking).
- **Edges.** Beyond the lowest or highest key, a target matches that key only within
  half the step to the nearest *distinct* inner pitch. In 12-TET that is 50¢ past
  MIDI 0 or 127. A map with only one distinct pitch has no outer limit.
- **Key matching.** With `.within(ratio)`, the search also returns `nil` if the
  nearest key is farther than `ratio` from the target. The stricter of the two limits
  wins. See [Key matching](#key-matching).

The Scala `.kbm` retune range (which MIDI notes the mapping applies to) is
deliberately left out. It is a deployment concern, not a mathematical property of the
mapping, and belongs in a caller-level wrapper if it is ever needed.

---

## Decision: Keyboard Layouts

**Status:** decided 2026-11-02, including all details; implemented 2026-11-02 in
IvorTuning, IvorModel and IvorApp. The text below is the decision as made. Where the
code departs from it, see
[What changed during implementation](#what-changed-during-implementation).

### Problem

A `KeyboardMap` bundles three concerns, and only one of them is specific to keyboards:

| `KeyboardMap` property                          | Concern            | Already modelled by |
|-------------------------------------------------|--------------------|---------------------|
| `ratios`, `equivalenceRatio`                    | The scale          | `TuningSystem`      |
| `referenceNote`, `referenceFrequency`           | The tuning anchor  | `PitchStandard`     |
| `middleNote`, which slots are `nil`             | The layout         | —                   |

The scale and the tuning anchor are copied into the map when it is built, so nothing
keeps them in step with the `TuningSystem` and `PitchStandard` the caller chose.
`Work.ConvertContext` stores all three independently. Three problems follow:

- **Choices that silently disagree.** The predefined maps share their names with the
  `PitchStandard` constants (`a415`, `a432`, `a435`, `a440`, `c256`) and are documented
  as "Pairs with ``PitchStandard/…``". Choosing a mismatched pair isn't an error: it
  silently transposes.
- **The presets aren't layouts.** Every predefined map except `bohlenPierce` has the
  same layout. They differ only in their tuning anchor, which is the pitch standard's
  job.
- **No support for other tunings.** To map a 12-key subset of 19-EDO, a caller has to
  work out the 12 ratios by hand and pass them as `ratios`. The resulting map has no
  connection to `EqualTemperament.edo19`.

### Decision

Callers describe only the **layout**, with a new public `KeyboardLayout`. A layout
holds no frequencies and no ratios, except for two low-level initializers (raw ratios,
and per-key frequencies) kept for `.scl`/`.kbm` import and per-key tuning tables. Each
converter that needs key frequencies works them out from a layout, a tuning system and
a pitch standard. `KeyboardMap` becomes an
**internal** type: the table of key frequencies the converter builds at init, plus the
nearest-key search.

The layout is the one keyboard-specific choice. The scale and the tuning anchor each
come from a single source of truth, so they can't disagree.

### `KeyboardLayout`

```swift
public struct KeyboardLayout {
    /// Keys described by spelled pitch class, for tuning systems that support standard
    /// notation. Key `anchorNote` sounds `pitchClasses[0]` in SPN octave `anchorOctave`.
    ///
    /// `pitchClasses[0]` may be any pitch class, not only C, and the layout need not
    /// contain C at all. For example, `[.a, .bFlat, .b, .c, …]` with `anchorNote: 57`
    /// and `anchorOctave: 3` puts A3 on key 57, and C4 three keys higher.
    public init(pitchClasses: [PitchClass?],     // one per key in a period; nil = unmapped
                anchorNote: NoteNumber = 60,
                anchorOctave: Pitch.Octave = 4) throws(TuningError)

    /// Keys described by degree, for tuning systems without standard notation. Each
    /// element is the degree of the tuning system each key plays, counted from 0 (the
    /// unison) within one period. Key `anchorNote` sounds `degrees[0]`; key
    /// `referenceNote` sounds the pitch standard's frequency.
    ///
    /// `degrees[0]` may be any degree, not only 0, and the layout need not contain
    /// degree 0 at all. For example, `[5, 7, 9, 0, 2]` puts degree 5 on `anchorNote`,
    /// and degree 0 three keys higher, in the next period.
    public init(degrees: [Int?],                 // one per key in a period; nil = unmapped
                anchorNote: NoteNumber = 60,
                referenceNote: NoteNumber = 69) throws(TuningError)

    /// Low level: keys described by explicit ratios, tuned independently of any tuning
    /// system or pitch standard. Intended for `.kbm`/`.scl` import. Each element is
    /// the position of its key within one period, in [1, `equivalenceRatio`). Key
    /// `anchorNote` sounds `ratios[0]`; key `referenceNote` sounds
    /// `referenceFrequency`.
    ///
    /// `ratios[0]` may be any ratio in that range, not only the unison, and the layout
    /// need not contain the unison at all. Only the ratios' relative values matter:
    /// the absolute tuning comes from `referenceNote` and `referenceFrequency`.
    public init(ratios: [Ratio?],                // one per key in a period; nil = unmapped
                equivalenceRatio: Ratio,
                anchorNote: NoteNumber = 60,
                referenceNote: NoteNumber = 69,
                referenceFrequency: Frequency) throws(TuningError)

    /// Low level: an explicit frequency for every MIDI note number, with no repeating
    /// pattern. Element `n` is the frequency of MIDI note number `n`; `nil` means the
    /// key is unmapped. Intended for per-key tuning tables, such as a MIDI Tuning
    /// Standard bulk dump.
    public init(frequencies: [Frequency?]) throws(TuningError)   // exactly 128 elements
}
```

The first two kinds of layout work the same way. A layout says which elements of the
tuning system each key plays: spelled pitch classes in one case, degrees of the
tuning system in the other. The frequencies come only from the tuning system and the
pitch standard.

The label is `degrees:`, not `scaleDegrees:`. The values are degrees of the tuning
system, not of the scale being laid out: the Lambda layout holds Bohlen-Pierce
degrees 0, 2, 3, …, not Lambda's own 0–8. Music theory also counts scale degrees
from 1. The name matches `TuningSystem.ratio(forDegree:)`. The 19-EDO
example below picks 12 of 19-EDO's pitch classes. A degree layout could pick, say,
12 of 22-EDO's degrees in the same way.

The period is one equivalence interval of the tuning system, spread over
`pitchClasses.count` (or `degrees.count`) keys, and the pattern repeats outward from
`anchorNote`. A raw-ratio layout gives its period explicitly, as `equivalenceRatio`.
A frequency layout has no period.

**Slot order.** Slot `i` is key `anchorNote + i` in every period, so the list order is
the keyboard's physical left-to-right order. In pitch-class and degree layouts, slots
must therefore be listed in ascending order of sound within one period, starting
with slot 0. Raw-ratio and frequency layouts are exempt; see
[Raw-ratio layouts](#keyboardlayout) below. Slot 0 need not be C:
`[.a, .bFlat, .b, .c, …]` with `anchorNote: 57, anchorOctave: 3` is a valid A-to-A
layout. A `nil` slot is an unmapped key. It has no pitch, so placement skips
it: the next mapped slot is placed above the last *mapped* slot. Slot 0 must be
mapped, because it defines the anchor. See [Validation](#validation) for what
happens when the order is wrong.

**Resolving a pitch-class key.** Within one period, slot 0 is the anchor's pitch class
in `anchorOctave`. Each later mapped slot takes the lowest octave of its pitch class
that sounds above the previous mapped slot, in the given tuning system. This rule
keeps spellings that cross the octave boundary in their real place. In a C-to-C
layout, a final C♭ slot becomes C♭5, not C♭4. In 19-EDO it also places a B♯ slot
correctly, after B and below the next C. Each period after that adds 1 to every
slot's octave.

The key's spelled `Pitch` then goes through `StandardToAbsolutePitchConverter`, so its
frequency comes from the same tuning system and pitch standard used everywhere else.

**Resolving a degree key.** The rule is the same, with equivalence intervals in place
of octaves. Slot 0 is `degrees[0]` in period 0. Each later mapped slot takes the
lowest period of its degree that sounds above the previous mapped slot. The tuning
system supplies each degree's ratio through a new requirement:

```swift
// TuningSystem
func ratio(forDegree degree: Int) -> Ratio?   // default: nil (no degrees)
```

Its documented contract: degrees are numbered `0..<n`, where `n` is the number of
degrees in one period, and `ratio(forDegree:)` returns `nil` for any degree outside
that range. There is no folding by periods. Layouts only need one period, because the
placement rule handles the wrap, and a single valid number per degree means a layout
can't name the same key twice in different ways. Degree 0 is the unison, and degrees
ascend in sound, so `ratio(forDegree: d + 1)` > `ratio(forDegree: d)` for every `d`
in `0..<n − 1`. That contract lets a degree layout's order be checked without a tuning
system; see [Validation](#validation).

It is implemented by `EqualTemperament` (`divisions` steps per period), by
`JustIntonation` (its `ratios`), and by `WellTemperament` (its 12 circle positions).
`LinearTemperament` has an open chain, not a finite set of degrees, so it keeps the
default and supports pitch-class layouts only. A degree layout used with a tuning
system whose `ratio(forDegree:)` returns `nil` for a listed degree throws.

**Tuning a degree layout.** A degree layout has no spellings, so the pitch standard's
spelled pitch can't locate a key. Instead, the layout names one: key `referenceNote`
sounds `pitchStandard.frequency`, and the pitch standard's pitch is ignored. Every
other key is tuned from that key's ratio to it. `referenceNote` must fall on a mapped
key. A pitch-class layout has no `referenceNote`: the key sounding the pitch
standard's pitch follows from the spellings.

**Raw-ratio layouts.** The third initializer is the escape hatch for tunings the
library can't express: a Scala `.scl`/`.kbm` pair, for example. It carries the same
information as today's public `KeyboardMap` initializer. Each `ratios[i]` is the
position of slot `i` within its period, like a degree, and key `referenceNote` sounds
`referenceFrequency`.

Placement does **not** follow the ascending rule. Every ratio lies in
[1, `equivalenceRatio`), so each key's period is already unambiguous: slot `i` in
period `p` sounds `ratios[i] × equivalenceRatio^p`, relative to a base pitch shared
by all periods. The base pitch is fixed by the reference key:

```
f(key) = referenceFrequency × ratios[slot(key)] / ratios[slot(ref)]
                            × equivalenceRatio^(period(key) − period(ref))
```

Scaling every ratio by the same factor cancels out, so `ratios[0]` need not be the
unison. It works like the first element of a degree layout. This is how a `.kbm`
mapping behaves too: its middle note plays whatever degree the mapping's first entry
names, so an importer copies ratios across without rescaling. It is otherwise exactly
today's `KeyboardMap` behavior. Raw-ratio layouts may therefore be:

- **Non-monotonic.** Going up a key need not go up in pitch: for example, two
  interleaved scales on the white and black keys.
- **Duplicated.** Two keys may sound the same pitch.

Both are needed for `.kbm` import. A Scala keyboard mapping may list scale degrees in
any order and may map several keys to the same degree. Pitch-class and degree layouts
keep the ascending rule, because they need it: it places spellings such as C♭ and B♯
in the right octave, and it resolves a degree list that wraps.

**Frequency layouts.** The fourth initializer goes one step further: it drops the
repeating pattern altogether. It takes one frequency per MIDI note number, so it has
no `anchorNote`, `referenceNote`, `referenceFrequency` or `equivalenceRatio`. A
raw-ratio layout can express the same keyboard, using 128 ratios, `anchorNote: 0` and
an `equivalenceRatio` above the largest ratio, but then `equivalenceRatio` is a
meaningless upper bound. The frequency initializer states the intent directly. Like
raw-ratio layouts, frequency layouts may be non-monotonic and may repeat pitches. The
only checks are that there are exactly 128 elements and that at least one is mapped.
These are the only layouts that can be empty, since they have no anchor slot that
must be mapped.

**Raw layouts.** Raw-ratio and frequency layouts together are the *raw* layouts. They
are the ones that hold frequencies themselves, so they give up the guarantee the
other two provide. The converters take them as follows:

- **`absolute ↔ keyboard` and `absolute → standard`.** Nothing has to be realized, so a
  tuning system and pitch standard would go unused. These converters take a raw
  layout only through a separate initializer that has no such parameters:
  `init(keyboardLayout:)`, or `init(keyboardLayout:pitchSpeller:)` for
  `AbsoluteToStandardPitchConverter`. Each initializer accepts only its own kind of
  layout. The short form throws for a pitch-class or degree layout, which has no
  frequencies without a tuning system. The full form throws for a raw layout, where
  its tuning system and pitch standard would be silently ignored. So no argument is
  ever silently ignored.
- **`standard → keyboard`.** The tuning system and pitch standard still realize the
  written pitch, so `StandardToKeyboardPitchConverter` accepts a raw layout through
  its full initializer. If they disagree with the layout's own tuning, the
  result transposes, as it does today. Its documentation should say so, and should
  point callers to the pitch-class and degree initializers when the tuning is one the
  library knows.

### Validation

Every check that can run without a tuning system runs in the `KeyboardLayout`
initializer. The rest run in the converter initializer, once the tuning system is
known. Both throw rather than trap. Layouts will come from `.kbm` imports, saved
settings, and perhaps a layout editor in IvorApp, so invalid input is expected and
must not crash. (`EqualTemperament` uses preconditions because its inputs are always
written in code.) Predefined layouts unwrap with `.require()`, as
`StandardToKeyboardPitchConverter.init()` already does.

#### In `KeyboardLayout.init`

| Check                                                                         | Pitch-class          | Degree            | Raw-ratio        | Frequency        |
|-------------------------------------------------------------------------------|----------------------|-------------------|------------------|------------------|
| Slot 0 is mapped                                                              | ✓                    | ✓                 | ✓                | — (no slot 0)    |
| At least one key is mapped                                                    | (implied)            | (implied)         | (implied)        | ✓                |
| No value appears twice                                                        | same spelling twice  | same degree twice | — (allowed)      | — (allowed)      |
| `referenceNote` is on a mapped slot: `(referenceNote − anchorNote) mod count` | n/a                  | ✓                 | ✓                | n/a              |
| Mapped values ascend, wrapping at most once                                   | ✗ (tuning-dependent) | ✓                 | — (not required) | — (not required) |
| `equivalenceRatio` > 1, every ratio in [1, `equivalenceRatio`)                | —                    | —                 | ✓                | —                |
| Degrees are non-negative                                                      | —                    | ✓                 | —                | —                |
| Exactly 128 elements                                                          | —                    | —                 | —                | ✓                |

- **Degree order is checked early.** Because `ratio(forDegree:)` promises ascending
  degrees, a degree layout is in valid order exactly when its mapped degrees ascend
  with at most one wrap. `[5, 7, 9, 0, 2]` passes; `[0, 5, 2]` fails.
- **Raw-ratio order isn't checked at all.** Each ratio fixes its key's pitch within
  its period, so order and duplicates don't affect placement. Only the range of each
  ratio is checked.
- **Pitch-class order can't be checked early, even by letter.** Enharmonic pairs swap
  order between tunings: G♯ lies below A♭ in quarter-comma meantone and 19-EDO, and
  about 23.5¢ above it in Pythagorean. E♯ and F♭ do the same, so a valid layout can
  even step backwards in letter name. Order is checked by the converter.
- **Empty layouts are impossible.** In the three patterned kinds, slot 0 must be
  mapped, and it sits on `anchorNote`, which is a valid MIDI note by type. A frequency
  layout has no anchor, so its initializer checks directly that at least one key is
  mapped (`noMappedKeys`). Every layout therefore has at least one key in 0–127, and
  `TuningError.emptyKeyboardMap` is retired.
- **Frequency layouts** are checked only for having exactly 128 elements
  (`invalidFrequencyCount`) and at least one mapped key. Order and duplicates are not
  checked, as for raw-ratio layouts.

#### In the converter initializer

- **Pitch-class layouts.** The tuning system supports standard notation (otherwise
  `unsupportedStandardConversion`). Placed in that tuning, the mapped slots ascend in
  sound and fit within one period: no slot reaches or passes the anchor's pitch an
  octave up, and no two slots sound the same pitch (G♯ and A♭ in 12-TET, for example).
  A misordered list shows up the same way: in 12-TET, C, D, C♯ pushes C♯ into the next
  octave, past the anchor. Validity therefore depends on the pairing. A split-key
  meantone layout listing G♯ before A♭ is valid with meantone and 19-EDO but throws
  with Pythagorean. This is intended: the keys are physically fixed, and sorting the
  slots by sound would move keys depending on the tuning. Layouts without enharmonic
  pairs, such as `.piano`, are valid with every tuning system that supports standard
  notation.
- **Degree layouts.** `ratio(forDegree:)` returns a ratio for every mapped degree. This
  checks the upper bound: a degree ≥ `n` for that tuning system throws
  `unsupportedDegree`. The lower bound is already checked by `KeyboardLayout.init`.
- **Raw layouts.** No further checks. The layout is complete when it is created; the
  converter only checks that it is the right kind for that initializer.
- **Wrong kind for the initializer.** The short `absolute` initializers reject
  pitch-class and degree layouts, and the full ones reject raw layouts.

#### Error reporting

A single new case carries the reason, rather than one `TuningError` case per check:

```swift
public enum TuningError {
    case invalidKeyboardLayout(KeyboardLayout.Problem)
    case invalidKeyMatching                       // see "Key matching"
    case unsupportedConversion(from: PitchNotation, to: PitchNotation)
    case unsupportedStandardConversion
}

extension KeyboardLayout {
    public enum Problem {
        // KeyboardLayout.init
        case unmappedAnchor                       // slot 0 is nil
        case duplicateSlot(index: Int)            // pitch-class/degree: same value as an earlier slot
        case unmappedReference                    // referenceNote's slot is nil
        case slotOutOfOrder(index: Int)           // degrees don't ascend
        case invalidEquivalenceRatio              // raw-ratio: ≤ 1
        case invalidRatio(index: Int)             // raw-ratio: outside [1, period)
        case invalidFrequencyCount                // frequency: not exactly 128 elements
        case noMappedKeys                         // frequency: every element is nil

        // Converter initializer
        case slotOutsidePeriod(index: Int)        // reaches or passes the anchor a period up
        case coincidentSlots(index: Int)          // sounds the same as an earlier slot
        case unsupportedDegree(index: Int)        // ratio(forDegree:) returned nil
        case rawLayoutRequired                    // short absolute initializer (raw-ratio or frequency)
        case rawLayoutNotAllowed                  // full absolute initializer
        case pitchClassLayoutRequired             // spelling initializer without a speller
        case notTwelveKeysPerOctave               // speller used with another layout shape
    }
}
```

A nested `Problem`, rather than fifteen flat `TuningError` cases, is chosen mainly for
IvorModel: `Work.Error` maps one case and carries the `Problem` along, instead of
mirroring every check. It also lets callers tell "the layout is invalid" from "the
conversion isn't possible" with a single pattern, and gives a layout editor its own
type to switch over. The cost: `TuningError` and `ParseError` are otherwise flat, and
matching one specific problem takes two levels of pattern.

Slot indexes let a layout editor point at the offending key.

`KeyboardLayout`'s initializers throw `TuningError`, like the converters, even though
they can fail only with `invalidKeyboardLayout`. `Problem` is not an `Error` itself, so
the public API has one error type. `emptyKeyboardMap` is removed, as above. A
pitch-class layout used with a tuning system that has no
`standardConversion` still throws `unsupportedStandardConversion`, because the
problem there is the tuning system, not the layout.

### Reading a layout

**Status:** decided 2026-11-02.

A `.kbm` exporter, a layout editor, and IvorApp showing the current layout all need
to read a layout back. A layout exposes the arguments it was built from as a single
enum, with one case per initializer:

```swift
extension KeyboardLayout {
    /// What the layout was built from: exactly the arguments of one of its initializers.
    public enum Definition {
        case pitchClasses([PitchClass?],
                          anchorNote: NoteNumber,
                          anchorOctave: Pitch.Octave)

        case degrees([Int?],
                     anchorNote: NoteNumber,
                     referenceNote: NoteNumber)

        case ratios([Ratio?],
                    equivalenceRatio: Ratio,
                    anchorNote: NoteNumber,
                    referenceNote: NoteNumber,
                    referenceFrequency: Frequency)

        case frequencies([Frequency?])
    }

    /// The definition this layout was created from.
    public var definition: Definition { get }

    /// The number of keys in one period: the definition's array count, or 128 for a
    /// frequency layout.
    public var keysPerPeriod: Int { get }

    /// Creates a layout from a definition, with the same validation as the other
    /// initializers.
    public init(_ definition: Definition) throws(TuningError)
}
```

```swift
switch layout.definition {
case let .degrees(degrees, anchorNote, referenceNote):
    …   // write a .kbm mapping
case let .frequencies(frequencies):
    …   // write an MTS bulk dump
default:
    …
}
```

- **Everything lives inside the enum.** The alternative was an enum for the slot data
  plus top-level `anchorNote`, `referenceNote` and so on. Those properties would have
  to be optional, and each one applies to only some kinds: `anchorOctave` only to
  pitch-class layouts, `referenceFrequency` only to raw-ratio ones. That is the "which
  one pairs with which" problem this decision removes. With associated values, each
  case carries exactly what it needs.
- **It converts both ways.** `init(_:)` turns a definition back into a layout, so an
  importer or editor can build a `Definition` and create the layout in one call. A
  hand-built `Definition` is unchecked, but it becomes a `KeyboardLayout` only through
  the throwing initializer. Every layout a caller holds is therefore valid, and
  `Problem`'s slot indexes refer directly to the definition's array. The four labeled
  initializers remain as the readable way to write a layout in code.
- **The name.** `Definition` says it is the layout as written, not as it sounds.
  `Content` and `Kind` are vaguer.
- **Resolved keys are not exposed.** A key's pitch, octave or frequency depends on the
  tuning system and pitch standard. Answering that is the job of `KeyboardToStandard`
  and `KeyboardToAbsolute`. Putting it on the layout would give the layout a second,
  tuning-dependent API and bring back the coupling this decision removes.

### Conformances

**Status:** decided 2026-11-02.

| Type                         | Conformances                                   |
|------------------------------|------------------------------------------------|
| `KeyboardLayout`             | `Codable`, `Equatable`, `Hashable`, `Sendable` |
| `KeyboardLayout.Definition`  | `Codable`, `Equatable`, `Hashable`, `Sendable` |
| `KeyboardLayout.Problem`     | `Equatable`, `Hashable`, `Sendable`            |
| `KeyMatching`                | `Codable`, `Equatable`, `Hashable`, `Sendable` |
| `KeyboardLayoutSpeller`      | `Equatable`, `Sendable` (as `PitchSpeller` requires) |

- **Everything a definition holds already conforms.** `PitchClass`, `Ratio`,
  `Frequency`, `NoteNumber` and `Pitch.Octave` are all `Codable` and `Hashable`. The
  last four inherit this from `NumberRepresentable`, `UIntRepresentable` and
  `IntRepresentable`. `Definition` and `KeyMatching` can therefore use synthesized
  conformances.
- **`KeyboardLayout` encodes its definition.** It encodes as its `definition`, and
  decodes by decoding a `Definition` and passing it to `init(_:)`. A decoded layout is
  therefore validated exactly like a constructed one. A failure is reported as
  `DecodingError.dataCorrupted`, with the `TuningError` in its debug description. This
  follows the pattern `PitchNotation` uses for invalid values.
- **Equality is structural.** Two layouts are equal when their definitions are equal.
  A frequency layout and a raw-ratio layout that sound identical are therefore
  unequal, because they were defined differently. The documentation for `==` says so.
- **`Problem` is not `Codable`.** It is a diagnostic, like `TuningError`, which isn't
  `Codable` either.

### Converters

| Converter                          | Initializers                                                                      |
|------------------------------------|-----------------------------------------------------------------------------------|
| `StandardToKeyboardPitchConverter` | `init()`; `init(keyboardLayout:tuningSystem:pitchStandard:)`                       |
| `AbsoluteToKeyboardPitchConverter` | `init()`; `init(keyboardLayout:tuningSystem:pitchStandard:)`; `init(keyboardLayout:)` |
| `KeyboardToAbsolutePitchConverter` | `init()`; `init(keyboardLayout:tuningSystem:pitchStandard:)`; `init(keyboardLayout:)` |
| `AbsoluteToStandardPitchConverter` | `init()`; `init(keyboardLayout:tuningSystem:pitchStandard:pitchSpeller:)`; `init(keyboardLayout:pitchSpeller:)`; `init(keyboardLayout:tuningSystem:pitchStandard:)` (pitch-class layouts) |
| `KeyboardToStandardPitchConverter` | `init()`; `init(pitchSpeller:)` unchanged; `init(keyboardLayout:pitchSpeller:)`; `init(keyboardLayout:tuningSystem:)` (pitch-class layouts). It produces no frequencies, so it takes no pitch standard. |

The spelling converters' initializers without a speller accept only pitch-class
layouts, which spell themselves; see [Spelling](#spelling).

The shorter initializers on the three `absolute` converters accept only raw layouts
(raw-ratio or frequency), and the full initializers reject them; see
[Raw layouts](#keyboardlayout).

Every initializer of the three converters that search for a key
(`StandardToKeyboard`, `AbsoluteToKeyboard`, `AbsoluteToStandard`) also takes
`keyMatching: KeyMatching = .nearest`; see [Key matching](#key-matching).
`KeyboardToAbsolutePitchConverter` never searches, so it doesn't take it.

Each of these initializers validates the layout against the tuning system (see
[Validation](#validation)) and builds the internal `KeyboardMap` once. For a
pitch-class layout, the internal map also records each key's pitch class, for
[tie-breaking](#tie-breaking).

**Default initializers** (decided 2026-11-02). Every keyboard converter has a
non-throwing `init()` for the usual 12-TET piano at A4 = 440 Hz. Each unwraps its full
initializer with `.require()`, as `StandardToKeyboardPitchConverter.init()` does
today:

| Converter                                                | `init()` is                                                                    |
|----------------------------------------------------------|--------------------------------------------------------------------------------|
| `StandardToKeyboardPitchConverter`                       | `.piano` + `EqualTemperament.edo12` + `.a440`. Same results as today.          |
| `AbsoluteToKeyboardPitchConverter`                       | `.piano` + `EqualTemperament.edo12` + `.a440`                                  |
| `KeyboardToAbsolutePitchConverter`                       | `.piano` + `EqualTemperament.edo12` + `.a440`                                  |
| `AbsoluteToStandardPitchConverter<MeredithPitchSpeller>` | `.piano` + `EqualTemperament.edo12` + `.a440` + `MeredithPitchSpeller()`       |
| `KeyboardToStandardPitchConverter<MeredithPitchSpeller>` | `init(pitchSpeller: MeredithPitchSpeller())`                                   |

The two spelling defaults use `MeredithPitchSpeller`, for context-aware spelling, and
are declared in extensions `where Speller == MeredithPitchSpeller`. With a speller,
the speller spells, even though `.piano` carries spellings of its own (see
[Spelling](#spelling)).

### Tie-breaking

The nearest-key search can find two keys equally near the target. Today it silently
keeps the first, which is the lower key. Ties are rare in 12-TET but systematic in
subset layouts: in the 12-key 19-EDO example, every spelling the layout leaves out
lies exactly halfway between two keys.

**Rule.** In `standard → keyboard` with a pitch-class layout, a tie goes to the key
whose spelling shares the written pitch's letter. A written A♭4 between the G♯4 and A4
keys goes to the A4 key. This keeps the result close to what the score shows, and in
the 19-EDO example it sends every missing spelling to the natural key of its own
letter.

**Fallback: the lower key.** It applies when the letter rule can't decide:

- Neither tied key shares the written letter, or both do.
- The layout has no spellings: a degree, raw-ratio or frequency layout.
- The source is a frequency, not a spelled pitch: `absolute → keyboard` and
  `absolute → standard`.

The fallback is documented behavior, not an accident of iteration order.

**Detecting a tie.** Realized frequencies come from `exp`/`log` arithmetic, so two
keys a mathematically equal distance away rarely compare exactly equal. A tie is
therefore two candidates whose distances to the target, measured as ratios, agree
within a small tolerance. The tolerance, for example 0.001 cent, must be far smaller
than any step a real keyboard has, and far larger than floating-point error. Without
it, the rule would almost never fire, and the result would depend on rounding.

**Where it lives.** The internal `KeyboardMap` stores the pitch class of each key of
a pitch-class layout. Its nearest-key search takes an optional written letter, which
`StandardToKeyboardPitchConverter` supplies and the `absolute` converters don't. The
public result is still a single `NoteNumber?`.

**Duplicate pitches.** In a raw layout where two keys sound the same pitch,
every target near that pitch is a tie between them. The fallback then always picks
the lower key. This is ordinary behavior for such layouts, not an edge case.

**Edge of range.** A target beyond the lowest or highest key still matches it within
half the step to its inner neighbor (see [The nearest-key search](#the-nearest-key-search)).
Today the inner neighbor is simply the next value in sorted order. With duplicates,
that value can equal the outermost one, so the catchment collapses to nothing.
The internal map must instead measure the step to the nearest *distinct* pitch, and
must treat a layout with only one distinct pitch as having no outer limit, as it
does today for a single mapped key.

### Key matching

By default, a pitch converts to the nearest key, however far away that key is (within
the edge-of-range catchment). A caller converting a work that should lie entirely on
the layout's pitches may want an off-layout pitch to fail instead. For example, a
work in Bohlen-Pierce may contain degrees outside the
[Lambda layout](#worked-example-the-bohlen-pierce-lambda-scale-on-12-keys).

```swift
public enum KeyMatching {
    /// The nearest key, within the edge-of-range catchment. Today's behavior.
    case nearest

    /// The nearest key, but only if it lies within the given tolerance of the target;
    /// otherwise no key.
    case within(Ratio)
}
```

With `.within`, `convert` returns `nil` for a pitch farther than the tolerance from
every key. That uses the existing optional-return contract, with `nil` meaning "no
counterpart in the target notation", so failure reaches the caller with no new
mechanism. `Work.convert` already turns `nil` into `Work.Error.pitchOutOfRange`, or
drops the note when `dropsOutOfRangeNotes` is `true`. These are renamed
`unconvertiblePitch` and `dropsUnconvertibleNotes`; see
[Ripple outside IvorTuning](#ripple-outside-ivortuning).

```swift
let converter = try AbsoluteToKeyboardPitchConverter(keyboardLayout: lambda,
                                                     tuningSystem: EqualTemperament.bohlenPierce,
                                                     pitchStandard: .a440,
                                                     keyMatching: .within(Ratio(cents: 5)))
```

Here a Bohlen-Pierce degree outside the Lambda scale, such as degree 1 (about 146¢
from its neighbors), converts to `nil`.

- **A property of the conversion, not the layout.** The same layout may be used
  strictly, when importing a work that should already be on it, or loosely, when
  snapping a performance to the nearest key.
- **A tolerance, not exact equality.** Frequencies pass through `exp`/`log`
  arithmetic, sometimes through an earlier conversion, and sometimes come from a real
  performance. Exact equality would reject pitches that are really on the layout. The
  tolerance is a `Ratio`, in keeping with the library's units; `Ratio(cents:)` keeps it
  readable.
- **Acoustic, like the rest of the conversion.** In `standard → keyboard`, a written
  pitch matches a key if it *sounds* within the tolerance, regardless of spelling. In
  the 12-key 19-EDO layout, `.within(Ratio(cents: 5))` rejects a written A♭4, a full
  19-EDO step from both neighboring keys, instead of tie-breaking it onto the A key.
  On a 12-TET piano, B♯3 still matches the C4 key, because it sounds the same. Strict
  matching is a poor fit for a tuning that differs from the keyboard's own. In
  quarter-comma meantone on a 12-TET piano layout, written pitches can lie tens of
  cents from every key.
- **Interaction with the other rules.** The edge-of-range catchment still applies, and
  the stricter of the two limits wins. A tie can arise only if the tolerance is at
  least half the step between the tied keys. With any sensible strict tolerance,
  [Tie-breaking](#tie-breaking) never comes into play.
- **Validation.** `.within` with a ratio below 1 (a negative tolerance) is invalid. It
  is checked in the converter initializer and reported as a new
  `TuningError.invalidKeyMatching` case, because it is not a layout problem.
  (Not built: `Ratio` is never below 1, so the check could never fail; see
  [What changed during implementation](#what-changed-during-implementation).)

### Spelling

**Status:** decided 2026-11-02.

`MeredithPitchSpeller` assumes MIDI note numbers are 12-TET semitones: note `n` has
chroma `n mod 12`, with C at 0. Given note numbers from a 19-key layout or the Lambda
layout, it would silently produce meaningless spellings. The two spelling converters
therefore spell with **a `PitchSpeller` only on a 12-key octave, and otherwise with
the layout's own spelling where it has one**:

| Layout kind  | With a `PitchSpeller`                          | Without one                       |
|--------------|------------------------------------------------|-----------------------------------|
| Pitch-class  | The speller, if 12 slots (the period is 2:1)   | The layout's spelling of each key |
| Degree       | The speller, if 12 slots and the period is 2:1 | Not supported                     |
| Raw-ratio    | The speller, if 12 slots and `equivalenceRatio` is 2:1 | Not supported             |
| Frequency    | Not supported: no period to check              | Not supported                     |

A speller always wins when one is given. A pitch-class layout can therefore be
spelled two ways, and the caller chooses by passing a speller or not. Passing one
asks for context-aware spelling instead of the layout's fixed names. Nothing is
silently ignored: the layout still decides which keys exist and how they sound, and
only its spellings go unused. This is why `.piano` serves both purposes, and why
there is no separate unspelled 12-key preset. Such a preset would have to be a
degree layout, and degree layouts don't work with `LinearTemperament`, which has no
`ratio(forDegree:)`.

**Spelling from the layout.** A pitch-class layout already names every key it maps,
and those names are what the instrument actually plays: on the 12-key meantone
keyboard, the black key between G and A *is* G♯, not A♭. The spelling is fixed and
context-free. Each key gets its layout spelling, in the octave that the placement
rule gave it. The sequence form of `convert` simply maps over the notes, as for any
context-free converter. This applies at any size, including 12-TET: `.piano` used
through the layout always spells E♭, never D♯. Callers who want contextual spelling
pass a speller.

**Why `keyboard → standard` takes a tuning system** (decided 2026-11-02). Spelling from
the layout produces no frequencies, but each key's octave comes from the placement
rule, and that rule depends on how the spellings sound. No tuning-free rule can always
match it: the two-key layout `[C, B♯]` is valid in both quarter-comma meantone and
Pythagorean, yet its B♯ key is B♯4 in meantone (just below C5) and B♯3 in Pythagorean
(just above C4). `init(keyboardLayout:tuningSystem:)` therefore requires the tuning
system. It builds the same internal map as the `absolute` converters, with any pitch
standard, because placement doesn't depend on it. This has three benefits:

- Every key spells exactly as `AbsoluteToStandardPitchConverter` spells it with the
  same layout and tuning system.
- The layout is validated like everywhere else: `[C, D, C♯]` throws
  `slotOutsidePeriod` instead of being spelled.
- The pitch-class layout must be used with a tuning system that supports standard
  notation, as in the other converters.

The parameter is required rather than optional, so there is only one placement rule. A
default of `EqualTemperament.edo12` was also rejected: 12-TET makes G♯ and A♭ coincide,
so every split-key layout would throw `coincidentSlots`. An earlier tuning-free rule
(nominal 12-tone positions, an enharmonic of the previous slot counting as above it)
was implemented and withdrawn: it put the key an octave off for layouts whose
spellings step down nominally, which are valid only in tunings flatter than 19-EDO.
`init(keyboardLayout:pitchSpeller:)` still takes no tuning system, because the speller
chooses the octaves. As a result, it can't check that a degree layout's period is an
octave.

**The 12-key requirement.** A frequency layout passed with a speller always throws
`notTwelveKeysPerOctave`, even one that happens to hold a retuned 12-key piano: with
no period, nothing says its keys repeat by octave. Such a table can be re-expressed
as a 12-slot raw-ratio layout if it does repeat.

For pitch-class, degree and raw-ratio layouts, a speller is allowed only when the
layout has the shape a speller assumes: 12 slots per period, with an octave period. Otherwise the
initializer throws `notTwelveKeysPerOctave`. Lambda (12
slots per tritave) and the 19-key layouts are rejected. The check is structural: it
can't tell whether the keys sound anything like piano keys. The 7-TET/5-TET split
layout passes, and spelling it is the caller's responsibility.

**Initializers.**

- `AbsoluteToStandardPitchConverter`
  - `init(keyboardLayout:tuningSystem:pitchStandard:keyMatching:)`: pitch-class layouts
    only; spells from the layout.
  - `init(keyboardLayout:tuningSystem:pitchStandard:pitchSpeller:keyMatching:)`:
    pitch-class or degree layouts with 12 keys per octave; spells with the speller.
  - `init(keyboardLayout:pitchSpeller:keyMatching:)`: raw-ratio layouts with 12 keys
    per octave.
- `KeyboardToStandardPitchConverter`
  - `init(keyboardLayout:tuningSystem:)`: pitch-class layouts only. An unmapped key
    converts to `nil`. The tuning system is required because the placement rule, and so
    each key's octave, depends on it (decided 2026-11-02; see below).
  - `init(keyboardLayout:pitchSpeller:)`: any layout except a frequency layout, with 12
    keys per octave. The layout supplies which keys are mapped (an unmapped key
    converts to `nil`), and the speller spells.
  - `init(pitchSpeller:)`: unchanged. It takes no layout, so nothing can be checked. Its
    documentation states that it assumes 12-TET piano numbering. It behaves like
    `init(keyboardLayout: .piano, pitchSpeller:)`.

A degree or raw layout passed without a speller throws `pitchClassLayoutRequired`.
A layout of the wrong shape passed with one throws `notTwelveKeysPerOctave`.

**The generic parameter.** Both converters are generic over `Speller`, which the
initializers without a speller don't use. They are declared in an extension
`where Speller == KeyboardLayoutSpeller`. `KeyboardLayoutSpeller` is a public
`PitchSpeller` with no public initializer; only those converters create it, and it
reads spellings from the layout. Callers see it only in a type annotation such as
`AbsoluteToStandardPitchConverter<KeyboardLayoutSpeller>`. Its `spell(_:)` is called
only on mapped keys, because the converters return `nil` for an unmapped key before
spelling. This is the chosen shape. An equivalent one is acceptable if implementation
turns up a problem, as long as the initializers without a speller stay free of an
unused speller argument.

### Predefined layouts

The `KeyboardMap` constants `a415`, `a432`, `a435`, `a440`, `c256` and `bohlenPierce`
are removed. In their place, layouts are named after the keyboard they describe:

- `KeyboardLayout.piano`: 12 keys per octave, C C♯ D E♭ E F F♯ G G♯ A B♭ B, anchored at
  MIDI 60 = C4. The spelling doesn't matter in 12-TET. With a meantone tuning it gives
  the historical E♭–G♯ keyboard.
- `KeyboardLayout.bohlenPierce`: degrees 0–12, one per key, with degree 0 on MIDI 60
  and MIDI 69 as the reference key. With `.a440`, key 69 (degree 9) sounds 440 Hz and
  key 60 sounds about 205.7 Hz. Today's map instead tunes key 60 to 12-TET middle C
  (≈ 261.6 Hz). The reference key is a choice, not a convention: no established
  Bohlen-Pierce reference pitch exists. Keeping MIDI 69 = 440 Hz matches the MIDI
  tuning convention.

These two are the only presets (decided 2026-11-02). `.piano` is also the only one
that works with `LinearTemperament`, since a degree layout needs
`ratio(forDegree:)`. Further layouts, such as a
sequential 19-EDO or 31-EDO layout, an A♭–C♯ meantone window, or split-key keyboards,
are plain pitch-class lists that callers build. Layouts for 19-EDO and 31-EDO vary
between instruments (sequential keys vs. Bosanquet-style generalized keyboards), so
no single choice suits every caller. See [Future Work](#future-work).

### Worked example: a 12-key subset of 19-EDO

```swift
let layout = try KeyboardLayout(pitchClasses: [.c, .cSharp, .d, .eFlat, .e, .f,
                                               .fSharp, .g, .gSharp, .a, .bFlat, .b])

let converter = try StandardToKeyboardPitchConverter(keyboardLayout: layout,
                                                     tuningSystem: EqualTemperament.edo19,
                                                     pitchStandard: .a440)
```

MIDI 69 sounds A4 at exactly 440 Hz. Its neighbors, 68 and 70, sound 19-EDO's G♯4 and
B♭4. Each of the seven spellings left out (D♭, D♯, E♯, G♭, A♭, A♯, B♯) lies exactly
one 19-EDO step from the keys on either side. For example, A♭4 is step 13, between
G♯4 at 12 and A4 at 14. A written A♭4 is therefore a tie. It goes to key 69, the
key whose spelling shares the written letter; see [Tie-breaking](#tie-breaking).
Every spelling left out resolves the same way, to the natural key of its own letter:
D♭ and D♯ → D, E♯ → E, F♭ → F, G♭ → G, A♯ → A, B♯ → B, C♭ → C. A full 19-key layout
simply lists all 19 spellings instead.

### Worked example: the Bohlen-Pierce Lambda scale on 12 keys

The Lambda mode uses 9 of Bohlen-Pierce's 13 degrees (steps 2 1 1 2 1 2 1 2 1). This
degree layout spreads them over 12 keys and leaves three black keys unmapped:

```swift
//                          C   C♯   D  D♯  E  F   F♯   G  G♯  A   A♯   B
let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])

let converter = try KeyboardToAbsolutePitchConverter(keyboardLayout: lambda,
                                                     tuningSystem: EqualTemperament.bohlenPierce,
                                                     pitchStandard: .a440)
```

The period is the tuning system's equivalence interval, so the 12-key pattern spans a
tritave: key 72 sounds 3:1 above key 60. The default `referenceNote`, 69, falls on
slot 9 (degree 10), which sounds 440 Hz. The unmapped C♯, F♯ and A♯ keys realize to
`nil`, and `absolute → keyboard` never picks them. A different arrangement moves the
`nil`s, as long as the degrees still ascend.

By default, a Bohlen-Pierce frequency outside the Lambda scale converts to the nearest
Lambda key. To make it fail instead, pass `keyMatching: .within(…)`; see
[Key matching](#key-matching).

### Worked example: 7-TET on the white keys, 5-TET on the black keys

Two different tunings interleaved on one keyboard need a raw-ratio layout. Neither
tuning supports standard notation, and a degree layout uses a single tuning system.
35-EDO contains both, but its degrees would not ascend across the keyboard: F is
514¢ and F♯ is 480¢. This layout is deliberately non-monotonic:

```swift
let white = (0..<7).map { Ratio(cents: Number($0) * 1200 / 7) }
let black = (0..<5).map { Ratio(cents: Number($0) * 1200 / 5) }

let layout = try KeyboardLayout(ratios: [white[0], black[0], white[1], black[1], white[2],
                                         white[3], black[2], white[4], black[3], white[5],
                                         black[4], white[6]],
                                equivalenceRatio: .octave,
                                referenceFrequency: 440)
```

Here both scales start on C, so C and C♯ sound the same pitch. Multiply `black` by an
offset ratio to start the black-key scale elsewhere. The `absolute` converters take
the layout through `init(keyboardLayout:)`. Frequency → key picks the nearest key on
either set of keys, and the C/C♯ unison always ties, so it goes to C, the lower key.

### Consequences

- **The pitch standard tunes the keyboard; it no longer transposes.** With `.a415`,
  written A4 → 69, and key 69 sounds 415 Hz. A transposing keyboard, if one is ever
  needed, is expressed in the layout (for example, key 69 sounding G♯4), not by
  mismatching anchors.
- **The restricted-gamut proposal is withdrawn.** A meantone keyboard with a fixed
  window on the chain of fifths is a 12-key pitch-class layout. A score's D♯ lands on
  the E♭ key, which is the folding that proposal described. `standard → absolute`
  with a restricted gamut is `standard → keyboard → absolute` through such a layout.
- **A pitch-class layout gives keys a fixed spelling.** Both spelling converters use
  it, and take no `PitchSpeller`, for pitch-class layouts; see [Spelling](#spelling).
- **`unrealize` performance is resolved.** The internal map precomputes all 128 key
  frequencies at init, so `convert` stops calling `exp`/`log` for every key. (The
  search is now `nearestKey(to:)`, and the lookup `frequency(of:)`.)
- **Interval methods stop being public.** `realize(noteDistance:)` and
  `unrealize(ratio:)` were removed rather than kept internal, since nothing used them.
  Nothing public offers `NoteDistance ↔ Ratio` until an interval API is designed; see
  [Future Work](#future-work).
- **`Status at a Glance` and the `KeyboardMap` sections become history.** They were
  rewritten on 2026-11-02 to describe what was built; see
  [Keyboards](#keyboards-keyboardlayout-and-the-internal-keyboardmap).

### Ripple outside IvorTuning

- **IvorModel:** `Work.ConvertContext` stores a `keyboardLayout` instead of a
  `keyboardMap`. Its private `concertKeyboardMap` becomes `.piano`. The default
  context also holds a `MeredithPitchSpeller`, and a speller wins over a pitch-class
  layout's spelling, so `keyboard → standard` and `absolute → standard` keep Meredith
  spelling, as today. `.piano` works with every tuning system the Convert sheet
  offers, including linear temperaments. `Work+Convert`
  passes the context's own tuning system and pitch standard to each converter, so a
  missing tuning system or pitch standard becomes an error on the `absolute ↔ keyboard`
  paths too. The exception is a raw layout: on the `absolute` paths,
  `Work+Convert` calls the short initializer and needs neither. `Work.Error` drops
  `emptyKeyboardMap` and maps `TuningError.invalidKeyboardLayout` instead.
  `Work.ConvertContext` gains a `keyMatching` setting, defaulting to `.nearest`, and
  passes it to the converters that take it. Also decided during implementation
  (2026-11-02):
  - `missingKeyboardMap` is renamed `missingKeyboardLayout`.
  - `keyboard → standard` requires a layout too, because the layout decides which keys
    are mapped.
  - Each part's pitches are converted as one sequence in performance order: by
    attack, then from low to high. A portamento note's end pitch comes right after its
    start pitch. This lets a context-aware speller see the passage.
- **IvorModel, choosing an initializer.** `Work+Convert` picks each converter's
  initializer by the context layout's kind (from its `definition`) and by whether the
  context has a `pitchSpeller`. The spelling conversions use the context's speller
  when it has one. Without one, a pitch-class layout spells itself, and any other
  layout throws `missingPitchSpeller`. A raw layout uses the short `absolute`
  initializers. A context is a bundle of dependencies, and a conversion that doesn't
  need one of them, such as the tuning system with a raw layout, simply doesn't use
  it.
- **`Work.Error.pitchOutOfRange` → `unconvertiblePitch(partID:)`, and
  `dropsOutOfRangeNotes:` → `dropsUnconvertibleNotes:`.** With `.within`, a note can
  fail because its pitch isn't on the layout, not because it is out of range. A
  converter returns only `nil`, so it can't say which. One error remains, documented
  as "has no counterpart in the target notation". "Unconvertible" names the outcome,
  not a cause, so it stays accurate as reasons are added. It also follows
  `Work.Error`'s adjective + noun pattern (`unsupportedPitchConversion`,
  `missingTuningSystem`, `duplicatePartID`). Rejected alternatives:
  - `pitchHasNoCounterpart`: reads as a sentence, unlike every other case.
  - `unmatchedPitch`: implies key matching is the only reason.
  - `pitchNotOnKeyboard`: wrong when the target isn't `keyboard`.

  Returning a reason from `convert` was also rejected, because it would undo the
  optional-return decision.
- **IvorApp, for the rename.** `ConvertSettings` persists the flag. It keeps the
  existing coding key, `case dropsUnconvertibleNotes = "dropsOutOfRangeNotes"`, so
  saved settings still decode. The Convert sheet's toggle title and description in
  `Localizable.xcstrings` are reworded (for example, "Drop notes that can't be
  converted"). `PanTests.codable_rejectsOutOfRangeLegacyStereoValue` is unrelated and
  keeps its name.
- **IvorApp, layout presets.** `KeyboardMapPreset` becomes a layout preset with two
  cases: `piano` (the default) and `bohlenPierce`. Saved `ConvertSettings` containing
  `"a415"`, `"a440"` and so on decode to the default, `piano`.
- **IvorApp, key matching** (decided 2026-11-02). The Convert sheet offers a toggle
  (for example, "Require Exact Match") plus a tolerance field in cents. It is shown
  whenever the conversion searches for a key: `standard → keyboard`,
  `absolute → keyboard` and `absolute → standard`. `ConvertSettings` stores two new
  values: `requiresExactKeyMatch: Bool` (default `false`) and
  `keyMatchToleranceCents: Double` (default 5). Toggle off gives `.nearest`; on gives
  `.within(Ratio(cents: keyMatchToleranceCents))`. Settings saved before this change
  lack both keys and decode to the defaults. The field accepts values above 0 and
  below 50¢: half a 12-TET step, beyond which ties and the nearest-key rule take over
  and "exact" stops meaning anything. Out-of-range entries are clamped. New strings
  (toggle title, field label, description) go in `Localizable.xcstrings`.
- **IvorApp, decided during implementation** (2026-11-02):
  - **Bohlen-Pierce tunes itself.** The app's tuning-system presets list only systems
    that support standard notation, so Bohlen-Pierce isn't among them. The app's
    `bohlenPierce` preset is therefore a raw-ratio layout with
    `EqualTemperament.bohlenPierce`'s 13 ratios. Its reference key is tuned to the chosen
    pitch standard's frequency, with the same keys as `KeyboardLayout.bohlenPierce`.
    The tuning-system picker is hidden for steps it tunes. A raw layout also keeps one
    context valid for varispeed, whose standard → absolute step still uses the context's
    tuning system.
  - **The sheets show what each step uses.**
    - Keyboard layout: every step from `keyboard` or `absolute`.
    - Pitch standard: standard → absolute, plus every step that tunes keys
      (`absolute → *`, `keyboard → absolute`).
    - Tuning system: the same steps, except where the layout tunes itself.
    - Key matching and dropping notes: `* → keyboard` and `absolute → standard`.
  - **The Play sheet's conversion menu** offers the layout, tuning system and pitch
    standard. Playback always uses `.nearest`, whatever the Convert sheet's key-matching
    setting, so no note is silently dropped from playback.
  - **The tolerance is clamped to 0.1–49.9¢.**
  - **New conversions are offered.** Works in absolute pitch can now be played, keyboard
    works can be varispeeded, and keyboard and absolute works can be converted to
    every notation, because `isConversionSupported(to:)` now reports those edges.

### Rollout

**Status:** decided 2026-11-02.

A **clean break**. Removing the public `KeyboardMap` and changing the converter
initializers breaks IvorTuning's API, so the change ships as a new major version of
IvorTuning, with IvorModel and IvorApp updated in the same round. There is no
transitional release with a deprecated `KeyboardMap`. It would bring back the very
presets this decision removes, and IvorTuning has no callers in the Ivor workspace
outside these packages.

### Implementation plan

**Status:** adopted 2026-11-02; completed 2026-11-02.

Each step leaves every package building and every existing test passing, apart from
tests that the step deliberately replaces.

1. **`KeyboardLayout`.** The four initializers, `Definition`, `init(_:)`,
   `keysPerPeriod`, the conformances, the two presets, and all
   `KeyboardLayout.init` validation with `Problem` and
   `TuningError.invalidKeyboardLayout`. Unit tests for every row of the validation
   table.
2. **`TuningSystem.ratio(forDegree:)`.** Add the requirement with its `nil` default, and
   implement it in `EqualTemperament`, `JustIntonation` and `WellTemperament`. Tests
   check the documented contract: `0..<n`, degree 0 is the unison, and degrees ascend.
3. **The internal `KeyboardMap`.** Build it from a layout + tuning system + pitch
   standard, or from a raw layout. Precompute the 128-key table, and validate against
   the tuning system (the converter-initializer checks). Search for the nearest key
   with tie-breaking, `KeyMatching`, and the distinct-pitch edge-of-range fix. The old
   public initializer, presets and interval methods become internal or are removed.
   `KeyboardMapTests` move to `@testable` tests of the internal type.
4. **The converters.** The new initializers, `init()` defaults, `KeyMatching`
   parameters and `TuningError.invalidKeyMatching`. Implement the three stubbed
   `absolute ↔ keyboard` and spelling converters, with `KeyboardLayoutSpeller`.
   Implement [Decision: Sequence-Based Spelling](#decision-sequence-based-spelling)
   in this step, because the spelling converters need it. Update
   `isConversionSupported(to:)` to report the new edges, and retire
   `TuningError.emptyKeyboardMap`. `StandardToKeyboardPitchConverter()` must still
   pass the 385-spelling test. The worked examples in this document become tests.
5. **IvorModel.** Make the `Work.ConvertContext` and `Work+Convert` changes, choose
   initializers by layout kind, map `Work.Error`, and rename to
   `unconvertiblePitch` and `dropsUnconvertibleNotes`.
6. **IvorApp.** Make the layout presets, the `ConvertSettings` migration, the
   key-matching toggle and tolerance, and the renamed flag with its kept coding key.
   Update the localized strings.
7. **This document.** Rewrite `Status at a Glance` and the `KeyboardMap` sections to
   describe what was built, and mark both decisions implemented.

### What changed during implementation

The implementation follows the decision, with these exceptions, all made on
2026-11-02:

- **`KeyboardMap`'s methods were renamed.** The lookup is `frequency(of:)` and the
  search is `nearestKey(to:letter:keyMatching:)`. "Realize" and "unrealize" read as
  exact inverses, and they aren't.
- **The interval methods were removed** rather than kept internal.
- **`TuningError.invalidKeyMatching` was not added.** `Ratio` is never below 1, so a
  negative tolerance can't be expressed.
- **`TuningError.unsupportedConversion(from:to:)` is kept, though nothing throws it.**
  Removing it is a separate API change.
- **A negative degree reports `unsupportedDegree(index:)`.** `Problem` has no
  separate case for it.
- **Layout spelling in `keyboard → standard` takes a tuning system.** The converter's
  initializer is `init(keyboardLayout:tuningSystem:)`, and the tuning-free placement
  rule was withdrawn; see [Spelling](#spelling).
- **IvorModel and IvorApp** made further choices, recorded in
  [Ripple outside IvorTuning](#ripple-outside-ivortuning).

---

## `keyboard → standard`: `PitchSpeller`

`PitchSpeller` assigns spelled pitch names to MIDI note numbers:

```swift
public protocol PitchSpeller: Equatable, Sendable {
    func spell(_ noteNumbers: [NoteNumber]) -> [Pitch]
}
```

The input is sorted by onset time, then by chromatic pitch (onset time takes
priority). The output is index-aligned with the input.

### `MeredithPitchSpeller`

The only concrete implementation applies the **PS13S1 algorithm** from Meredith
(2006). PS13S1 gives each note the spelling most strongly implied by its local tonal
context. That context is the distribution of chromas in a window around the note.

```swift
public struct MeredithPitchSpeller: PitchSpeller {
    public init(contextBefore: Int = 10, contextAfter: Int = 42)

    public let contextAfter: Int
    public let contextBefore: Int
}
```

### `KeyboardLayoutSpeller`

The spelling converters' initializers without a speller use `KeyboardLayoutSpeller`.
It spells each key with a pitch-class layout's own spelling, and its octaves come from
the layout's placement. It has no public initializer: the converters build it from the
internal `KeyboardMap`. Its spelling is fixed and context-free. With `.piano`, key 63
is always E♭4.

### Caveats

- **Sequence input required.** Pitch spelling depends on context, so the protocol
  has no single-note entry point. A spelling converter's single-pitch `convert(_:)`
  gives a lone note no context.
- **Intervals not covered.** There is no `NoteDistance → Interval` equivalent.
- **12-TET implicit.** PS13S1 assumes 12-tone equal temperament and is not suitable
  for microtonal contexts.

---

## Decision: Sequence-Based Spelling

**Status:** decided 2026-10-28; implemented 2026-11-02.

### Problem

`PitchConverter.convert(_:)` takes one pitch, but `PitchSpeller.spell(_:)` needs a
sequence to have any context. This blocks `KeyboardToStandardPitchConverter` and
`AbsoluteToStandardPitchConverter`.

### Decision

Add a sequence-level `convert` to `PitchConverter` as a protocol requirement, with a
default implementation that maps the single-pitch `convert(_:)` over the array:

```swift
public protocol PitchConverter: Equatable, Sendable {
    associatedtype FromPitchType: PitchProtocol
    associatedtype ToPitchType: PitchProtocol

    func convert(_ pitch: FromPitchType) -> ToPitchType?

    /// Converts a sequence of pitches in performance order (by onset, then low to high
    /// within a chord). Converters whose results depend on context use the whole sequence.
    func convert(_ pitches: [FromPitchType]) -> [ToPitchType?]
}

extension PitchConverter {
    public func convert(_ pitches: [FromPitchType]) -> [ToPitchType?] {
        pitches.map { convert($0) }
    }
}
```

The array version must be declared in the protocol body, not only in an extension.
Otherwise generic code calling it through `some PitchConverter` always gets the
default and never reaches a spelling converter's override.

The four converters that don't need context inherit the default. The two spelling
converters override it:

| Converter                          | `convert(_: [From])`                                                  | `convert(_: From)`        |
|------------------------------------|-----------------------------------------------------------------------|---------------------------|
| `KeyboardToStandardPitchConverter` | `pitchSpeller.spell(noteNumbers)`                                     | `convert([noteNumber])[0]` |
| `AbsoluteToStandardPitchConverter` | `keyboardMap.nearestKey(to:)` on each element, then `pitchSpeller.spell` on the mapped notes; out-of-range elements stay `nil` | `convert([frequency])[0]` |

(Under [Decision: Keyboard Layouts](#spelling), a pitch-class layout replaces the
speller with the layout's fixed spelling. Both forms are then context-free, and the
array form maps over the elements.)

On a spelling converter, single-pitch `convert(_:)` is a context-free fallback. With
`MeredithPitchSpeller`, a single note's context window contains only itself, so it
always gets the default spelling: naturals for white keys, and B♭, C♯, E♭, F♯, G♯ for
black keys. This must be documented on both spelling converters, pointing callers to
the sequence form for real spelling.

### Rationale

- **One API for every converter.** Code that converts a passage between notations
  chosen at runtime calls the array version on any converter. It gets plain
  conversion from four of them and context-aware spelling from the other two, with
  no special cases.
- **Single-pitch spelling stays predictable.** The fallback spelling is fixed and
  conventional, not arbitrary.
- **Cheap now.** Nothing in the library uses `PitchConverter` generically yet, so
  the protocol change breaks nothing.
- **`isConversionSupported(to:)` stays truthful.** Both spelling directions can be
  reported as supported once implemented.

### Alternatives rejected

- **Spell each note on its own, with no sequence API.** Trivial to wire up, but
  quietly gives poor results to every caller working with real music.
- **Keep spelling outside the `PitchConverter` family.** Splits the API.
  `isConversionSupported(to:)` would permanently report two directions as
  unsupported even though they are reachable by other means.

### Implementation notes

- **Ordering is the caller's job.** A converter can't know onset times, so the
  ordering contract lives on the array method's documentation. Converters that
  don't depend on context ignore order.
- **Empty maps are rejected at init.** `TuningError.emptyKeyboardMap` and the
  internal `KeyboardMap.hasMappedNotes` check now exist (added for
  `StandardToKeyboardPitchConverter`). `AbsoluteToStandardPitchConverter` and
  `AbsoluteToKeyboardPitchConverter` should use the same check. (Superseded by
  [Decision: Keyboard Layouts](#validation): every layout maps its anchor key, so
  `emptyKeyboardMap` is retired.)
- **Overload vs. distinct name.** The design overloads `convert(_:)`. A distinct
  name such as `convertSequence(_:)` is an acceptable substitute if the overload
  proves confusing at call sites.

---

## Future Work

There are no open questions about the decisions above. The following are outside
the scope of the keyboard-layout implementation and are recorded for later:

- **`.kbm`/`.scl` import and export.** A `.kbm` file corresponds to a degree layout
  when its `.scl` matches a library tuning system. Otherwise the `.scl`/`.kbm` pair
  imports as a raw-ratio layout, with scale degrees resolved to ratios at import
  time. Export is straightforward for degree and raw-ratio layouts. A pitch-class
  layout would export as its resolved ratios in a given tuning system, losing its
  spellings. A frequency layout has no period, so it can't be exported as `.kbm`.

- **MIDI Tuning Standard import and export.** A per-key MTS bulk dump is the natural
  file format for a frequency layout, in both directions.

- **Predefined layouts for 19-EDO and 31-EDO.** Layouts vary between instruments, so
  none ships now; see [Predefined layouts](#predefined-layouts). Each is a plain
  pitch-class list.

- **Interval conversion.** There is no public interval conversion involving
  `keyboard`. `Interval → NoteDistance`, the counterpart of `standard → keyboard`, is
  not implemented, and `KeyboardMap`'s interval methods were removed. An interval
  API would also need a layout: a `NoteDistance` means a different ratio on every
  keyboard.

- **`NoteDistance → Interval` spelling.** There is no interval equivalent of
  `PitchSpeller`. Spelling the interval between two notes needs the spelled pitches
  at both ends, which in turn needs musical context. This may never warrant a
  dedicated API.
