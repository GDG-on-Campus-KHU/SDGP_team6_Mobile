//
//  MockWeeklyViewModel.swift
//  SDGP6
//
//  Created by 박현빈 on 5/6/25.
//

// MockWeeklyViewModel.swift

import Foundation

class MockWeeklyViewModel: ObservableObject {
    @Published var score: Int = 66
    @Published var steps: Int = 11575
    @Published var progress: Double = 0.66 // 0.0 ~ 1.0

    @Published var calories: Int = 608
    @Published var distance: Double = 5.0
    @Published var moveMinutes: Int = 33

    @Published var lastSleep: String = "9h 1m"

    @Published var dailyGoals: [Bool] = [true, false, true, false, true, false, true] // 7일치 성취 여부

    var achievedCount: Int {
        dailyGoals.filter { $0 }.count
    }
}
