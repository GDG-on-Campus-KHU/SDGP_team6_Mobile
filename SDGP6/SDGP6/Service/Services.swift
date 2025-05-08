//
//  Services.swift
//  SDGP6
//
//

import Foundation

protocol ServiceType {
    var authService: AuthenticationServiceType { get set}
}

class Services: ServiceType {
    var authService: any AuthenticationServiceType
    
    init() {
        self.authService = AuthenticationService()
    }
}

class StubService: ServiceType {
    var authService: any AuthenticationServiceType = StubAuthenticationService()
}
