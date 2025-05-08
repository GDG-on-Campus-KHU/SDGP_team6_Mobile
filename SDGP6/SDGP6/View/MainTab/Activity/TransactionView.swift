import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()

    let userId: String = "your_user_id"
    let token: String = "your_bearer_token"

    var body: some View {
        NavigationView {
            //아래 Mock지워야댐
            /*List(viewModel.transactions) { tx in
                VStack(alignment: .leading, spacing: 6) {
                    Text(tx.name)
                        .font(.headline)
                    Text("\(formattedAmount(tx.amount))원")
                        .foregroundColor(.blue)
                    Text("계좌번호: \(tx.accountNumber)")
                        .font(.caption)
                    Text("은행 코드: \(tx.bankCode)")
                        .font(.caption2)
                    Text("날짜: \(formattedDate(tx.date))")
                        .font(.caption2)
                }
            }*/
            VStack {
                // MARK: - 거래 API 버튼
                HStack(spacing: 12) {
                    Button("조회 ID") {
                        Task {
                            await viewModel.fetchTransaction(by: "abc123", token: token)
                        }
                    }

                    Button("생성") {
                        Task {
                            await viewModel.createTransaction(token: token)
                        }
                    }

                    Button("삭제 ID") {
                        Task {
                            await viewModel.deleteTransaction(id: "abc123", token: token)
                        }
                    }
                }
                .padding()

                // MARK: - 상태 표시
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // MARK: - 거래내역 리스트
                    List(viewModel.transactions) { tx in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tx.name)
                                .font(.headline)
                            Text("\(formattedAmount(tx.amount))원")
                                .foregroundColor(.blue)
                            Text("계좌번호: \(tx.accountNumber)")
                                .font(.caption)
                            Text("은행 코드: \(tx.bankCode)")
                                .font(.caption2)
                            Text("날짜: \(formattedDate(tx.date))")
                                .font(.caption2)
                        }
                    }
                }
            }
            .navigationTitle("거래내역")
            .task {
                await viewModel.fetchTransactions(userId: userId, token: token)
            }
        }
    }

    private func formattedAmount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    TransactionView()
}

