//
//  DatabaseSafetyAndValidationTests.swift
//  ProjectHealthTests
//
//  Created by Aaron Huxley on 24/02/2026.
//

import Testing
import SwiftData
import SwiftUI
@testable import ProjectHealth


@MainActor
@Suite("Exercise Database Updater – Safety & Validation Tests")
struct DatabaseSafetyAndValidationTests {
    
    /// Tests that the updater handles malformed JSON safely without crashing
    /// and does not insert any exercises into the database.
    ///
    /// Steps:
    /// 1. Provide invalid JSON data.
    /// 2. Run the updater.
    /// 3. Verify the database remains empty.
    @Test
    func testMalformedJSONDoesNotCrash() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let malformedJSON = Data("this is not valid json".utf8)

        ExerciseInfoDatabaseUpdater.updateIfNeeded(
            context: context,
            jsonData: malformedJSON
        )

        let exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.isEmpty)
    }
    
    /// Tests that exercises with invalid UUID values are ignored
    /// and not inserted into the database.
    ///
    /// Steps:
    /// 1. Provide JSON containing an invalid UUID.
    /// 2. Run the updater.
    /// 3. Verify no exercises are inserted.
    @Test
    func testInvalidUUIDIsIgnored() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let invalidJSON = Data("""
        [
            { "id": "not-a-uuid", "name": "Bench Press" }
        ]
        """.utf8)

        ExerciseInfoDatabaseUpdater.updateIfNeeded(
            context: context,
            jsonData: invalidJSON
        )

        let exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.isEmpty)
    }
    
    /// Tests that duplicate exercise IDs in JSON do not create
    /// multiple records in the database.
    ///
    /// Steps:
    /// 1. Provide JSON containing two exercises with the same ID.
    /// 2. Run the updater.
    /// 3. Verify only one exercise exists in the database.
    @Test
    func testDuplicateIDsDoNotCreateDuplicates() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let exercise1 = exerciseJSON(
            id: "11111111-1111-1111-1111-111111111111",
            name: "Bench Press"
        )

        let duplicate = exerciseJSON(
            id: "11111111-1111-1111-1111-111111111111",
            name: "Barbell Bench Press"
        )

        let combined = try combineJSON([exercise1, duplicate])

        ExerciseInfoDatabaseUpdater.updateIfNeeded(
            context: context,
            jsonData: combined
        )

        let exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.count == 1)
        #expect(exercises.first!.name == "Barbell Bench Press")
    }
    
    /// Tests that exercises missing required fields are ignored
    /// and not inserted into the database.
    ///
    /// Steps:
    /// 1. Provide JSON entries missing required properties.
    /// 2. Run the updater.
    /// 3. Verify no exercises are inserted.
    @Test
    func testMissingRequiredFieldsAreIgnored() throws {
        resetSeedVersion()

        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let invalidJSON = Data("""
        [
            { "name": "Bench Press" },
            { "id": "11111111-1111-1111-1111-111111111111" }
        ]
        """.utf8)

        ExerciseInfoDatabaseUpdater.updateIfNeeded(
            context: context,
            jsonData: invalidJSON
        )

        let exercises = try context.fetch(FetchDescriptor<ExerciseInfo>())

        #expect(exercises.isEmpty)
    }
}
