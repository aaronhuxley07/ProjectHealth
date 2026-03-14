//
//  WorkoutSessionViewModel.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//


import SwiftUI
import Combine

@MainActor
final class WorkoutSessionViewModel: ObservableObject {
    
    @Published var session: WorkoutSession?
    
    let manager: WorkoutSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(manager: WorkoutSessionManager) {
        self.manager = manager
        self.session = manager.activeSession
        
        // Observe changes to activeSession
        manager.$activeSession
            .sink { [weak self] session in
                self?.session = session
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func startWorkout() {
        manager.startWorkout()
    }
    
    func finishWorkout() {
        manager.finishWorkout()
    }
    
    func addExercise(_ exercise: ExerciseInfo) {
        manager.addExercise(exercise)
    }
    
    func removeExercise(_ exercise: WorkoutExercise) {
        manager.deleteExercise(exercise)
    }
    
    func addSet(to exercise: WorkoutExercise, reps: Int, weight: Double? = nil) {
        manager.addSet(to: exercise, reps: reps, weight: weight)
    }
    
    func removeSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        manager.deleteSet(set, from: exercise)
    }
}
