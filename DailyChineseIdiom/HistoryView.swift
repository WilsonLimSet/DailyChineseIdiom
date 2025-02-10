import SwiftUI

struct HistoryView: View {
    @State private var selectedDate = Date()
    private let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
    @State private var showingFullIdiom = false
    @State private var showingShareSheet = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calendar view
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: startDate...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                let idiom = IdiomProvider.shared.idiomForDate(selectedDate)
                
                // Preview card
                VStack(alignment: .leading, spacing: 12) {
                    // Date header
                    HStack {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    // Main content
                    Text(idiom.characters)
                        .font(.system(size: 36, weight: .bold))
                        .transition(.opacity.combined(with: .scale))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(idiom.pinyin)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(idiom.meaning)
                            .font(.title3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                    
                    Button(action: {
                        withAnimation {
                            showingFullIdiom = true
                        }
                    }) {
                        Text("View Full Details")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: UIColor.systemBackground))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2)
                )
                .padding(.horizontal)
                .animation(.easeInOut, value: selectedDate)
            }
            .padding(.vertical)
        }
        .navigationTitle("Previous Idioms")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFullIdiom) {
            NavigationStack {
                IdiomDetailView(idiom: IdiomProvider.shared.idiomForDate(selectedDate), date: selectedDate)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

struct IdiomDetailView: View {
    let idiom: Idiom
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedToast = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var shareText: String {
        ShareUtils.formatShareText(idiom: idiom, date: date, dateFormatter: dateFormatter)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date header
                HStack {
                    Text(dateFormatter.string(from: date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Main content
                Text(idiom.characters)
                    .font(.system(size: 42, weight: .bold))
                    .transition(.scale)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(idiom.pinyin)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(idiom.meaning)
                        .font(.title3)
                }
                .transition(.move(edge: .leading))
                
                if let example = idiom.example {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Applicable Situation")
                            .font(.headline)
                        
                        if let chineseExample = idiom.chineseExample {
                            Text(chineseExample)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(example)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("History & Meaning")
                        .font(.headline)
                    
                    Text(idiom.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .animation(.easeInOut, value: idiom)
        }
        .navigationTitle("Idiom Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    withAnimation {
                        dismiss()
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
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
} 