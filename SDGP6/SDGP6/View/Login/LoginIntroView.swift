//
//  LoginIntroView.swift
//  SDGP6
//
//

import SwiftUI

struct LoginIntroView: View {
    @State private var isPresentedLoginView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("나의 탄소 배출량을 알아볼까요?")
                    .font(.system(size: 26, weight: .bold))
                Text("더 알아보려면 아래 버튼을 눌러보아요.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button {
                    isPresentedLoginView.toggle()
                } label: {
                    Text("로그인")
                }
                .buttonStyle(LoginButtonStyle(textColor: .teal))
                .padding(.bottom,  30)

            }
            .navigationDestination(isPresented: $isPresentedLoginView) {
                LoginView()
            }
        }
    }
}

#Preview {
    LoginIntroView()
}
