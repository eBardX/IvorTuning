// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct IntervalCommonTests {
}

// MARK: -

extension IntervalCommonTests {
    @Test
    func augmented_sizes() {
        let entries: [(Interval, Int)] = [(.augmented1, 1),
                                          (.augmented2, 2),
                                          (.augmented3, 3),
                                          (.augmented4, 4),
                                          (.augmented5, 5),
                                          (.augmented6, 6),
                                          (.augmented7, 7),
                                          (.augmented8, 8),
                                          (.augmented9, 9),
                                          (.augmented10, 10),
                                          (.augmented11, 11),
                                          (.augmented12, 12),
                                          (.augmented13, 13),
                                          (.augmented14, 14),
                                          (.augmented15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .augmented)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func diminished_sizes() {
        let entries: [(Interval, Int)] = [(.diminished2, 2),
                                          (.diminished3, 3),
                                          (.diminished4, 4),
                                          (.diminished5, 5),
                                          (.diminished6, 6),
                                          (.diminished7, 7),
                                          (.diminished8, 8),
                                          (.diminished9, 9),
                                          (.diminished10, 10),
                                          (.diminished11, 11),
                                          (.diminished12, 12),
                                          (.diminished13, 13),
                                          (.diminished14, 14),
                                          (.diminished15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .diminished)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func doublyAugmented_sizes() {
        let entries: [(Interval, Int)] = [(.doublyAugmented1, 1),
                                          (.doublyAugmented2, 2),
                                          (.doublyAugmented3, 3),
                                          (.doublyAugmented4, 4),
                                          (.doublyAugmented5, 5),
                                          (.doublyAugmented6, 6),
                                          (.doublyAugmented7, 7),
                                          (.doublyAugmented8, 8),
                                          (.doublyAugmented9, 9),
                                          (.doublyAugmented10, 10),
                                          (.doublyAugmented11, 11),
                                          (.doublyAugmented12, 12),
                                          (.doublyAugmented13, 13),
                                          (.doublyAugmented14, 14),
                                          (.doublyAugmented15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .doublyAugmented)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func doublyDiminished_sizes() {
        let entries: [(Interval, Int)] = [(.doublyDiminished2, 2),
                                          (.doublyDiminished3, 3),
                                          (.doublyDiminished4, 4),
                                          (.doublyDiminished5, 5),
                                          (.doublyDiminished6, 6),
                                          (.doublyDiminished7, 7),
                                          (.doublyDiminished8, 8),
                                          (.doublyDiminished9, 9),
                                          (.doublyDiminished10, 10),
                                          (.doublyDiminished11, 11),
                                          (.doublyDiminished12, 12),
                                          (.doublyDiminished13, 13),
                                          (.doublyDiminished14, 14),
                                          (.doublyDiminished15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .doublyDiminished)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func major_sizes() {
        let entries: [(Interval, Int)] = [(.major2, 2),
                                          (.major3, 3),
                                          (.major6, 6),
                                          (.major7, 7),
                                          (.major9, 9),
                                          (.major10, 10),
                                          (.major13, 13),
                                          (.major14, 14)]

        for (interval, size) in entries {
            #expect(interval.quality == .major)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func minor_sizes() {
        let entries: [(Interval, Int)] = [(.minor2, 2),
                                          (.minor3, 3),
                                          (.minor6, 6),
                                          (.minor7, 7),
                                          (.minor9, 9),
                                          (.minor10, 10),
                                          (.minor13, 13),
                                          (.minor14, 14)]

        for (interval, size) in entries {
            #expect(interval.quality == .minor)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func perfect_sizes() {
        let entries: [(Interval, Int)] = [(.perfect1, 1),
                                          (.perfect4, 4),
                                          (.perfect5, 5),
                                          (.perfect8, 8),
                                          (.perfect11, 11),
                                          (.perfect12, 12),
                                          (.perfect15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .perfect)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func quadruplyAugmented_sizes() {
        let entries: [(Interval, Int)] = [(.quadruplyAugmented1, 1),
                                          (.quadruplyAugmented2, 2),
                                          (.quadruplyAugmented3, 3),
                                          (.quadruplyAugmented4, 4),
                                          (.quadruplyAugmented5, 5),
                                          (.quadruplyAugmented6, 6),
                                          (.quadruplyAugmented7, 7),
                                          (.quadruplyAugmented8, 8),
                                          (.quadruplyAugmented9, 9),
                                          (.quadruplyAugmented10, 10),
                                          (.quadruplyAugmented11, 11),
                                          (.quadruplyAugmented12, 12),
                                          (.quadruplyAugmented13, 13),
                                          (.quadruplyAugmented14, 14),
                                          (.quadruplyAugmented15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .quadruplyAugmented)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func quadruplyDiminished_sizes() {
        let entries: [(Interval, Int)] = [(.quadruplyDiminished2, 2),
                                          (.quadruplyDiminished3, 3),
                                          (.quadruplyDiminished4, 4),
                                          (.quadruplyDiminished5, 5),
                                          (.quadruplyDiminished6, 6),
                                          (.quadruplyDiminished7, 7),
                                          (.quadruplyDiminished8, 8),
                                          (.quadruplyDiminished9, 9),
                                          (.quadruplyDiminished10, 10),
                                          (.quadruplyDiminished11, 11),
                                          (.quadruplyDiminished12, 12),
                                          (.quadruplyDiminished13, 13),
                                          (.quadruplyDiminished14, 14),
                                          (.quadruplyDiminished15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .quadruplyDiminished)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func triplyAugmented_sizes() {
        let entries: [(Interval, Int)] = [(.triplyAugmented1, 1),
                                          (.triplyAugmented2, 2),
                                          (.triplyAugmented3, 3),
                                          (.triplyAugmented4, 4),
                                          (.triplyAugmented5, 5),
                                          (.triplyAugmented6, 6),
                                          (.triplyAugmented7, 7),
                                          (.triplyAugmented8, 8),
                                          (.triplyAugmented9, 9),
                                          (.triplyAugmented10, 10),
                                          (.triplyAugmented11, 11),
                                          (.triplyAugmented12, 12),
                                          (.triplyAugmented13, 13),
                                          (.triplyAugmented14, 14),
                                          (.triplyAugmented15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .triplyAugmented)
            #expect(interval.size.intValue == size)
        }
    }

    @Test
    func triplyDiminished_sizes() {
        let entries: [(Interval, Int)] = [(.triplyDiminished2, 2),
                                          (.triplyDiminished3, 3),
                                          (.triplyDiminished4, 4),
                                          (.triplyDiminished5, 5),
                                          (.triplyDiminished6, 6),
                                          (.triplyDiminished7, 7),
                                          (.triplyDiminished8, 8),
                                          (.triplyDiminished9, 9),
                                          (.triplyDiminished10, 10),
                                          (.triplyDiminished11, 11),
                                          (.triplyDiminished12, 12),
                                          (.triplyDiminished13, 13),
                                          (.triplyDiminished14, 14),
                                          (.triplyDiminished15, 15)]

        for (interval, size) in entries {
            #expect(interval.quality == .triplyDiminished)
            #expect(interval.size.intValue == size)
        }
    }
}
