//
//  LoginView.swift
//  SDGP6
//
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showEmailForm = false
    @State private var isSignup = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("로그인")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 80)
                Text("아래 제공되는 서비스로 로그인해주세요.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            
            if showEmailForm {
                emailLoginForm
            }
            
            Spacer()
            
            VStack {
                Button {
                    showEmailForm.toggle()
                } label: {
                    Text(showEmailForm ? "다른 로그인 방법" : "이메일로 로그인")
                }.buttonStyle(LoginButtonStyle(textColor: .teal))
                
                if !showEmailForm {
                    Button {
                        authViewModel.send(action: .googleLogin)
                    } label: {
                        Text("Google로 로그인")
                    }
                    .buttonStyle(LoginButtonStyle(textColor: .black, borderColor: .gray))
                }
            }
            .padding(.bottom, 30)
        }
        .overlay(
            Group {
                if authViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
        )
    }
    
    private var emailLoginForm: some View {
        VStack(spacing: 15) {
            TextField("이메일", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Button {
                authViewModel.send(action: .emailLogin(email: email, password: password))
            } label: {
                Text("로그인")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty)
        }
        .padding(.top, 20)
    }
}
