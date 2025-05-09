// DailyView.swift - 실제 API 연동 기반
/*
import SwiftUI

struct CategorizeRequest: Codable {
    let payerName: String
    let amount: String
}

struct CategorizeResponse: Codable {
    let category: String
    let figure: Int
}

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
}

@MainActor
class DailyViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var carbonFigure: Int = 0

    func loadCarbonData(payer: String, amount: String) async {
        do {
            let result = try await CategorizeService.fetchCarbonFigure(payerName: payer, amount: amount)
            self.category = result.category
            self.carbonFigure = result.figure
        } catch {
            print("API 호출 실패: \(error)")
        }
    }
}

struct DailyView: View {
    @StateObject private var viewModel = DailyViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("🍀 탄소 발자국 측정")
                .font(.title2)
                .bold()

            Text("카테고리: \(viewModel.category)")
                .font(.headline)
            Text("탄소 수치: \(viewModel.carbonFigure)g CO₂")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadCarbonData(payer: "생생직판장", amount: "140,000원")
            }
        }
        .navigationTitle("Daily Summary")
    }
}

#Preview {
    DailyView()
}
*/

