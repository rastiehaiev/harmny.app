//
//  harmny_appApp.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI

@main
struct harmny_app_Watch_AppApp: App {
    @StateObject var activitiesViewModel = ActivitiesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(activitiesViewModel)
        }
    }
}
