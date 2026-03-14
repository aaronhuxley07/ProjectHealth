//
//  WorkoutSessionView.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//


import SwiftUI

struct WorkoutSessionView: View {
    
    @ObservedObject var viewModel: WorkoutSessionViewModel
    @State private var showExerciseSelector = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let session = viewModel.session {
                    List {
                        ForEach(session.exercises, id: \.id) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.exerciseInfo.name)
                                    .font(.headline)
                                
                                ForEach(exercise.sets, id: \.id) { set in
                                    Text("Reps: \(set.reps)  Weight: \(set.weight ?? 0, specifier: "%.1f") kg")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete { indices in
                            for index in indices {
                                viewModel.removeExercise(session.exercises[index])
                            }
                        }
                    }
                } else {
                    Text("No active workout")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    Button(viewModel.session == nil ? "Start Workout" : "Finish Workout") {
                        if viewModel.session == nil {
                            viewModel.startWorkout()
                        } else {
                            viewModel.finishWorkout()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if viewModel.session != nil {
                        Button("Add Exercise") {
                            showExerciseSelector = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Session")
            .fullScreenCover(isPresented: $showExerciseSelector) {
                ExerciseSelectionView(workoutManager: viewModel.manager)
            }
        }
    }
}
