//
//  ContentView.swift
//  DailyChineseIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentIdiom: Idiom = IdiomProvider.shared.idiomForDate()
    @State private var isShowingTodaysIdiom: Bool = true
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Today and Year
                HStack {
                    if isShowingTodaysIdiom {
                        Text("TODAY")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                        
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("RANDOM")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(16)
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack(spacing: 12) {
                        if !isShowingTodaysIdiom {
                            Button(action: {
                                currentIdiom = IdiomProvider.shared.idiomForDate()
                                isShowingTodaysIdiom = true
                            }) {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Button(action: {
                            currentIdiom = IdiomProvider.shared.randomIdiom()
                            isShowingTodaysIdiom = false
                        }) {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top)
                
                // Main Characters
                Text(currentIdiom.characters)
                    .font(.system(size: 42, weight: .bold))
                
                // Pinyin and Meaning
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentIdiom.pinyin)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(currentIdiom.meaning)
                        .font(.title3)
                }
                
                // Divider line
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.2))
                
                // Example section
                if let example = currentIdiom.example {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Usage")
                            .font(.headline)
                        
                        if let chineseExample = currentIdiom.chineseExample {
                            Text(chineseExample)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(example)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Description section
                VStack(alignment: .leading, spacing: 12) {
                    Text("History & Meaning")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(currentIdiom.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .long
                    let dateString = dateFormatter.string(from: Date())
                    
                    let shareText = """
                    Daily Chinese Idiom
                    \(dateString)
                    
                    \(currentIdiom.characters)
                    \(currentIdiom.pinyin)
                    \(currentIdiom.meaning)
                    
                    Example:
                    \(currentIdiom.chineseExample ?? "")
                    \(currentIdiom.example ?? "")
                    
                    History & Meaning:
                    \(currentIdiom.description)
                    
                    Learn more at https://www.chineseidioms.com
                    """
                    
                    let activityVC = UIActivityViewController(
                        activityItems: [shareText],
                        applicationActivities: nil
                    )
                    
                    // For iPad support
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        activityVC.popoverPresentationController?.sourceView = rootVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = []
                        rootVC.present(activityVC, animated: true)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Image(systemName: "doc.text")
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && isShowingTodaysIdiom {
                currentIdiom = IdiomProvider.shared.idiomForDate()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
