//
//  KUHealthcareApp.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 21/04/2025.
//

import SwiftUI

@main
struct KUHealthcareApp: App {
    @State private var showImmersive = false

    var body: some Scene {
        // This is needed for launch
        WindowGroup {
            EmptyView()
                .onAppear {
                    // Automatically launch immersive login screen
                    showImmersive = true
                }
                .sheet(isPresented: $showImmersive) {
                    LoginView() // Your immersive login UI
                }
        }
    }
}
