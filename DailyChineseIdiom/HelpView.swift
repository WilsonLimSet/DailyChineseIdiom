import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // How to Add Widget Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Add Widget")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        instructionStep(
                            number: "1",
                            title: "Enter edit mode on your home screen",
                            detail: "Long press any empty area on your home screen until edit mode appears"
                        )
                        
                        Image(HelpScreenshots.wigglingApps)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                        
                        instructionStep(
                            number: "2",
                            title: "Tap 'Add Widget' in the top left",
                            detail: "You'll see this option in the menu that appears at the top after tapping 'Edit'"
                        )
                        
                        Image(HelpScreenshots.plusButton)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                        
                        instructionStep(
                            number: "3",
                            title: "Search for 'ChengYu'",
                            detail: "Use the search bar at the top or scroll through the widget list"
                        )
                        
                        Image(HelpScreenshots.widgetSelection)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                        
                        instructionStep(
                            number: "4",
                            title: "Choose your preferred size",
                            detail: "Swipe through the sizes and tap 'Add Widget' when ready"
                        )
                        
                        Image(HelpScreenshots.sizeSelection)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                    }
                }
                
                Divider()
                
                // Widget Sizes section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Available Sizes")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Small")
                            .font(.headline)
                        Text("Shows the idiom characters and pinyin")
                            .foregroundColor(.secondary)
                        
                        Text("Medium")
                            .font(.headline)
                            .padding(.top, 4)
                        Text("Displays characters, pinyin, and meaning")
                            .foregroundColor(.secondary)
                        
                        Text("Large")
                            .font(.headline)
                            .padding(.top, 4)
                        Text("Full experience with characters, pinyin, meaning, and example")
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 16) {
                    Text("About the Content")
                        .font(.title2)
                        .bold()
                    
                    Text("The idioms, translations, and historical explanations in this app are meant to help you learn and appreciate Chinese culture. While we do our best to be accurate, the historical origins and interpretations can vary across different sources and time periods. These should be taken as friendly introductions rather than academic references.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func instructionStep(number: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Text(number)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.blue))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
} 