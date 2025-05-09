import SwiftUI

struct DailyView: View {
    @StateObject private var viewModel = DailyViewModel()

    @State private var newCategory: String = ""

    // 실제 서버 연동 시 외부에서 주입 필요
    let transactionId: String = "your_transaction_id"
    let token: String = "your_bearer_token"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("🍀 탄소 발자국 측정")
                    .font(.title2)
                    .bold()

                // MARK: - 원형 시각화
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(viewModel.figurePercent), 1.0))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    VStack {
                        Text("\(viewModel.carbonFigure)g")
                            .font(.title)
                            .bold()
                        Text("절감량")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text("카테고리: \(viewModel.category)")
                    .font(.headline)

                // MARK: - 카테고리 수정 입력
                VStack(spacing: 10) {
                    TextField("새 카테고리 입력", text: $newCategory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button("카테고리 수정") {
                        Task {
                            await viewModel.updateCategory(transactionId: transactionId, category: newCategory, token: token)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    if !viewModel.editMessage.isEmpty {
                        Text(viewModel.editMessage)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear {
                Task {
                    await viewModel.loadCarbonData(payer: "생생직판장", amount: "140,000원")
                }
            }
        }
        .navigationTitle("Daily Summary")
    }
}

#Preview {
    DailyView()
}
