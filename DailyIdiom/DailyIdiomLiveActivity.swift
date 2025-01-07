//
//  DailyIdiomLiveActivity.swift
//  DailyIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DailyIdiomAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DailyIdiomLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DailyIdiomAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DailyIdiomAttributes {
    fileprivate static var preview: DailyIdiomAttributes {
        DailyIdiomAttributes(name: "World")
    }
}

extension DailyIdiomAttributes.ContentState {
    fileprivate static var smiley: DailyIdiomAttributes.ContentState {
        DailyIdiomAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DailyIdiomAttributes.ContentState {
         DailyIdiomAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DailyIdiomAttributes.preview) {
   DailyIdiomLiveActivity()
} contentStates: {
    DailyIdiomAttributes.ContentState.smiley
    DailyIdiomAttributes.ContentState.starEyes
}
