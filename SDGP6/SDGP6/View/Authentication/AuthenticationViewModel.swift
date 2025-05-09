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
        case emailLogin(email: String, password: String)
        case emailSignup(email: String, password: String)
        case logout
    }
    
    @Published var authenticationState: AuthenticaionState = .unauthenticated
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var userID: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        
        // 저장된 토큰이 있으면 자동 로그인
        if let expirationDate = UserDefaults.standard.object(forKey: "tokenExpiration") as? Date,
           let _ = UserDefaults.standard.string(forKey: "accessToken"),
           expirationDate > Date() {
            self.authenticationState = .authenticated
        } else if let _ = UserDefaults.standard.string(forKey: "refreshToken") {
            // 토큰이 만료되었지만 refresh 토큰이 있으면 갱신 시도
            refreshToken()
        }
    }
    
    private func refreshToken() {
        isLoading = true
        container.services.authService.refreshToken()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "토큰 갱신 실패: \(error.localizedDescription)"
                    self?.authenticationState = .unauthenticated
                }
            } receiveValue: { [weak self] success in
                self?.isLoading = false
                if success {
                    self?.authenticationState = .authenticated
                } else {
                    self?.authenticationState = .unauthenticated
                }
            }.store(in: &subscriptions)
    }
    
    func send(action: Action) {
        isLoading = true
        errorMessage = nil
        
        switch action {
        case .googleLogin:
            container.services.authService.signInWithGoogle()
                .sink { completion in
                    // 실패했을 때
                } receiveValue: { [weak self] user in
                    self?.userID = user.id
                }.store(in: &subscriptions)
            
        case let .emailLogin(email, password):
            container.services.authService.signInWithEmail(email: email, password: password)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = "로그인 실패: \(error.localizedDescription)"
                    }
                } receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userID = user.id
                    self?.authenticationState = .authenticated
                }.store(in: &subscriptions)
            
        case let .emailSignup(email, password):
            container.services.authService.signUpWithEmail(email: email, password: password)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = "회원가입 실패: \(error.localizedDescription)"
                    }
                } receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userID = user.id
                    self?.authenticationState = .authenticated
                }.store(in: &subscriptions)
            
        case .logout:
            container.services.authService.logout()
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = "로그아웃 실패: \(error.localizedDescription)"
                    }
                } receiveValue: { [weak self] success in
                    self?.isLoading = false
                    if success {
                        self?.authenticationState = .unauthenticated
                        self?.userID = nil
                    }
                }.store(in: &subscriptions)
        }
    }
    //
    //    func logout() {
    //        UserDefaults.standard.removeObject(forKey: "authToken")
    //        self.authenticationState = .unauthenticated
    //    }
}
