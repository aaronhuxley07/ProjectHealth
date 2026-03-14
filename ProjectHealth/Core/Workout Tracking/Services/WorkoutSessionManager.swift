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
    private let userDefaultsKey = "activeWorkoutSessionID"
    
    init(context: ModelContext) {
        self.context = context
        loadActiveSession()
    }
    
    // MARK: - Start Workout
    
    func startWorkout() {
        guard activeSession == nil else { return }
        
        let session = WorkoutSession()
        context.insert(session)
        try? context.save() // Persist immediately
        activeSession = session
        
        // Store ID for resume
        UserDefaults.standard.set(session.id.uuidString, forKey: userDefaultsKey)
    }
    
    // MARK: - Finish Workout
    
    func finishWorkout() {
        guard let session = activeSession else { return }
        session.endDate = .now
        try? context.save()
        
        activeSession = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    // MARK: - Add / Remove Exercises
    
    func addExercise(_ exerciseInfo: ExerciseInfo) {
        guard let session = activeSession else { return }
        let order = session.exercises.count
        let workoutExercise = WorkoutExercise(exerciseInfo: exerciseInfo, order: order)
        session.exercises.append(workoutExercise)
        try? context.save()
    }
    
    func deleteExercise(_ exercise: WorkoutExercise) {
        guard let session = activeSession else { return }
        session.exercises.removeAll { $0.id == exercise.id }
        try? context.save()
    }
    
    // MARK: - Add / Remove Sets
    
    func addSet(to exercise: WorkoutExercise, reps: Int, weight: Double? = nil) {
        let workoutSet = WorkoutSet(reps: reps, weight: weight, order: exercise.sets.count)
        exercise.sets.append(workoutSet)
        try? context.save()
    }
    
    func deleteSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        exercise.sets.removeAll { $0.id == set.id }
        try? context.save()
    }
    
    // MARK: - Load Active Session
    
    private func loadActiveSession() {
        guard
            let idString = UserDefaults.standard.string(forKey: userDefaultsKey),
            let uuid = UUID(uuidString: idString)
        else { return }
        
        let fetchDescriptor = FetchDescriptor<WorkoutSession>()
        if let session = (try? context.fetch(fetchDescriptor))?.first(where: { $0.id == uuid }),
           session.endDate == nil // Only resume unfinished sessions
        {
            activeSession = session
        }
    }
}
