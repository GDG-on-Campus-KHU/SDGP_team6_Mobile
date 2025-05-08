//
//  AuthenticationView.swift
//  SDGP6
//
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        switch authViewModel.authenticationState {
        case .unauthenticated:
            LoginIntroView()
                .environmentObject(authViewModel)
        case .authenticated:
            MainTabView()
        }
    }
}

#Preview {
    AuthenticationView(authViewModel: .init(container: .init(services: StubService())))
}
