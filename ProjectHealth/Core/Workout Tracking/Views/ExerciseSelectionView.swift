//
//  ExerciseSelectionView.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//


import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutManager: WorkoutSessionManager
    
    @Query(sort: \ExerciseInfo.name)
    private var allExercises: [ExerciseInfo]
    
    @State private var selectedExercises: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            List(allExercises, id: \.id, selection: $selectedExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    if selectedExercises.contains(exercise.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(exercise)
                }
            }
            .navigationTitle("Select Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addSelectedExercises() }
                        .disabled(selectedExercises.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleSelection(_ exercise: ExerciseInfo) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }
    
    private func addSelectedExercises() {
        for exerciseID in selectedExercises {
            if let exercise = allExercises.first(where: { $0.id == exerciseID }) {
                workoutManager.addExercise(exercise)
            }
        }
        dismiss()
    }
}
