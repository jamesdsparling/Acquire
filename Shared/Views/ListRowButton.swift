//
//  ListRowButton.swift
//  Acquire
//
//  Created by James Sparling on 06/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct ListRowButton: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var listItem: ListItem
    
    var body: some View {
        Button(action: {
            listItem.quantity = listItem.quantity == 0 ? 1 : 0
            listItem.date = Date()
            try? moc.save()
            WidgetCenter.shared.reloadAllTimelines()
        }) {
            ListRow(listItem: listItem, compactView: false)
        }
        .contextMenu {
            ItemMenu(listItem: listItem)
                .environment(\.managedObjectContext, self.moc)
        }
    }
}

//struct ListRowButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ListRowButton()
//    }
//}
