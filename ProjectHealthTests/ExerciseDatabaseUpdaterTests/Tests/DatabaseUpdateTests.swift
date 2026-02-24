//
//  DatabaseUpdateTests.swift
//  ProjectHealthTests
//
//  Created by Aaron Huxley on 24/02/2026.
//

import Testing
import SwiftData
import SwiftUI
@testable import ProjectHealth

@MainActor
@Suite("Exercise Database Updater – Database Update Tests")
struct DatabaseUpdateTests {
    
    /// Tests that the ExerciseInfoDatabaseUpdater correctly updates an existing exercise
    /// when the JSON changes, without creating duplicates.
    ///
    /// Steps:
    /// 1. Seed the database with an initial exercise.
    /// 2. Update the JSON for the same exercise ID with a new name.
    /// 3. Force the updater to run by resetting the stored version.
    /// 4. Verify that the database contains exactly one exercise,
    ///    the name has been updated, and it is not deprecated.
    @Test
    @MainActor
    func testUpdatesExistingExercise() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        // Initial seed
        let initialJSON = exerciseJSON(id: "11111111-1111-1111-1111-111111111111", name: "Bench Press")
        ExerciseInfoDatabaseUpdater.updateIfNeeded(context: context, jsonData: initialJSON)

        var exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())
        #expect(exercises.count == 1)
        #expect(exercises.first!.name == "Bench Press")

        // JSON update: change name of existing exercise
        let updatedJSON = exerciseJSON(id: "11111111-1111-1111-1111-111111111111", name: "Barbell Bench Press")
        
        // Bump version to force updater
        UserDefaults.standard.set(0, forKey: "exerciseInfoDatabaseVersionKey")

        ExerciseInfoDatabaseUpdater.updateIfNeeded(context: context, jsonData: updatedJSON)

        exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.count == 1) // No duplicates
        #expect(exercises.first!.name == "Barbell Bench Press") // Name updated
        #expect(!exercises.first!.isDeprecated) // Still active
    }
    
    /// Tests that the ExerciseInfoDatabaseUpdater marks exercises as deprecated
    /// if they are not present in the updated JSON.
    ///
    /// Steps:
    /// 1. Seed the database with two exercises.
    /// 2. Provide an updated JSON containing only one of the exercises.
    /// 3. Force the updater to run by resetting the stored version.
    /// 4. Verify that the missing exercise is marked as deprecated,
    ///    and the remaining exercise stays active.
    @Test
    @MainActor
    func testDeprecatesRemovedExercise() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        // Initial seed: two exercises
        let exercise1JSON = exerciseJSON(id: "11111111-1111-1111-1111-111111111111", name: "Bench Press")
        let exercise2JSON = exerciseJSON(id: "22222222-2222-2222-2222-222222222222", name: "Squat")
        let initialJSON = try combineJSON([exercise1JSON, exercise2JSON])
        ExerciseInfoDatabaseUpdater.updateIfNeeded(context: context, jsonData: initialJSON)

        var exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())
        #expect(exercises.count == 2)
        #expect(exercises.allSatisfy { !$0.isDeprecated })

        // Updated JSON: remove Squat (exercise2)
        let updatedJSON = exerciseJSON(id: "11111111-1111-1111-1111-111111111111", name: "Bench Press")
        
        // Force updater to run
        UserDefaults.standard.set(0, forKey: "exerciseInfoDatabaseVersionKey")
        ExerciseInfoDatabaseUpdater.updateIfNeeded(context: context, jsonData: updatedJSON)

        exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.contains { $0.id.uuidString == "11111111-1111-1111-1111-111111111111" })
        #expect(exercises.contains { $0.id.uuidString == "22222222-2222-2222-2222-222222222222" })
        
        guard let bench = exercises.first(where: { $0.id.uuidString == "11111111-1111-1111-1111-111111111111" }),
              let squat = exercises.first(where: { $0.id.uuidString == "22222222-2222-2222-2222-222222222222" }) else {
            return
        }

        #expect(!bench.isDeprecated) // Bench Press remains active
        #expect(squat.isDeprecated)  // Squat is deprecated
    }
}
