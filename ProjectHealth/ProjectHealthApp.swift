//
//  ProjectHealthApp.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 21/02/2026.
//

import SwiftUI
import SwiftData

@main
struct ProjectHealthApp: App {
    
    let container: ModelContainer

    init() {
        do {
            // Initialise the container with ExerciseInfo model
            container = try ModelContainer(for: ExerciseInfo.self)
            
            // Seed or update the exercise database from JSON if needed
            ExerciseInfoDatabaseUpdater.updateIfNeeded(context: container.mainContext)
        } catch {
            fatalError("Failed to initialise app: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ExerciseInfoListView()
                .modelContainer(container)
        }
    }
}
