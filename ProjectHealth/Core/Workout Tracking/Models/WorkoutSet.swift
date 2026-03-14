//
//  WorkoutSet.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class WorkoutSet {

    var id: UUID

    var reps: Int
    var weight: Double?

    var order: Int

    init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double? = nil,
        order: Int
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.order = order
    }
}
