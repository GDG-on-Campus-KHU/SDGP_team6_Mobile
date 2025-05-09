import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()

    @State private var type: String = "expense"
    @State private var accountId: String = ""
    @State private var accountNumber: String = ""
    @State private var bankCode: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var name: String = ""
    @State private var userId: String = "system"

    @State private var showInputForm: Bool = false // ✅ 입력 폼 표시 여부
    @State private var showDeleteButtons: Bool = false


    let token: String

    var body: some View {
        NavigationView {
            Form {
               
                // 거래내역 리스트
                Section(header: Text("거래내역")) {
                    if viewModel.transactions.isEmpty {
                        Text("거래내역이 없습니다.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.transactions) { tx in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tx.name)
                                        .font(.headline)
                                    Text("₩\(tx.amount) • \(tx.type)")
                                        .font(.subheadline)
                                    Text("날짜: \(formattedDate(tx.date))")
                                        .font(.caption2)
                                }
                                Spacer()
                                if showDeleteButtons {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteTransaction(id: tx.id, token: token)
                                            await viewModel.fetchTransactions(userId: userId, token: token)
                                            showDeleteButtons = false // ✅ 삭제 후 모드 종료
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                }


                
                // 거래내역 생성 버튼 (처음에만 표시됨)
                if !showInputForm && !showDeleteButtons {
                    Section {
                        Button("거래내역 생성하기") {
                            showInputForm = true
                        }
                        Button("거래내역 삭제하기") {
                            showDeleteButtons = true
                        }
                    }
                }


                // 거래 정보 입력 폼 (버튼 누르면 나타남)
                if showInputForm {
                    Section(header: Text("거래 정보 입력")) {
                        TextField("거래 타입 (expense/income)", text: $type)
                        TextField("계좌 ID", text: $accountId)
                        TextField("계좌 번호", text: $accountNumber)
                        TextField("은행 코드", text: $bankCode)
                        TextField("금액", text: $amount)
                            .keyboardType(.numberPad)
                        DatePicker("거래 날짜", selection: $date, displayedComponents: .date)
                        TextField("거래 이름", text: $name)
                        TextField("유저 ID", text: $userId)
                    }

                    Section {
                        Button("생성") {
                            Task {
                                guard let amountInt = Int(amount) else {
                                    viewModel.errorMessage = "금액은 숫자만 입력해주세요."
                                    return
                                }

                                await viewModel.createTransaction(
                                    type: type,
                                    accountId: accountId,
                                    accountNumber: accountNumber,
                                    bankCode: bankCode,
                                    amount: amountInt,
                                    date: date,
                                    name: name,
                                    userId: userId,
                                    token: token
                                )

                                // ✅ 생성 완료 후 폼 숨기기 & 필드 초기화
                                showInputForm = false
                                resetInputFields()
                            }
                        }

                        Button("취소", role: .cancel) {
                            showInputForm = false
                        }
                    }
                    
                }

                // 에러 메시지
                if let error = viewModel.errorMessage {
                    Section {
                        Text("⚠️ \(error)")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("거래 관리")
            .task {
                await viewModel.fetchTransactions(userId: userId, token: token)
            }
        }
    }

    // 금액 포맷
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // 필드 초기화
    private func resetInputFields() {
        type = "expense"
        accountId = ""
        accountNumber = ""
        bankCode = ""
        amount = ""
        date = Date()
        name = ""
    }
}


#Preview {
    TransactionView(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGVzdC11c2VyLTEiLCJleHAiOjE3MDAwMDAwMDB9.abc123signature")

}


