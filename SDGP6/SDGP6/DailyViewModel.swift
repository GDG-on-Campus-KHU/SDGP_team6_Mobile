import Foundation

// MARK: - 요청 및 응답 모델
struct CategorizeRequest: Codable {
    let payerName: String
    let amount: String
}

struct CategorizeResponse: Codable {
    let category: String
    let figure: Int
}

struct CategoryUpdateRequest: Codable {
    let category: String
}

// MARK: - API 서비스
class CategorizeService {
    static func fetchCarbonFigure(payerName: String, amount: String) async throws -> CategorizeResponse {
        guard let url = URL(string: "https://ef-server-jaclg44nla-du.a.run.app/categorize") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = CategorizeRequest(payerName: payerName, amount: amount)
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(CategorizeResponse.self, from: data)
    }

    static func updateCategory(transactionId: String, category: String, token: String) async throws -> String {
        guard let url = URL(string: "https://your-server.com/transactions/\(transactionId)/category") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody = CategoryUpdateRequest(category: category)
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        if let response = try? JSONDecoder().decode([String: String].self, from: data),
           let message = response["message"] {
            return message
        } else {
            return "수정 완료"
        }
    }
}

// MARK: - ViewModel
@MainActor
class DailyViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var carbonFigure: Int = 0
    @Published var editMessage: String = ""

    var figurePercent: Double {
        Double(carbonFigure) / 100.0
    }

    func loadCarbonData(payer: String, amount: String) async {
        do {
            let result = try await CategorizeService.fetchCarbonFigure(payerName: payer, amount: amount)
            self.category = result.category
            self.carbonFigure = result.figure
        } catch {
            print("API 호출 실패: \(error)")
        }
    }

    func updateCategory(transactionId: String, category: String, token: String) async {
        do {
            let message = try await CategorizeService.updateCategory(transactionId: transactionId, category: category, token: token)
            self.editMessage = message
        } catch {
            self.editMessage = "수정 실패: \(error.localizedDescription)"
        }
    }
}
