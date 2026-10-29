# Notation Conversion Design

This document describes how IvorTuning converts between its three `PitchNotation`
systems: what is implemented, what is stubbed, and what remains undecided. It began
as a design brainstorm; the original proposal is preserved in git history.

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

Conversions are exposed through two layers:

- **Building blocks** — the types that do the actual math: `TuningSystem` +
  `PitchStandard`, `KeyboardMap`, and `PitchSpeller`.
- **Converters** — one `PitchConverter` type per directed edge, each wrapping the
  building blocks that edge needs.

All the building blocks are implemented. Of the six converters, two are implemented:
`StandardToAbsolutePitchConverter` and `StandardToKeyboardPitchConverter`. The other
four are stubs whose initializers always throw
`TuningError.unsupportedConversion(from:to:)`.

| From       | To         | Converter                                   | Building blocks                                 | Status      |
|------------|------------|---------------------------------------------|-------------------------------------------------|-------------|
| `standard` | `absolute` | `StandardToAbsolutePitchConverter`          | `TuningSystem`, `PitchStandard`                 | Implemented |
| `standard` | `keyboard` | `StandardToKeyboardPitchConverter`          | `TuningSystem`, `PitchStandard`, `KeyboardMap`  | Implemented |
| `absolute` | `keyboard` | `AbsoluteToKeyboardPitchConverter`          | `KeyboardMap.unrealize(frequency:)`             | Stub        |
| `keyboard` | `absolute` | `KeyboardToAbsolutePitchConverter`          | `KeyboardMap.realize(noteNumber:)`              | Stub        |
| `keyboard` | `standard` | `KeyboardToStandardPitchConverter<Speller>` | `PitchSpeller`                                  | Stub        |
| `absolute` | `standard` | `AbsoluteToStandardPitchConverter<Speller>` | `KeyboardMap`, `PitchSpeller`                   | Stub        |

Callers should check `PitchNotation.isConversionSupported(to:)` before creating a
converter. It returns `true` for `standard → absolute` and `standard → keyboard`, and
never for a notation converted to itself.

```
            StandardToAbsolute (implemented)
standard ─────────────────────────────────► absolute
   │  ▲  ╲                                   │  ▲
   │  │   ╲ StandardToKeyboard   KeyboardMap │  │ KeyboardMap
   │  │    ╲ (implemented)         unrealize │  │ realize
   │  │ PitchSpeller ╲               (stub)  │  │ (stub)
   │  │ (stub)        ╲                      ▼  │
   └──┴───────────────► keyboard ◄────────────┘
```

