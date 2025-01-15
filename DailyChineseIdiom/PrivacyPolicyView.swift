import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Last updated: January 13, 2025")
                        .foregroundColor(.secondary)
                    
                    Text("Overview")
                        .font(.headline)
                    Text("Daily Chinese Idiom is a widget and app that displays Chinese idioms. We believe in complete transparency and want you to know that we do not collect, store, or share any personal information.")
                    
                    Text("Information Collection")
                        .font(.headline)
                    Text("Our app:")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Does not collect personal information")
                        Text("• Does not require user registration")
                        Text("• Does not track user activity")
                        Text("• Does not use cookies")
                        Text("• Does not access device location")
                        Text("• Does not require internet access")
                        Text("• Does not store any user data")
                    }
                }
                
                Group {
                    Text("Widget Functionality")
                        .font(.headline)
                    Text("The widget operates completely locally on your device and:")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Only displays pre-loaded Chinese idioms")
                        Text("• Does not transmit any data")
                        Text("• Does not access any device features")
                        Text("• Does not require any permissions")
                    }
                    
                    Text("Changes to Our App")
                        .font(.headline)
                    Text("All idioms and functionality are included in the app installation. Any changes or updates will be made through the App Store update process.")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
} 
