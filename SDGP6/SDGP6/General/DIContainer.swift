//
//  DIContainer.swift
//  SDGP6
//
//

import SwiftUI

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}
