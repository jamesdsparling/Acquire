//
//  ContentViewToolbar.swift
//  Acquire
//
//  Created by James Sparling on 11/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentViewToolbar: ToolbarContent {
    @Environment(\.managedObjectContext) private var moc
    
    var listItems: FetchedResults<ListItem>
    
    @Binding var selectKeeper: Set<String>
    @Binding var editMode: EditMode
    @Binding var sortBy: SortOptions
    @Binding var sortReversed: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            if editMode == .active {
                Button(action: {
                    for deleteName in selectKeeper {
                        let deleteItem = listItems.first(where: {$0.name == deleteName})
                        deleteItem!.quantity = deleteItem!.quantity == 0 ? 1 : 0
                        try? self.moc.save()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    selectKeeper = Set<String>()
                    editMode.toggle()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Completed")
                            .font(.headline)
                    }
                }
                .disabled(selectKeeper.count == 0)
            }
        }

        ToolbarItem(placement: .navigationBarLeading) {
            CustomEditButton(sortBy: $sortBy, sortReversed: $sortReversed, selectKeeper: $selectKeeper, editMode: $editMode)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if editMode == .inactive {
                SortMenu(sortBy: $sortBy, sortReversed: $sortReversed)
            } else {
                Button(action: {
                    for deleteName in selectKeeper {
                        moc.delete(listItems.first(where: {$0.name == deleteName})!)
                        try? self.moc.save()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    selectKeeper = Set<String>()
                    editMode.toggle()
                }) {
                    Image(systemName: "trash")
                }
                .disabled(selectKeeper.count == 0)
            }
        }
    }
}
