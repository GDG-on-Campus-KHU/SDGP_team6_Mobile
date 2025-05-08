//
//  MainTabView.swift
//  SDGP6
//
//

import SwiftUI

struct MainTabView: View {
//    @State private var selectedTab: MainTabType = .home
    @StateObject private var tabBarViewModel = TabBarViewModel()
    
    var body: some View {
//        TabView(selection: $selectedTab) {
//            ForEach(MainTabType.allCases, id: \.self) { tab in
//                Group {
//                    switch tab {
//                    case .home:
//                        HomeView()
//                    case .activity:
//                        ActivityView()
//                    case .setting:
//                        Color.blackFix
//                    }
//                }
//            }
//        }
        
        TabView(selection: $tabBarViewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Image(
                        tabBarViewModel.selectedTab == .home
                        ? "ic_home_bk"
                        : "ic_home_gr")
                }
                .tag(MainTabType.home)
            
            ActivityView()
                .tabItem {
                    Image(
                        tabBarViewModel.selectedTab == .activity
                        ? "ic_activity_bk"
                        : "ic_activity_gr")
                }
                .tag(MainTabType.activity)
        }
    }
}

#Preview {
    MainTabView()
}
