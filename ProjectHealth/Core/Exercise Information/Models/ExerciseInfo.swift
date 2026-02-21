//
//  ExerciseInfo.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 21/02/2026.
//

import Foundation
import SwiftData

@Model
final class ExerciseInfo {

    @Attribute(.unique)
    var id: UUID
    
    var name: String

    init(
        id: UUID,
        name: String,
    ) {
        self.id = id
        self.name = name
    }
}
