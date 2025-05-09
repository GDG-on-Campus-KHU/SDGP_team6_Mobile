//
//  AuthenticationService.swift
//  SDGP6
//
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

enum AuthenticationError: Error {
    case clientIDError
    case tokenError
    case invalidated
    case networkError
    case invalidCredentials
    case parsingError
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

protocol AuthenticationServiceType {
    func signInWithGoogle() -> AnyPublisher<User, ServiceError>
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError>
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError>
    func refreshToken() -> AnyPublisher<Bool, ServiceError>
    func logout() -> AnyPublisher<Bool, ServiceError>
}

class AuthenticationService: AuthenticationServiceType {
    private let baseURL = "https://carbon-api-305709153081.us-central1.run.app"
    
    // Google 로그인 메서드
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.singInWithGoogle { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Email 로그인 메서드
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.loginWithEmail(email: email, password: password) { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Email 회원가입 메서드
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.signupWithEmail(email: email, password: password) { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 토큰 갱신 메서드
    func refreshToken() -> AnyPublisher<Bool, ServiceError> {
        Future { [weak self] promise in
            self?.refreshAuthToken { result in
                switch result {
                case let .success(success):
                    promise(.success(success))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 로그아웃 메서드
    func logout() -> AnyPublisher<Bool, ServiceError> {
        Future { [weak self] promise in
            self?.logoutUser { result in
                switch result {
                case let .success(success):
                    promise(.success(success))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension AuthenticationService {
    // Google 로그인 기능
    private func singInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticationError.clientIDError))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error{
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Google Login 완료 시 호출
            self?.authenticatedUserFirebase(credential: credential, completion: completion)
        }
    }
    
    // Firebase 인증 기능
    private func authenticatedUserFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let result else {
                completion(.failure(AuthenticationError.invalidated))
                return
            }
            
            let firebaseUser = result.user
            let user: User = .init(id: firebaseUser.uid,
                                   name: firebaseUser.displayName ?? "",
                                   phoneNumber: firebaseUser.phoneNumber,
                                   profileURL: firebaseUser.photoURL?.absoluteString)
            
            completion(.success(user))
        }
    }
    
    // Email 로그인 기능
    private func loginWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(AuthenticationError.networkError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AuthenticationError.networkError))
                return
            }
            
            // 응답 처리
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    // 토큰 저장
                    UserDefaults.standard.set(token, forKey: "authToken")
                    
                    // 사용자 정보 생성
                    let user = User(id: email, name: email.components(separatedBy: "@").first ?? "", phoneNumber: nil, profileURL: nil)
                    completion(.success(user))
                } else {
                    completion(.failure(AuthenticationError.invalidCredentials))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Email 회원가입 기능
    private func signupWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            completion(.failure(AuthenticationError.networkError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AuthenticationError.networkError))
                return
            }
            
            // 응답 처리
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // 토큰 저장
                UserDefaults.standard.set(authResponse.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(authResponse.refreshToken, forKey: "refreshToken")
                let expirationDate = Date(timeIntervalSinceNow: TimeInterval(authResponse.expiresIn))
                UserDefaults.standard.set(expirationDate, forKey: "tokenExpiration")
                
                // 사용자 정보 생성
                let user = User(id: email,
                                name: email.components(separatedBy: "@").first ?? "",
                                phoneNumber: nil,
                                profileURL: nil)
                completion(.success(user))
            } catch {
                completion(.failure(AuthenticationError.parsingError))
            }
        }.resume()
    }
    
    // 토큰 갱신 기능
    private func refreshAuthToken(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken"),
              let url = URL(string: "\(baseURL)/auth/refresh") else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AuthenticationError.networkError))
                return
            }
            
            // 응답 처리
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // 토큰 저장
                UserDefaults.standard.set(authResponse.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(authResponse.refreshToken, forKey: "refreshToken")
                let expirationDate = Date(timeIntervalSinceNow: TimeInterval(authResponse.expiresIn))
                UserDefaults.standard.set(expirationDate, forKey: "tokenExpiration")
                
                completion(.success(true))
            } catch {
                completion(.failure(AuthenticationError.parsingError))
            }
        }.resume()
    }
    
    // 로그아웃 기능
    private func logoutUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/logout"),
              let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 토큰 삭제
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "tokenExpiration")
            
            completion(.success(true))
        }.resume()
    }
}

class StubAuthenticationService: AuthenticationServiceType {
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<Bool, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Bool, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
