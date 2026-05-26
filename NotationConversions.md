# Notation Conversion Design

This document describes how IvorTuning converts between its three `PitchNotation`
systems. It began as a design brainstorm; the original proposal is preserved in git
history.

---

## The Three Systems

Each notation system has a concrete pitch type and a concrete interval type:

| Notation   | Pitch Type   | Interval Type  | What it represents                    |
|------------|--------------|----------------|---------------------------------------|
| `standard` | `Pitch`      | `Interval`     | Letter name + accidental + octave     |
| `absolute` | `Frequency`  | `Ratio`        | Frequency in Hz / frequency ratio     |
| `keyboard` | `NoteNumber` | `NoteDistance` | MIDI note number / semitone distance  |

---

## The Conversion Graph

All six directed edges of the conversion triangle are now supported, though two
directions have caveats noted below.

```
standard ──────────────────────────► keyboard
    │                                  │  ▲
    │                             PS13S1  │
    ▼                                  ▼  │
absolute ◄──────────────────────────────►
```

### Supported conversions

| From       | To         | Mechanism                                            | Notes                                    |
|------------|------------|------------------------------------------------------|------------------------------------------|
| `standard` | `absolute` | `TuningSystem.realize(_:)` (+ `PitchStandard`)       |                                          |
| `standard` | `keyboard` | `standard` → `absolute` → `keyboard`                 | Indirect path                            |
| `absolute` | `keyboard` | `KeyboardMap.unrealize(frequency:)`              | Always nearest mapped note               |
| `keyboard` | `absolute` | `KeyboardMap.realize(noteNumber:)`               | Exact                                    |
| `keyboard` | `standard` | `PitchSpeller.spell(_:)` (`MeredithPitchSpeller`)    | Note sequences only; see below           |
| `absolute` | `standard` | `absolute` → `keyboard` → `standard`                 | Indirect; same caveats as `keyboard → standard` |

