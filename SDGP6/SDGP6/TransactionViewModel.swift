// TransactionViewModel.swift - 전체 API 대응

import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let type: String
    let accountId: String
    let accountNumber: String
    let bankCode: String
    let amount: Int
    let date: Date
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case type = "transaction_type"
        case accountId = "bank_account_id"
        case accountNumber = "bank_account_number"
        case bankCode = "bank_code"
        case amount
        case date = "transaction_date"
        case name = "transaction_name"
    }
}

struct TransactionListResponse: Codable {
    let status: Int
    let result: [Transaction]
}

struct DefaultResponse: Codable {
    let status: Int
    let message: String
    let error: String?
}

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let baseURL = "https://carbon-api-382694116051.us-central1.run.app"

    func fetchTransactions(userId: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions/list?user_id=\(userId)") else { return }
        await request(url: url, method: "GET", token: token) { (data) in
            let decoded = try JSONDecoder().decode(TransactionListResponse.self, from: data)
            self.transactions = decoded.result
        }
    }

    func fetchTransaction(by id: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions?transaction_id=\(id)") else { return }
        await request(url: url, method: "GET", token: token) { (data) in
            let decoded = try JSONDecoder().decode(TransactionListResponse.self, from: data)
            self.transactions = decoded.result // 단건도 리스트 포맷
        }
    }

    func createTransaction(token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions/import") else { return }

        let newTx = Transaction(
            id: UUID().uuidString,
            type: "deposited",
            accountId: "001",
            accountNumber: "123456789",
            bankCode: "003",
            amount: 10000,
            date: Date(),
            name: "테스트상점"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(newTx) else { return }

        await request(url: url, method: "POST", token: token, body: body) { _ in }
    }

    func deleteTransaction(id: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions/\(id)") else { return }
        await request(url: url, method: "DELETE", token: token) { _ in }
    }

    private func request(url: URL, method: String, token: String, body: Data? = nil, handle: (Data) throws -> Void) async {
        isLoading = true
        errorMessage = nil
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            try handle(data)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
