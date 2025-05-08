//
//  SDGP6App.swift
//  SDGP6
//
//  Created by HanJW on 4/9/25.
//

import SwiftUI

@main
struct SDGP6App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var container: DIContainer = .init(services: Services())
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView(authViewModel: .init(container: container))
                .environmentObject(container)

            AuthenticationView(authViewModel: .init(container: container))
                .environmentObject(container)
            
            TransactionView()
        }
    }
}
