// © 2026 John Gary Pusey (see LICENSE.md)

/// How strictly a converter matches a pitch to a key of a ``KeyboardLayout``.
///
/// Matching is acoustic: a pitch matches a key if it *sounds* close enough, regardless of its
/// spelling. In either mode, a pitch beyond the lowest or highest key matches that key only if it
/// lies within half the step to the key’s nearest distinct inner neighbor.
public enum KeyMatching {

    /// The nearest key, however far away it is.
    case nearest

    /// The nearest key, but only if it lies within the given tolerance of the target; otherwise no
    /// key.
    ///
    /// For example, `.within(Ratio(cents: 5))` rejects a pitch more than 5 cents from every key.
    case within(Ratio)
}

// MARK: - Codable

extension KeyMatching: Codable {
}

// MARK: - Equatable

extension KeyMatching: Equatable {
}

// MARK: - Hashable

extension KeyMatching: Hashable {
}

// MARK: - Sendable

extension KeyMatching: Sendable {
}
