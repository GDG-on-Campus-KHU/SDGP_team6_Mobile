//
//  LoginView.swift
//  SDGP6
//
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
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
            
            Spacer()
            
            VStack {
                Button {
                    //TODO: 이메일로 로그인
                } label: {
                    Text("이메일로 로그인")
                }.buttonStyle(LoginButtonStyle(textColor: .teal))
                
                Button {
                    authViewModel.send(action: .googleLogin)
                } label: {
                    Text("Google로 로그인")
                }
                .buttonStyle(LoginButtonStyle(textColor: .black, borderColor: .gray))
            }
            .padding(.bottom,  30)
        }
    }
}

#Preview {
    LoginView()
}
