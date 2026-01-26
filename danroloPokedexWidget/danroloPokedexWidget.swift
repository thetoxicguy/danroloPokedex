//
//  danroloPokedexWidget.swift
//  danroloPokedexWidget
//
//  Created by daniel.a.robles on 23/01/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry.placeholder
            entries.append(entry)
        }

        let timeline = Timeline (
            entries: entries,
            policy: .atEnd
        )
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
//    let configuration: ConfigurationAppIntent
    let name: String
    let types: [String]
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "bulbasaur",
            types: ["grass", "poison"],
            sprite: Image(.bulbasaur)
        )
    }
    static var placeholder2: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "mew",
            types: ["psychic"],
            sprite: Image(.mew))
    }
}

struct danroloPokedexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry
    
    var pokemonImage: some View { // Image() does not work because the modifiers change it to something more general
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(color: .black, radius: 6)
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) { type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(Color(type.capitalized))
                .clipShape(Capsule())
                .shadow(radius: 3)
        }
    }

    var body: some View {
        switch widgetSize {
        case .systemMedium:
            HStack {
                pokemonImage
                Spacer()
                VStack (alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.title)
                        .padding(.vertical, 1)
                    HStack {
                        typesView
                    }
                }
                .layoutPriority(1) // This gives the VStack priority in the container (the default is 0)
                Spacer()
            }
        case .systemLarge:
            ZStack {
                pokemonImage
                VStack (alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    HStack {
                        Spacer()
                        typesView
                    }
                }
            }
        default: // The small size is applied here
            pokemonImage
        }
    }
}

struct danroloPokedexWidget: Widget {
    let kind: String = "danroloPokedexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                danroloPokedexWidgetEntryView(entry: entry)
                    .foregroundStyle(.black) // The color is black independently of the dark/light mode
                    .containerBackground(
                        Color(entry.types[0].capitalized),
                        for: .widget
                    )
            } else {
                danroloPokedexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Pokémon")
        .description("See a random Pokémon")
    }
}

//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}

#Preview(as: .systemSmall) {
    danroloPokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    danroloPokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    danroloPokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