The building blocks for the stubbed edges already work and can be called directly.
`KeyboardMap.realize` and `unrealize` cover `keyboard ↔ absolute` today. Wiring them
into their converters is mostly mechanical. The two spelling converters need a
protocol change first; see [Decision: Sequence-Based Spelling](#decision-sequence-based-spelling).

---

## The `PitchConverter` Protocol

```swift
public protocol PitchConverter: Equatable, Sendable {
    associatedtype FromPitchType: PitchProtocol
    associatedtype ToPitchType: PitchProtocol

    func convert(_ pitch: FromPitchType) -> ToPitchType?
}
```

`convert(_:)` returns `nil` when the pitch has no counterpart in the target notation.
For example, `Pitch` reaches C𝄫−1 and B𝄪9 but MIDI stops at 0 and 127, and a keyboard
map may leave keys unmapped. Clamping would silently give a wrong answer, and
trapping would crash on valid input. The optional also matches the library's
existing style: `KeyboardMap.realize`/`unrealize` and `transposed(by:)` already
return optionals. Converters whose conversion always succeeds, such as
`StandardToAbsolutePitchConverter`, document that they never return `nil`.

Checks that depend only on the configuration belong in the converter's throwing
initializer, not in `convert`. Three errors can come out of a converter initializer:

- `TuningError.unsupportedConversion(from:to:)` — the edge itself is not implemented
  (thrown by the four stubs).
- `TuningError.unsupportedStandardConversion` — the edge is implemented, but the
  given tuning system cannot express standard notation.
- `TuningError.emptyKeyboardMap` — the keyboard map doesn't map any MIDI note number,
  so no conversion through it could succeed.

There are no interval converters. Interval conversion is available only where a
building block provides it directly (`KeyboardMap.realize(noteDistance:)` and
`unrealize(ratio:)`).

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

**Status:** deferred 2026-10-28; not designed in detail.

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

**Status:** implemented 2026-10-28.

### The default: piano key assignments

```swift
public struct StandardToKeyboardPitchConverter: PitchConverter {
    public init()   // KeyboardMap.a440, EqualTemperament.edo12, PitchStandard.a440

    public init(keyboardMap: KeyboardMap,
                tuningSystem: some TuningSystem,
                pitchStandard: PitchStandard = .a440) throws(TuningError)

    public func convert(_ pitch: Pitch) -> NoteNumber?
}
```

The no-argument initializer gives the usual piano key assignments: 12-tone equal
temperament, A4 = 440 Hz, and the standard MIDI layout. It cannot fail. For every
pitch whose key is in 0–127, the result matches the notational formula
`12 × (octave + 1) + letter + accidental`. So B♯3 → 60, C4 → 60, D𝄫4 → 60,
C♭4 → 59, A4 → 69, C−1 → 0 and G9 → 127. A test checks all 385 spellings
(35 pitch classes × 11 octaves) against that formula.

### Semantics: acoustic

Conversion goes through frequency: `StandardToAbsolutePitchConverter.convert`, then
`KeyboardMap.unrealize(frequency:)`. The result is the mapped key that *sounds*
nearest the pitch. There is no separate code path for the default: the notational
and acoustic answers coincide there, so a second implementation would be redundant.

Acoustic semantics generalizes to keyboards with other than 12 keys per octave
(e.g., a 19-EDO layout where C♯ and D♭ are different keys). It has two consequences
worth documenting:

- **A mismatched pitch standard transposes; it isn't an error.** With
  `pitchStandard: .a415` and `keyboardMap: .a440`, written A4 → 68 (G♯4), the key
  that sounds closest to 415 Hz. There is no validation that the pitch standard
  agrees with the keyboard map's reference.
- **Non-12-TET tunings follow the sound, not the spelling.** In quarter-comma
  meantone with `KeyboardMap.a440`, B𝄪3 sounds about 45¢ above C4, nearer C4 than
  C♯4, so it converts to 60, not 61.

### Why the converter isn't generic

The converter only needs the tuning system at init time, to build its internal
`StandardToAbsolutePitchConverter`, so it takes `some TuningSystem` rather than being
generic over `System`. That lets `init()` live on the type itself. A generic type
would need a constrained extension (`where System == EqualTemperament`), and Swift
does not allow static stored properties on generic types.

### Out-of-range pitches

`Pitch` spans MIDI −2 (C𝄫−1) to 133 (B𝄪9). `convert` returns `nil` for pitches that
lie beyond the lowest or highest mapped key by more than half the step to that key's
inner neighbor; the rule lives in `KeyboardMap.unrealize`. With the default, that
means C♭−1, C𝄫−1, and every octave-9 spelling above G9 (G♯9 onward) return `nil`.

---

## `absolute ↔ keyboard`: `KeyboardMap`

`KeyboardMap` encodes a repeating pitch pattern laid out across MIDI note numbers.

### Structure

```swift
public struct KeyboardMap {
    public init(referenceNote: NoteNumber,
                referenceFrequency: Frequency,
                middleNote: NoteNumber,
                equivalenceRatio: Ratio,
                ratios: [Ratio?])

    public let equivalenceRatio: Ratio    // interval of equivalence of the pattern
    public let middleNote: NoteNumber     // where ratios[0] (unison) is placed
    public let ratios: [Ratio?]           // one per key slot; nil = unmapped
    public let referenceFrequency: Frequency
    public let referenceNote: NoteNumber
}
```

A keyboard map has two independent anchors:

- **Intonation anchor** (`referenceNote` + `referenceFrequency`) fixes the actual
  frequency of one MIDI note.
- **Layout anchor** (`middleNote`) identifies the MIDI note where `ratios[0]`
  (the unison) is placed. The pattern repeats outward from there, one
  `equivalenceRatio` per `ratios.count` keys.

They are separate because a transposed keyboard map often keeps the intonation
reference fixed (e.g., A4 = 440 Hz) while putting the scale root on a different key.

`ratios` stores `Ratio?` values directly rather than Scala-style scale-degree
indices. This keeps `KeyboardMap` self-contained, with no runtime dependency on
`TuningSystem`. A `.kbm` import would resolve scale degrees to ratios when the map is
built, not when it is used.

### Predefined maps

There is one 12-TET piano-layout map for each `PitchStandard` constant, with the
same name and reference:

| Map      | Reference             | Pairs with           |
|----------|-----------------------|----------------------|
| `.a415`  | MIDI 69 (A4) = 415 Hz | `PitchStandard.a415` |
| `.a432`  | MIDI 69 (A4) = 432 Hz | `PitchStandard.a432` |
| `.a435`  | MIDI 69 (A4) = 435 Hz | `PitchStandard.a435` |
| `.a440`  | MIDI 69 (A4) = 440 Hz | `PitchStandard.a440` |
| `.c256`  | MIDI 60 (C4) = 256 Hz | `PitchStandard.c256` |

Each has 12 slots of 12-TET ratios, `middleNote` 60 (matching the Scala `.kbm`
convention) and every key mapped. Using a map with its matching pitch standard gives
the usual piano key assignments at that pitch (A4 → 69). Mixing them transposes; see
[`standard → keyboard`](#standard--keyboard-standardtokeyboardpitchconverter). The
names parallel `PitchStandard`. "Standard" was avoided because in this library it
means standard notation.

`KeyboardMap.bohlenPierce` is Bohlen-Pierce equal temperament: 13 keys per tritave
(3:1), each step ¹³√3 ≈ 146.3¢, every key mapped. Its unison is on MIDI 60, tuned to
middle C's frequency in `.a440` (≈ 261.626 Hz), so MIDI 73 sounds a tritave above.
There is no established reference pitch for Bohlen-Pierce, so this anchor is a
choice, not a convention. It pairs with `EqualTemperament.bohlenPierce`, but standard
notation can't drive it: Bohlen-Pierce has no `standardConversion`, so it is reachable
only through `absolute ↔ keyboard`.

### Conversion methods

```swift
// keyboard → absolute
func realize(noteNumber: NoteNumber) -> Frequency?
func realize(noteDistance: NoteDistance) -> Ratio?

// absolute → keyboard (nearest mapped key, within range)
func unrealize(frequency: Frequency) -> NoteNumber?
func unrealize(ratio: Ratio) -> NoteDistance?
```

- `realize(noteNumber:)` returns `nil` if the note or the `referenceNote` falls on an
  unmapped slot, or if `ratios` is empty.
- `realize(noteDistance:)` measures upward from `middleNote` (`NoteDistance` is
  unsigned). It returns `nil` if that slot is unmapped.
- `unrealize` checks every note number (or distance) from 0 through 127 and returns
  the one whose realized value is nearest the target, measured as a ratio. It returns
  `nil` if nothing in that range is mapped. It also returns `nil` if the target lies
  beyond the lowest or highest realized value by more than half the step to that
  value's inner neighbor (measured geometrically). In 12-TET that is 50¢ past MIDI 0
  or 127.

The Scala `.kbm` retune range (which MIDI notes the mapping applies to) is
deliberately left out. It is a deployment concern, not a mathematical property of the
mapping, and belongs in a caller-level wrapper if it is ever needed.

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

### Caveats

- **Sequence input required.** Pitch spelling depends on context, so the protocol
  has no single-note entry point.
- **Intervals not covered.** There is no `NoteDistance → Interval` equivalent.
- **12-TET implicit.** PS13S1 assumes 12-tone equal temperament and is not suitable
  for microtonal contexts.

---

## Decision: Sequence-Based Spelling

**Status:** decided 2026-10-28; not yet implemented.

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
| `AbsoluteToStandardPitchConverter` | `keyboardMap.unrealize(frequency:)` on each element, then `pitchSpeller.spell` on the mapped notes; out-of-range elements stay `nil` | `convert([frequency])[0]` |

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
  `AbsoluteToKeyboardPitchConverter` should use the same check.
- **Overload vs. distinct name.** The design overloads `convert(_:)`. A distinct
  name such as `convertSequence(_:)` is an acceptable substitute if the overload
  proves confusing at call sites.

---

## Open Questions

- **Restricted gamut for linear temperaments.** Modelling keyboards with a fixed
  window of the chain of fifths; see
  [Proposal: restricted gamut for linear temperaments](#proposal-restricted-gamut-for-linear-temperaments).

- **Keyboard maps for other EDOs.** 19-EDO and 31-EDO support standard notation but
  have no predefined keyboard map. Their layouts vary between instruments
  (sequential keys vs. Bosanquet-style generalized keyboards), so the right choice
  depends on the intended hardware.

- **`unrealize` performance.** Each call realizes all 128 keys (with `exp`/`log` per
  key), so `StandardToKeyboardPitchConverter.convert` does too. This is fine for now.
  A closed-form search for evenly spaced maps, or a table built at init, can come
  later if needed.

- **`Interval → NoteDistance`.** The interval counterpart of `standard → keyboard`
  is not implemented.

- **`NoteDistance → Interval` spelling.** There is no interval equivalent of
  `PitchSpeller`. Spelling the interval between two notes requires the spelled
  pitches at both ends, which in turn requires musical context. This may not
  warrant a dedicated API.

- **`.kbm` import/export.** Import needs a companion `.scl` file or `TuningSystem` to
  resolve scale degrees to ratios when the map is built. Export may lose
  information for maps whose ratios don't match a known scale.

- **`Frequency → Pitch` outside 12-TET.** Going through `keyboard` works only when
  `KeyboardMap.unrealize` lands on meaningful 12-TET note numbers. Proper spelling of
  frequencies in other tuning systems is deferred.
