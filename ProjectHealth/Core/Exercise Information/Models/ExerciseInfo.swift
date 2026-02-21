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
    var isDeprecated: Bool

    init(
        id: UUID,
        name: String,
        isDeprecated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isDeprecated = isDeprecated
    }
}
