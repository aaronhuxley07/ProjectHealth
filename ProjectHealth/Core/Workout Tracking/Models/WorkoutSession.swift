//
//  WorkoutSession.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class WorkoutSession {

    var id: UUID
    var startDate: Date
    var endDate: Date?

    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutExercise] = []

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        endDate: Date? = nil,
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
    }
}
