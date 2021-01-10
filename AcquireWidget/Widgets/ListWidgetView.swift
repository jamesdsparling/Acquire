//
//  ListWidgetView.swift
//  AcquireWidgetExtension
//
//  Created by James Sparling on 0maxItems/01/2021.
//

import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.date, ascending: false)],
        //        sortDescriptors: [],
        animation: .default)
    private var listItems: FetchedResults<ListItem>
    
    @State var maxItems: Int
    var body: some View {
        VStack {
            Text("Shopping List")
                .font(.headline)
                .multilineTextAlignment(.leading)
                .padding(.top, 10)
            if listItems.contains(where: { $0.quantity > 0 }) {
                VStack {
                    let range: Range<Int> = 0..<min(maxItems, listItems.filter{ $0.quantity > 0 }.count)
                    ForEach(range, id: \.self) {
                        ListRow(listItem: listItems.filter{ $0.quantity > 0 }[$0], compactView: true)
                            .padding(.horizontal, 5)
                        
                        if $0 != range.last {
                            Divider()
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(20)
                let moreItems = listItems.filter{ $0.quantity > 0 }.count - maxItems
                if moreItems > 0 {
                    Text("\(moreItems) more item\(moreItems > 1 ? "s" : "")...")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
            } else {
                Text("No items on list")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green)
                    .foregroundColor(Color.black)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
}

struct LargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetView(maxItems: 6)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
