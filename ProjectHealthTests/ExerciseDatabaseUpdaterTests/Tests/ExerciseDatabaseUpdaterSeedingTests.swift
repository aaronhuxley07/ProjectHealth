//
//  SeedingBehaviorTests.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 22/02/2026.
//


import Testing
import SwiftData
import SwiftUI
@testable import ProjectHealth


@MainActor
@Suite("Exercise Database Updater – Seeding")
struct ExerciseDatabaseUpdaterSeedingTests {

    /// Verifies that a fresh database is correctly seeded from JSON data.
    ///
    /// Given an empty in-memory store and a reset version key,
    /// when updateIfNeeded is executed,
    /// then all exercises from the JSON are inserted,
    /// marked as active (not deprecated),
    /// and the version key is updated.
    @Test
    func testInitialSeedInsertsExercises() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext
        
        let json1 = exerciseJSON(name: "Bench Press")
        let json2 = exerciseJSON(name: "Squat")
        let combined = try combineJSON([json1, json2])

        ExerciseInfoDatabaseUpdater.updateIfNeeded(context: context, jsonData: combined)

        let exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.count == 2)
        
        let names = exercises.map { $0.name }
        #expect(names.contains("Bench Press"))
        #expect(names.contains("Squat"))

        #expect(exercises.allSatisfy { !$0.isDeprecated })

        let storedVersion = UserDefaults.standard.integer(
            forKey: "exerciseInfoDatabaseVersionKey"
        )
        #expect(storedVersion == 1)
    }
}
