//
//  ExerciseInfoListView.swift
//  ProjectHealth
//
//  Created by Aaron Huxley on 22/02/2026.
//

import SwiftUI
import SwiftData

struct ExerciseInfoListView: View {
    
    @Query(sort: \ExerciseInfo.name)
    private var exerciseInfos: [ExerciseInfo]
    
    var body: some View {
        List {
            ForEach(exerciseInfos, id: \.self) { exercise in
                Text(exercise.name)
            }
        }
    }
}

#Preview {
    ExerciseInfoListView()
}
