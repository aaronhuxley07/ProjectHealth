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
    
    @Published var elapsedTime: TimeInterval = 0
    private var timer: AnyCancellable?
    
    init(manager: WorkoutSessionManager) {
        self.manager = manager
        self.session = manager.activeSession
        
        // Observe changes to activeSession
        manager.$activeSession
            .sink { [weak self] session in
                self?.session = session
            }
            .store(in: &cancellables)
        
        updateElapsedTime()
        startTimer()
    }
    
    deinit {
        timer?.cancel()
    }
    
    // MARK: - Timer
       
   private func startTimer() {
       // Fires every second
       timer = Timer.publish(every: 1, on: .main, in: .common)
           .autoconnect()
           .sink { [weak self] _ in
               self?.updateElapsedTime()
           }
   }

    private func updateElapsedTime() {
        guard let start = session?.startDate else {
            elapsedTime = 0
            return
        }
        let end = session?.endDate ?? Date()
        elapsedTime = end.timeIntervalSince(start)
    }
    
    // Formatted time
    var elapsedTimeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
    
    func deleteExercise(_ exercise: WorkoutExercise) {
        manager.deleteExercise(exercise)
    }
    
    func addSet(to exercise: WorkoutExercise, reps: Int, weight: Double? = nil) {
        manager.addSet(to: exercise, reps: reps, weight: weight)
    }
    
    func deleteSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        manager.deleteSet(set, from: exercise)
    }
}
