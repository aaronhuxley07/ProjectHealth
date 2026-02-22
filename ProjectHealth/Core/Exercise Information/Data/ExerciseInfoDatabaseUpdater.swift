//
//  ExerciseInfoDatabaseUpdater.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 21/02/2026.
//

import Foundation
import SwiftData

/// Handles seeding or updating the ExerciseInfo database from a JSON file.
struct ExerciseInfoDatabaseUpdater {
    
    /// Latest version number of exercises.json.
    /// Increment this whenever the JSON file changes
    private static let latestJSONVersion: Int = 1

    /// UserDefaults key storing the last exercises.json version that was applied to the database.
    private static let storedVersionKey = "exerciseInfoDatabaseVersionKey"
    
    /// Seeds or updates the database if the JSON version has increased.
    ///
    /// - Parameters:
    ///   - context: The SwiftData `ModelContext` used to perform inserts and updates.
    ///   - jsonData: Optional JSON data for testing purposes. If nil, the seeder loads `exercises.json` from the app bundle.
    @MainActor
    static func updateIfNeeded(context: ModelContext, jsonData: Data? = nil) {
        guard databaseNeedsUpdate() else { return }
        
        guard let dtos = loadExerciseDTOs(from: jsonData) else { return }
        
        updateDatabase(dtos: dtos, context: context)
        
        updateStoredVersionKey()
    }
}

// MARK: - Helpers

extension ExerciseInfoDatabaseUpdater {
    
    /// Determines whether the database needs updating by comparing the stored version to the latest JSON version.
    ///
    /// - Returns: `true` if the database is outdated, `false` otherwise.
    private static func databaseNeedsUpdate() -> Bool {
        let lastUpdated = UserDefaults.standard.integer(forKey: storedVersionKey)
        return lastUpdated < latestJSONVersion
    }
    
    /// Loads and decodes the JSON data into `ExerciseInfoDTO` objects.
    ///
    /// - Parameter jsonData: Optional JSON data. If nil, loads from the app bundle.
    /// - Returns: An array of `ExerciseInfoDTO` objects, or nil if decoding fails.
    private static func loadExerciseDTOs(from jsonData: Data?) -> [ExerciseInfoDTO]? {
        let data: Data
        if let jsonData {
            data = jsonData
        } else if
            let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
            let bundleData = try? Data(contentsOf: url) {
            data = bundleData
        } else {
            fatalError("❌ Failed to load exercises.json")
        }

        do {
            return try JSONDecoder().decode([ExerciseInfoDTO].self, from: data)
        } catch {
            print("❌ Failed to decode JSON: \(error)")
            return nil
        }
    }
    
    /// Applies the seed data to the database by inserting new exercises or updating existing ones.
    ///
    /// - Parameters:
    ///   - dtos: Array of decoded `ExerciseInfoDTO` objects from JSON.
    ///   - context: The SwiftData `ModelContext` used for database operations.
    private static func updateDatabase(dtos: [ExerciseInfoDTO], context: ModelContext) {
        let existingExercises = (try? context.fetch(FetchDescriptor<ExerciseInfo>())) ?? []
        let existingByID = Dictionary(uniqueKeysWithValues: existingExercises.map { ($0.id, $0) })
        var jsonIDs = Set<UUID>()

        for dto in dtos {
            guard let uuid = UUID(uuidString: dto.id) else { continue }
            jsonIDs.insert(uuid)

            if let existing = existingByID[uuid] {
                updateExisting(existing, with: dto)
            } else {
                insertNew(dto, context: context)
            }
        }

        // Mark missing exercises as deprecated
        for exercise in existingExercises where !jsonIDs.contains(exercise.id) {
            exercise.isDeprecated = true
        }
    }
    
    /// Updates an existing ExerciseInfo object with data from a DTO.
    ///
    /// - Parameters:
    ///   - existing: The existing `ExerciseInfo` object in the database.
    ///   - dto: The `ExerciseInfoDTO` containing updated information.
    private static func updateExisting(_ existing: ExerciseInfo, with dto: ExerciseInfoDTO) {
        existing.name = dto.name
        existing.isDeprecated = false
    }

    /// Inserts a new ExerciseInfo object into the database.
    ///
    /// - Parameters:
    ///   - dto: The `ExerciseInfoDTO` to insert.
    ///   - context: The SwiftData `ModelContext` used for database operations.
    private static func insertNew(_ dto: ExerciseInfoDTO, context: ModelContext) {
        guard let uuid = UUID(uuidString: dto.id) else { return }
        let newExercise = ExerciseInfo(
            id: uuid,
            name: dto.name,
            isDeprecated: false
        )
        context.insert(newExercise)
    }

    /// Updates the stored JSON version in UserDefaults to reflect the latest applied version.
    private static func updateStoredVersionKey() {
        UserDefaults.standard.set(latestJSONVersion, forKey: storedVersionKey)
    }
}
