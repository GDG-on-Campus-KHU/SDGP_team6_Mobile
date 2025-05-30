//
//  MainTabType.swift
//  SDGP6
//
//

import Foundation

enum MainTabType: CaseIterable {
    case home
    case activity
    case setting
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .activity:
            return "Activity"
        case .setting:
            return "Setting"
        }
    }
//    
//    func imageName(selected: Bool) -> String {
//        selected ? "\(rawValue)_fill" : rawValue
//    }
}

class TabBarViewModel: ObservableObject {
    @Published var selectedTab: MainTabType
    @Published var homeCount: Int
    @Published var activityCount: Int
    
    init(
        selectedTab: MainTabType = .home,
        homeCount: Int = 0,
        activityCount: Int = 0
    ) {
        self.selectedTab = selectedTab
        self.homeCount = homeCount
        self.activityCount = activityCount
    }
}

extension TabBarViewModel {
    func setHome(_ count: Int) {
        homeCount = count
    }
    
    func setActivity(_ count: Int) {
        activityCount = count
    }
    
    func changeSelectedTab(_ tab: MainTabType) {
        selectedTab = tab
    }
}
