//
//  EmojiWidgetView.swift
//  AcquireWidgetExtension
//
//  Created by James Sparling on 07/01/2021.
//

import SwiftUI
import WidgetKit

struct EmojiWidgetView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.date, ascending: false)],
        //        sortDescriptors: [],
        animation: .default)
    private var listItems: FetchedResults<ListItem>
    
    let maxItems: Int
    let swapCount: Int
    var body: some View {
        let count = min(listItems.count, maxItems)
        let rows = Int(Double(count).squareRoot().rounded(.up))
        let range: Range<Int> = 0..<rows
        

        VStack {
            ForEach(range) { row in
                HStack  {
                    ForEach(range) { column in
                        let itemIndex = (row * rows) + column
                        if listItems.indices.contains(itemIndex) {
                            if listItems[itemIndex].emoji == "" {
                                Image(systemName: "bag")
                            } else {
                                Text(listItems[itemIndex].emoji ?? "")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                    .font(.title)
                                    .font((count <= swapCount ? .title : .title2))
                                    
                            }
                        }
                    }
                }
            }
        }
        .padding(2)
    }
}

struct EmojiWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmojiWidgetView(maxItems: 17, swapCount: 16)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            EmojiWidgetView(maxItems: 25, swapCount: 15)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            EmojiWidgetView(maxItems: 121, swapCount: 100)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
