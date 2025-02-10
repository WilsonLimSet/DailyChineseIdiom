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
    @State private var showCopiedToast = false
    @Environment(\.scenePhase) private var scenePhase
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var shareText: String {
        ShareUtils.formatShareText(idiom: currentIdiom, date: Date(), dateFormatter: dateFormatter)
    }
    
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
                        Text("Example Applicable Situation")
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
                HStack(spacing: 16) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    
                    Menu {
                        Button(action: {
                            ShareUtils.copyToClipboard(text: shareText) { showing in
                                showCopiedToast = showing
                            }
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            ShareUtils.presentShareSheet(text: shareText)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: HelpView()) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if showCopiedToast {
                CopyToastView()
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
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
