//
//  MainTabView.swift
//  SDGP6
//
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var mainTabViewModel = MainTabViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView(selection: $mainTabViewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Image(
                        mainTabViewModel.selectedTab == .home
                        ? "ic_home_bk"
                        : "ic_home_gr")
                }
                .tag(MainTabType.home)
            
            TransactionView(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGVzdC11c2VyLTEiLCJleHAiOjE3MDAwMDAwMDB9.abc123signature")
                .tabItem {
                    Image(
                        mainTabViewModel.selectedTab == .activity
                        ? "ic_activity_bk"
                        : "ic_activity_gr")
                }
                .tag(MainTabType.activity)
            
            SettingView()
                .tabItem {
                    Image(
                        mainTabViewModel.selectedTab == .setting
                        ? "ic_setting_bk"
                        : "ic_setting_gr")
                }
                .tag(MainTabType.setting)
        }
    }
}

#Preview {
    MainTabView()
}
