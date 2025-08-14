//
//  DailyChineseIdiomApp.swift
//  DailyChineseIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import SwiftUI

@main
struct DailyChineseIdiomApp: App {
    init() {
        // Initialize IdiomProvider early to catch any loading issues
        _ = IdiomProvider.shared
        
        // Increment launch count for review prompt tracking
        ReviewManager.shared.incrementLaunchCount()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}
