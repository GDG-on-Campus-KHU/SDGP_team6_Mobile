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
    let category: String?         // optional로 변경
    let carbonScore: Int?         // optional로 변경
    let userId: String

    enum CodingKeys: String, CodingKey {
        case id = "TransactionID"
        case type = "TransactionType"
        case accountId = "BankAccountID"
        case accountNumber = "BankAccountNumber"
        case bankCode = "BankCode"
        case amount = "Amount"
        case date = "TransactionDate"
        case name = "TransactionName"
        case category = "Category"
        case carbonScore = "CarbonScore"
        case userId = "UserID"
    }
}

struct TransactionListResponse: Codable {
    let status: Int
    let result: [Transaction]
}

struct TransactionCreateRequest: Codable {
    let transactionType: String
    let bankAccountId: String
    let bankAccountNumber: String
    let bankCode: String
    let amount: Int
    let transactionDate: Date
    let transactionName: String
    let userId: String // ✅

    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_type"
        case bankAccountId = "bank_account_id"
        case bankAccountNumber = "bank_account_number"
        case bankCode = "bank_code"
        case amount
        case transactionDate = "transaction_date"
        case transactionName = "transaction_name"
        case userId = "user_id"
    }
}



@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let baseURL = "https://carbon-api-305709153081.us-central1.run.app"

    func fetchTransactions(userId: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions/list?user_id=system") else { return }
        await request(url: url, method: "GET", token: token) { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 응답 데이터:\n\(raw)")
            }


            do {
                // 먼저 status만 확인하기 위한 임시 구조체
                struct BasicStatus: Codable {
                    let status: Int
                    let message: String?
                }

                let basic = try decoder.decode(BasicStatus.self, from: data)

                guard basic.status == 200 else {
                    self.errorMessage = basic.message ?? "오류 발생"
                    print("⚠️ 서버 응답 오류: \(basic.status) \(basic.message ?? "")")
                    return
                }

                // status가 200일 때만 전체 응답 디코딩
                let decoded = try decoder.decode(TransactionListResponse.self, from: data)
                self.transactions = decoded.result

            } catch {
                self.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                print("❌ 디코딩 실패: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 원본 응답 데이터:\n\(raw)")
                }
            }
        }
        //print("📥 거래 목록 불러오기: userId = \(userId)")
        
    }


    func fetchTransaction(by id: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions?transaction_id=\(id)") else { return }
        await request(url: url, method: "GET", token: token) { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let decoded = try decoder.decode(TransactionListResponse.self, from: data)
                self.transactions = decoded.result
            } catch {
                self.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                print("❌ 디코딩 실패: \(error)")
            }
        }
    }

    func createTransaction(
        type: String,
        accountId: String,
        accountNumber: String,
        bankCode: String,
        amount: Int,
        date: Date,
        name: String,
        userId: String,
        token: String
    ) async {
        guard let url = URL(string: "\(baseURL)/transactions/import") else { return }

        let requestBody = TransactionCreateRequest(
            transactionType: type,
            bankAccountId: accountId,
            bankAccountNumber: accountNumber,
            bankCode: bankCode,
            amount: amount,
            transactionDate: date,
            transactionName: name,
            userId: userId
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let body = try? encoder.encode(requestBody) else {
            self.errorMessage = "요청 인코딩 실패"
            return
        }

        // 디버깅용 출력
        if let json = String(data: body, encoding: .utf8) {
            print("📦 보내는 JSON:\n\(json)")
        }

        await request(url: url, method: "POST", token: token, body: body) { data in
            struct CreateResponse: Codable {
                let status: Int
                let message: String
                let error: String
            }

            do {
                let decoded = try JSONDecoder().decode(CreateResponse.self, from: data)
                print("✅ 생성 결과: \(decoded.status) - \(decoded.message)")

                if decoded.status == 200 {
                    // ✅ 성공했으면 바로 거래 리스트 새로고침
                    await self.fetchTransactions(userId: userId, token: token)
                } else {
                    self.errorMessage = decoded.message
                }
            } catch {
                self.errorMessage = "응답 디코딩 실패: \(error.localizedDescription)"
                print("❌ 응답 디코딩 실패: \(error)")
            }
        }
    }




    func deleteTransaction(id: String, token: String) async {
        guard let url = URL(string: "\(baseURL)/transactions/\(id)") else { return }
        await request(url: url, method: "DELETE", token: token) { _ in }
    }

    private func request(
        url: URL,
        method: String,
        token: String,
        body: Data? = nil,
        handle: @escaping (Data) async throws -> Void // ✅ 수정!
    ) async {
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
            try await handle(data) // ✅ 여기서 await 필요
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ 요청 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

}

