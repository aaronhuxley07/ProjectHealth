//
//  JSONHelpers.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 22/02/2026.
//


import Foundation

/// Returns JSON Data for a single exercise
func exerciseJSON(id: String = UUID().uuidString, name: String) -> Data {
    let json = """
    [
      { "id": "\(id)", "name": "\(name)" }
    ]
    """
    return Data(json.utf8)
}

/// Combines multiple single-exercise JSON Data objects into one array
func combineJSON(_ exercises: [Data]) throws -> Data {
    let combined = try exercises.flatMap { data -> [Any] in
        try JSONSerialization.jsonObject(with: data) as! [Any]
    }
    return try JSONSerialization.data(withJSONObject: combined)
}