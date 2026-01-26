//
//  danroloPokedexWidgetLiveActivity.swift
//  danroloPokedexWidget
//
//  Created by daniel.a.robles on 23/01/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct danroloPokedexWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct danroloPokedexWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: danroloPokedexWidgetAttributes.self) { context in
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

extension danroloPokedexWidgetAttributes {
    fileprivate static var preview: danroloPokedexWidgetAttributes {
        danroloPokedexWidgetAttributes(name: "World")
    }
}

extension danroloPokedexWidgetAttributes.ContentState {
    fileprivate static var smiley: danroloPokedexWidgetAttributes.ContentState {
        danroloPokedexWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: danroloPokedexWidgetAttributes.ContentState {
         danroloPokedexWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: danroloPokedexWidgetAttributes.preview) {
   danroloPokedexWidgetLiveActivity()
} contentStates: {
    danroloPokedexWidgetAttributes.ContentState.smiley
    danroloPokedexWidgetAttributes.ContentState.starEyes
}
