//
//  AcquireWidget.swift
//  AcquireWidget
//
//  Created by James Sparling on 06/01/2021.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.date, ascending: false)],
        //        sortDescriptors: [],
        animation: .default)
    private var listItems: FetchedResults<ListItem>
    
    func placeholder(in context: Context) -> ShoppingEntry {
        ShoppingEntry(listItems: listItems)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ShoppingEntry) -> Void) {
        let entry = ShoppingEntry(listItems: listItems)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingEntry>) -> Void) {
        let entry = ShoppingEntry(listItems: listItems)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    typealias Entry = ShoppingEntry
}

struct ShoppingEntry: TimelineEntry {
    let date = Date()
    let listItems: FetchedResults<ListItem>
}

struct ListWidgetEntryView : View {
    @Environment(\.managedObjectContext) private var moc
    
    @Environment(\.widgetFamily) var family
    
    //    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .systemLarge:
            ListWidgetView(maxItems: 6)
                .environment(\.managedObjectContext, self.moc)
            
        case .systemMedium:
            ListWidgetView(maxItems: 2)
                .environment(\.managedObjectContext, self.moc)
            
        case .systemSmall:
            ListWidgetView(maxItems: 2)
                .environment(\.managedObjectContext, self.moc)
            
        @unknown default:
            fatalError()
        }
    }
}

struct ListWidget: Widget {
    let kind: String = "ListWidget"
    let persistenceController = PersistenceController.shared
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()) { entry in
            ListWidgetEntryView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("Shopping List Widget")
        .description("Displays shopping list.")
    }
}

struct EmojiWidgetEntryView : View {
    @Environment(\.managedObjectContext) private var moc
    
    @Environment(\.widgetFamily) var family
    
    //    var entry: Provider.Entry
    
    var body: some View {
        switch family {
            case .systemLarge:
                EmojiWidgetView(maxItems: 25, swapCount: 15)
                    .environment(\.managedObjectContext, self.moc)
                
            case .systemMedium:
                EmojiWidgetView(maxItems: 25, swapCount: 15)
                    .environment(\.managedObjectContext, self.moc)
                
            case .systemSmall:
                EmojiWidgetView(maxItems: 25, swapCount: 15)
                    .environment(\.managedObjectContext, self.moc)
                
            @unknown default:
                fatalError()
        }
    }
}

struct EmojiWidget: Widget {
    let kind: String = "EmojiWidget"
    let persistenceController = PersistenceController.shared
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()) { entry in
            EmojiWidgetEntryView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .supportedFamilies([.systemSmall, .systemLarge])
        .configurationDisplayName("Emojis Widget")
        .description("Displays item emojis.")
    }
}

@main
struct AcquireWidgets: WidgetBundle {
    var body: some Widget {
        ListWidget()
        EmojiWidget()
    }
}


struct AcquireWidget_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetEntryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
