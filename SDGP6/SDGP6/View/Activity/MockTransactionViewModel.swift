//
//  MockTransactionViewModel.swift
//  SDGP6
//
//  Created by 박현빈 on 5/8/25.
//

import Foundation

struct MockTransaction: Identifiable {
    let id = UUID()
    let name: String
    let amount: Int
    let accountNumber: String
    let bankCode: String
    let date: Date
}

class MockTransactionViewModel: ObservableObject {
    @Published var transactions: [MockTransaction] = [
        MockTransaction(name: "점심 식사", amount: 14000, accountNumber: "110-123-456789", bankCode: "088", date: Date()),
        MockTransaction(name: "카페", amount: 5300, accountNumber: "110-987-654321", bankCode: "004", date: Date().addingTimeInterval(-86400)),
        MockTransaction(name: "서점", amount: 27000, accountNumber: "110-111-222333", bankCode: "081", date: Date().addingTimeInterval(-172800))
    ]
}
