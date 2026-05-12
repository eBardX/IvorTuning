public enum IntervalDirection {
    case descending
    case same
    case ascending
}

// MARK: - Codable

extension IntervalDirection: Codable {
}

// MARK: - Sendable

extension IntervalDirection: Sendable {
}
