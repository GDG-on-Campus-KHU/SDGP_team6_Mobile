//
//  SettingView.swift
//  SDGP6
//
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("계정")) {
                    Button("로그아웃") {
                        authViewModel.send(action: .logout)
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingView()
}
