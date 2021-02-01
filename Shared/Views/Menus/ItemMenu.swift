//
//  ItemMenu.swift
//  Acquire
//
//  Created by James Sparling on 05/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct ItemMenu: View {
    @Environment(\.managedObjectContext) var moc
    
//    @State private var showingEdit = false
    @ObservedObject var listItem: ListItem
    
    var body: some View {
        Section {
            Button(action: {
                listItem.quantity = listItem.quantity == 0 ? 1 : 0
                listItem.date = Date()
                try? moc.save()
                WidgetCenter.shared.reloadAllTimelines()
            }) {
                Label(listItem.quantity == 0 ? "Unmark as Complete" : "Mark as Complete", systemImage: "checkmark")
            }
            
            Button(action: {
                moc.delete(listItem)
                try? moc.save()
                WidgetCenter.shared.reloadAllTimelines()
            }) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(Color.red)
        }
        Section {
//            Button(action: {
//                showingEdit = true
//            }) {
//                Label("Edit", systemImage: "pencil")
//            }
//            .sheet(isPresented: $showingEdit) {
//                AddItem(showingAdd: $showingEdit)
//            }
            
            Button(action: {
                listItem.quantity += 1
                try? moc.save()
                WidgetCenter.shared.reloadAllTimelines()
            }) {
                Label("Quantity Up", systemImage: "chevron.up")
            }
            Button(action: {
                listItem.quantity -= 1
                try? moc.save()
                WidgetCenter.shared.reloadAllTimelines()
            }) {
                Label("Quantity Down", systemImage: "chevron.down")
            }
            .disabled(listItem.quantity < 1)
        }
        
    }
}

struct ItemMenu_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}){
            Text("ListItem")
        }
        .contextMenu{
            ItemMenu(listItem: ListItem())
        }
    }
}
