//
//  WorkoutExercise.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class WorkoutExercise {

    var id: UUID

    @Relationship
    var exerciseInfo: ExerciseInfo

    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet] = []

    var order: Int

    init(
        id: UUID = UUID(),
        exerciseInfo: ExerciseInfo,
        order: Int
    ) {
        self.id = id
        self.exerciseInfo = exerciseInfo
        self.order = order
    }
}
