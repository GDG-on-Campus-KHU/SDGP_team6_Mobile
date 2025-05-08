//
//  MainTabView.swift
//  SDGP6
//
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTabType = .home
    
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
        
        TabView(selection: $selectedTab) {
            UserHomeView()
                .tabItem {
                    Image(
                        tabBarViewModel.selectedTab == .userHome
                        ? "ic_home_black"
                        : "ic_home_gray")
                }
                .tag(Tab.userHome)
            
            StudyHomeView()
                .tabItem {
                    Image(
                        tabBarViewModel.selectedTab == .studyHome
                        ? "ic_cal_black"
                        : "ic_cal_gray")
                }
                .tag(Tab.studyHome)
        }
    }
}

#Preview {
    MainTabView()
}