The interval conversions (`Interval`, `Ratio`, `NoteDistance`) follow the same
routing, with the exception noted in [Open Questions](#open-questions).

---

## `standard ↔ absolute`: `TuningSystem` + `StandardToAbsolutePitchConverter`

The `standard → absolute` direction is handled by `StandardToAbsolutePitchConverter`,
a pre-computed lookup table initialized from a `TuningSystem` and a `PitchStandard`.

### Protocol hook: `TuningSystem.standardConversion(for:)`

Each supporting tuning system provides its own pitch-class mapping via:

```swift
func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]?
```

Returns `nil` if the tuning system does not support standard pitch notation (e.g.
because its interval of equivalence is not 2:1, or it has more than 35 distinct pitch
classes per octave). Otherwise returns exactly 35 entries — one per pitch class
(7 letters × 5 accidentals).

**Convention for each entry:** the directed frequency ratio from the reference pitch to
the instance of that pitch class within the **same SPN octave** as the reference.
Direction is `.ascending` if that same-octave instance lies above the reference,
`.descending` if below, and `.same` if it is the reference (or enharmonically
equivalent).

For example, with A4 as the reference, every entry corresponds to a pitch in [C4, B4].
B maps to the ascending ratio to B4 — not to the nearer descending ratio to B3. This
same-SPN-octave rule holds for all pitch classes, regardless of the reference pitch
class chosen.

### `StandardToAbsolutePitchConverter`

```swift
public struct StandardToAbsolutePitchConverter {
    public init(tuning: some TuningSystem,
                standard: PitchStandard = .a440) throws

    public func convert(_ pitch: Pitch) -> Frequency
}
```

`init` throws `TuningError.unsupportedStandardConversion` if the tuning system returns
`nil` from `standardConversion(for:)`. Once initialized, `convert` is non-optional —
a successfully initialized converter is guaranteed to cover all 35 pitch classes, so
no optional unwrapping is required at call sites.

### Scope and limitations

The following categories of tuning system support `standardConversion(for:)`:

- Well temperaments and linear temperaments (meantone, Pythagorean)
- EDOs with at most 35 divisions and a 2:1 period (12-EDO, 19-EDO, 31-EDO)
- 5-limit just intonation (`JustIntonation.fiveLimit`)

Not supported (return `nil`):

- Non-octave period systems (e.g., Bohlen-Pierce) — standard notation assumes 2:1
- Tuning systems with more than 35 distinct pitch classes (e.g., 53-EDO)
- Extended linear temperaments
- Just intonations beyond 5-limit (e.g., `sevenLimit`, `partch43`) — diverge too far
  from Pythagorean; may also exceed the 35-class limit
- Other EDOs may produce unexpected results (e.g., 17-EDO)

`PitchStandard` anchors the conversion by associating a `Pitch` with a `Frequency`.
Predefined constants: `a415`, `a432`, `a435`, `a440`, `c256`.

The reverse direction (`absolute → standard`) has no direct support. It is reachable
indirectly via `absolute → keyboard → standard`, subject to the same caveats as the
`keyboard → standard` direction described below.

---

## `absolute ↔ keyboard`: `KeyboardMap`

`KeyboardMap` is the bridge for the `absolute ↔ keyboard` edge. It encodes a
repeating pitch pattern across a MIDI keyboard layout.

### Structure

```swift
public struct KeyboardMap {
    /// The MIDI note where ratios[0] (unison) is placed.
    let middleNote: NoteNumber

    /// The frequency ratio spanned by one full period of the repeating pattern.
    let periodRatio: Ratio

    /// The ratio for each key slot in the repeating period. nil means unmapped.
    let ratios: [Ratio?]

    /// The frequency of the reference note.
    let referenceFrequency: Frequency

    /// The MIDI note whose frequency is known.
    let referenceNote: NoteNumber
}
```

The keyboard map is defined by two independent anchors:

- **Intonation anchor** (`referenceNote` + `referenceFrequency`): fixes the actual
  frequency of a specific MIDI note.
- **Layout anchor** (`middleNote`): identifies the MIDI note where `ratios[0]`
  (the unison) is placed. The repeating pattern radiates outward from here.

These anchors are distinct because transposed keyboard maps often keep the intonation
reference fixed (e.g. A4 = 440 Hz) while placing the scale root on a different key.

`ratios` stores `Ratio?` values directly — one per key slot in the period — rather
than Scala-style scale-degree indices. This makes `KeyboardMap` self-contained
with no runtime dependency on `TuningSystem`. (A `.kbm` import would resolve scale
degrees to ratios at construction time, not at realize/unrealize time.)

### Conversion methods

```swift
// keyboard → absolute
func realize(noteNumber: NoteNumber) -> Frequency?
func realize(noteDistance: NoteDistance) -> Ratio?

// absolute → keyboard (always-nearest rounding)
func unrealize(frequency: Frequency) -> NoteNumber?
func unrealize(ratio: Ratio) -> NoteDistance?
```

`realize` returns `nil` if the note falls on an unmapped slot (`nil` in `ratios`)
or if the `referenceNote` itself is unmapped. `unrealize` returns `nil` only if no
key at all is mapped; otherwise it always returns the nearest mapped note.

The retune-range field from the Scala `.kbm` format (which MIDI notes to apply the
keyboard mapping to) is intentionally absent. It is a deployment concern, not a mathematical
property of the keyboard mapping, and belongs in a caller-level wrapper if ever needed.

---

## `keyboard → standard`: `PitchSpeller`

`PitchSpeller` is a protocol for assigning spelled pitch names to MIDI note numbers:

```swift
public protocol PitchSpeller: Sendable {
    func spell(_ noteNumbers: [NoteNumber]) -> [Pitch]
}
```

The input is a sequence of note numbers in onset order; the output is an
index-aligned array of `Pitch` values.

### `MeredithPitchSpeller`

The sole concrete implementation applies the **PS13S1 algorithm** from Meredith
(2006). PS13S1 assigns each note the spelling most strongly implied by local tonal
context, modelled as the frequency distribution of chromas within a sliding window
surrounding each note.

```swift
public struct MeredithPitchSpeller: PitchSpeller {
    let contextBefore: Int  // default: 10
    let contextAfter: Int   // default: 42
}
```

### Caveats

- **Sequence input required.** Pitch spelling is inherently context-dependent;
  single-note spelling is not supported.
- **Intervals not covered.** There is no `NoteDistance → Interval` spelling
  equivalent. This would require a different framing (e.g. given the spelled
  pitches at both ends of the interval).
- **12-TET implicit.** PS13S1 assumes 12-tone equal temperament. It is not
  suitable for microtonal contexts.

---

## Routing Summary

| Conversion             | Route                                        | Types involved                                    |
|------------------------|----------------------------------------------|---------------------------------------------------|
| `standard` → `absolute`| direct                                       | `StandardToAbsolutePitchConverter`                |
| `standard` → `keyboard`| `standard` → `absolute` → `keyboard`         | `StandardToAbsolutePitchConverter`, then `KeyboardMap` |
| `absolute` → `keyboard`| direct                                       | `KeyboardMap`                                 |
| `keyboard` → `absolute`| direct                                       | `KeyboardMap`                                 |
| `keyboard` → `standard`| direct (note sequences only)                 | `PitchSpeller`                                    |
| `absolute` → `standard`| `absolute` → `keyboard` → `standard`         | `KeyboardMap`, then `PitchSpeller`            |

---

## Open Questions

- **`KeyboardMap` predefined constants** — analogous to `PitchStandard.a440`,
  there should be a `KeyboardMap.standard` (12-TET, A4 = 440 Hz, middle C on
  MIDI 60). Other candidates: Bohlen-Pierce tritave keyboard map.

- **`NoteDistance → Interval` spelling** — there is no interval equivalent of
  `PitchSpeller`. Computing the spelled interval between two notes would require
  the spelled pitches at both endpoints, which in turn requires musical context.
  This may not warrant a dedicated API.

- **`.kbm` import/export** — import requires a companion `.scl` or `TuningSystem`
  to resolve scale degrees to ratios at construction time. Export may be lossy for
  `KeyboardMap` instances whose ratios don't align to a known scale.

- **Pitch spelling for `absolute → standard`** — the indirect route
  (`absolute → keyboard → standard`) works only in 12-TET contexts where
  `KeyboardMap.unrealize` maps cleanly to MIDI note numbers. Proper
  `Frequency → Pitch` spelling in other tuning systems remains deferred.
