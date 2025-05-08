//
//  AuthenticationViewModel.swift
//  SDGP6
//
//

import Foundation
import Combine

enum AuthenticaionState {
    case unauthenticated
    case authenticated
}

class AuthenticationViewModel: ObservableObject {
    enum Action {
        case googleLogin
    }
    
    @Published var authenticationState: AuthenticaionState = .unauthenticated
    
    var userID: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .googleLogin:
            container.services.authService.signInWithGoogle()
                .sink { completion in
                    // 실패했을 때
                } receiveValue: { [weak self] user in
                    self?.userID = user.id
                }.store(in: &subscriptions)
        }
    }
}
