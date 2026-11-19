// © 2026 John Gary Pusey (see LICENSE.md)

extension Key {

    // MARK: Public Nested Types

    /// The mode of a diatonic key, apart from its tonic.
    ///
    /// Ionian and aeolian aren't separate modes: ``init(name:)`` reads them as ``major`` and
    /// ``minor``.
    public enum Mode: String, CaseIterable {

        /// The major mode (ionian).
        case major

        /// The minor mode (aeolian).
        case minor

        /// The dorian mode.
        case dorian

        /// The phrygian mode.
        case phrygian

        /// The lydian mode.
        case lydian

        /// The mixolydian mode.
        case mixolydian

        /// The locrian mode.
        case locrian
    }
}

// MARK: -

extension Key.Mode {

    // MARK: Public Initializers

    /// Creates a mode from a mode name, as a file format gives it.
    ///
    /// The name is read case-insensitively. `"ionian"` is read as ``major`` and `"aeolian"` as
    /// ``minor``.
    ///
    /// - Parameter name:   The mode name (e.g., `"Minor"`, `"dorian"`, `"aeolian"`).
    ///
    /// - Returns:  `nil` if `name` isn't the name of a mode, including `"none"`.
    public init?(name: String) {
        switch name.lowercased() {
        case "aeolian":
            self = .minor

        case "ionian":
            self = .major

        case let lowercased:
            self.init(rawValue: lowercased)
        }
    }

    // MARK: Public Instance Properties

    /// The mode this one becomes when a key is inverted.
    ///
    /// Inversion reverses a diatonic collection, so major and phrygian swap, as do minor and
    /// mixolydian, and lydian and locrian; dorian is its own inversion.
    public var inverted: Self {
        switch self {
        case .dorian:
            .dorian

        case .locrian:
            .lydian

        case .lydian:
            .locrian

        case .major:
            .phrygian

        case .minor:
            .mixolydian

        case .mixolydian:
            .minor

        case .phrygian:
            .major
        }
    }

    // MARK: Internal Instance Properties

    //
    // The index of the tonic in its diatonic collection, which runs from one fifth below the
    // major tonic to five above it.
    //
    internal var diatonicIndex: Int {
        switch self {
        case .dorian:
            3

        case .locrian:
            6

        case .lydian:
            0

        case .major:
            1

        case .minor:
            4

        case .mixolydian:
            2

        case .phrygian:
            5
        }
    }
}

// MARK: - Codable

extension Key.Mode: Codable {
}

// MARK: - Hashable

extension Key.Mode: Hashable {
}

// MARK: - Sendable

extension Key.Mode: Sendable {
}
