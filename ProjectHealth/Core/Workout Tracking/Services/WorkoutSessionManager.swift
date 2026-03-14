//
//  WorkoutSessionManager.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class WorkoutSessionManager: ObservableObject {

    @Published private(set) var activeSession: WorkoutSession?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Start Workout
    
    func startWorkout() {
        guard activeSession == nil else { return }
        activeSession = WorkoutSession()
    }
    
    // MARK: - Finish Workout

    func finishWorkout() {
        guard let session = activeSession else { return }
        session.endDate = .now
        context.insert(session)
        activeSession = nil
    }
    
    // MARK: - Add Exercise
    
    func addExercise(_ exerciseInfo: ExerciseInfo) {
        guard let session = activeSession else { return }
        let order = session.exercises.count
        let workoutExercise = WorkoutExercise(exerciseInfo: exerciseInfo, order: order)
        session.exercises.append(workoutExercise)
    }

    // MARK: - Delete Exercise

    func deleteExercise(_ exercise: WorkoutExercise) {
        guard let session = activeSession else { return }
        if let index = session.exercises.firstIndex(where: { $0.id == exercise.id }) {
            session.exercises.remove(at: index)
            // Reorder remaining exercises
            for (i, ex) in session.exercises.enumerated() {
                ex.order = i
            }
        }
    }

    // MARK: - Add Set

    func addSet(to exercise: WorkoutExercise, reps: Int, weight: Double? = nil) {
        guard let session = activeSession else { return }
        let order = session.exercises.count
        let workoutSet = WorkoutSet(reps: reps, weight: weight, order: order)
        exercise.sets.append(workoutSet)
    }
    
    // MARK: - Delete Set

    func deleteSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            exercise.sets.remove(at: index)
            // Reorder remaining sets
            for (i, s) in exercise.sets.enumerated() {
                s.order = i
            }
        }
    }
}
