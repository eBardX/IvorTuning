import Foundation
import IvorTuning
import Testing

struct IntervalDirectionTests {
}

// MARK: -

extension IntervalDirectionTests {
    @Test
    func codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in [IntervalDirection.ascending, .descending, .same] {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(IntervalDirection.self, from: data)

            #expect(decoded == value)
        }
    }
}
