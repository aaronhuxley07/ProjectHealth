//
//  TestContainer.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 22/02/2026.
//

import SwiftData
@testable import ProjectHealth

/// Creates an in-memory container for testing ExerciseInfo database updates
@MainActor
func makeInMemoryContainer(
    models: [any PersistentModel.Type] = [ExerciseInfo.self]
) throws -> ModelContainer {

    let schema = Schema(models)

    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: true
    )

    return try ModelContainer(
        for: schema,
        configurations: [configuration]
    )
}
