//
//  MathAppApp.swift
//  MathApp
//
//  Created by Nurislam Yerkinuly on 05.12.2025.
//

import SwiftUI

@main
struct MathAppApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
