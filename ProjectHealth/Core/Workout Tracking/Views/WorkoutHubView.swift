//
//  WorkoutHubView.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 14/03/2026.
//

import SwiftData
import SwiftUI

struct WorkoutHubView: View {
    
    @EnvironmentObject var sessionManager: WorkoutSessionManager
    @State private var showWorkoutSession = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Project Health")
                    .font(.largeTitle)
                    .bold()
                
                Button(action: startOrResumeWorkout) {
                    Text(sessionManager.activeSession == nil ? "Start Workout" : "Resume Workout")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationDestination(isPresented: $showWorkoutSession) {
                WorkoutSessionView(viewModel: WorkoutSessionViewModel(manager: sessionManager))
            }
            .onChange(of: sessionManager.activeSession) { _, newValue in
                // Automatically close the workout view when session finishes
                if newValue == nil {
                    showWorkoutSession = false
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func startOrResumeWorkout() {
        if sessionManager.activeSession == nil {
            sessionManager.startWorkout()
        }
        showWorkoutSession = true
    }
}
