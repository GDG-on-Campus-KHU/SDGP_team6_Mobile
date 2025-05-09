import Foundation

class MockHomeViewModel: ObservableObject {
    @Published var userName: String = "홍길동"
    @Published var totalFasts: Int = 3
    @Published var achievements: Int = 2
    @Published var longestStreak: Int = 4

    @Published var weeklyMessage: String = "이번 주 단식 목표에 도전해보세요!"

    @Published var datesWithReduction: [Date: Bool] = [:] // ✅ 날짜별 탄소 절약 여부

    init() {
        loadMockData()
    }

    func loadMockData() {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                // 3의 배수 날짜만 탄소 절약한 걸로 처리 (mock)
                datesWithReduction[calendar.startOfDay(for: date)] = day % 3 == 0
            }
        }
    }
}

