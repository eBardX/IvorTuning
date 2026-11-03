# IvorTuning

Musical pitch, interval, and tuning system types.

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBardX/IvorTuning/blob/main/LICENSE.md)

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#spm_installation)
* [Quick Start](#quick_start)
* [Documentation](#documentation)
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorTuning framework provides musical pitch, interval, and tuning system
types written in Swift. Pitches and intervals are each available in standard,
keyboard, and absolute (frequency) representations. Several tuning systems are
provided, including equal temperament, just intonation, meantone temperament,
Pythagorean tuning, and well temperament.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3 toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

IvorTuning is distributed exclusively through the [Swift Package Manager][spm].

To add IvorTuning to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/IvorTuning.git",
             .upToNextMinor(from: "0.13.0"))
]
```

Then add `IvorTuning` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "IvorTuning",
                                package: "IvorTuning")])
```

To add IvorTuning to an Xcode project, choose **File ▸ Add Package
Dependencies…** and enter the repository URL:

```
https://github.com/eBardX/IvorTuning.git
```

IvorTuning depends on [XestiNumbers][xestinumbers] and
[XestiTools][xestitools]; the Swift Package Manager resolves them
automatically.

## <a name="quick_start">Quick Start</a>

Convert pitches between standard notation, frequencies, and MIDI note numbers:

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

For the complete story — the pitch and interval types, the tuning systems,
keyboard layouts, spelling, and error handling — see the [usage guide][guide].

## <a name="documentation">Documentation</a>

* [Using IvorTuning][guide] — a guide to using the public API, published as
  part of the DocC documentation.
* Every public declaration carries a DocC comment.

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorTuning is available under [the MIT license][license].

[docc]:          https://www.swift.org/documentation/docc/
[guide]:         https://eBardX.github.io/ivor-packages-docs/documentation/ivortuning/usingivortuning
[license]:       https://github.com/eBardX/IvorTuning/blob/main/LICENSE.md
[refdoc]:        https://eBardX.github.io/ivor-packages-docs/documentation/ivortuning
[spm]:           https://swift.org/package-manager/
[xestinumbers]:  https://github.com/eBardX/XestiNumbers
[xestitools]:    https://github.com/eBardX/XestiTools
