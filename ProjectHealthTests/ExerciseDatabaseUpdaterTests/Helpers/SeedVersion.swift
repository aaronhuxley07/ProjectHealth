//
//  SeedVersion.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 22/02/2026.
//


import Foundation

/// Clears stored JSON version so seeding runs fresh
func resetSeedVersion() {
    UserDefaults.standard.removeObject(forKey: "exerciseInfoDatabaseVersionKey")
}