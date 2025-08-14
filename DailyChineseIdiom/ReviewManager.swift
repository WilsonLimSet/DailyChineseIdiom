//
//  ReviewManager.swift
//  DailyChineseIdiom
//
//  Created by Wilson Lim Setiawan on 1/13/25.
//

import SwiftUI
import StoreKit
import UIKit

class ReviewManager: ObservableObject {
    static let shared = ReviewManager()
    
    private let lastReviewPromptDateKey = "lastReviewPromptDate"
    private let appLaunchCountKey = "appLaunchCount"
    private let hasReviewedKey = "hasReviewed"
    
    private let minimumLaunchesBeforeReview = 5
    private let minimumDaysBetweenPrompts = 30
    
    private init() {}
    
    func incrementLaunchCount() {
        let currentCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: appLaunchCountKey)
    }
    
    func shouldRequestReview() -> Bool {
        let launchCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        
        guard launchCount >= minimumLaunchesBeforeReview else {
            return false
        }
        
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastReviewPromptDateKey) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            return daysSinceLastPrompt >= minimumDaysBetweenPrompts
        }
        
        return true
    }
    
    func requestReviewIfAppropriate() {
        guard shouldRequestReview() else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if #available(iOS 18.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    AppStore.requestReview(in: windowScene)
                    UserDefaults.standard.set(Date(), forKey: self.lastReviewPromptDateKey)
                }
            } else {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    UserDefaults.standard.set(Date(), forKey: self.lastReviewPromptDateKey)
                }
            }
        }
    }
    
    func resetReviewPromptDate() {
        UserDefaults.standard.removeObject(forKey: lastReviewPromptDateKey)
    }
    
    // Opens App Store page directly for written reviews
    func openAppStoreForReview() {
        let appID = "6740611324"
        
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}