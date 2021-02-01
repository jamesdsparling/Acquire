//
//  ShoppingList.swift
//  Acquire
//
//  Created by James Sparling on 11/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct ShoppingList: View {
    @Environment(\.managedObjectContext) private var moc
    
    var listItems: FetchedResults<ListItem>
    @Binding var sortBy: SortOptions
    @Binding var sortReversed: Bool
    @Binding var showingAddSheet: Bool
    @Binding var editMode: EditMode
    
    @State var selectKeeper = Set<String>()
    @State var isSearching = false
    @State var searchText = ""
    
    var body: some View {
        let sortedList = listItems.sorted(by: {
            switch sortBy {
//            case .custom:
//                return sortReversed
            case .date:
                return sortReversed
            case .name:
                return sortReversed ? ($0.name ?? "" > $1.name ?? "") : ($0.name ?? "" < $1.name ?? "")
            case .quantity:
                return sortReversed ? ($0.quantity < $1.quantity) : ($0.quantity > $1.quantity)
            }
        })
        
        List(selection: $selectKeeper) {
            Section {
                TextInputBar(text: $searchText, label: "🔎  Search...", buttonType: .cancel, isEditing: $isSearching)
            }
            Section {
                ForEach(sortedList.filter { $0.quantity > 0 && (searchText.isEmpty ? true : ($0.emoji!.lowercased() + $0.name!.lowercased()).contains(searchText.lowercased())) }, id: \.name) { listItem in
                    ListRowButton(listItem: listItem)
                        .environment(\.managedObjectContext, self.moc)
                }
//                .onDelete(perform: delete)
                //                        .onMove(perform: move)
            }
            if sortedList.contains(where: { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }) {
                Section(header: Text("Preveious Items")) {
                    ForEach(sortedList.filter { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }, id: \.name) { listItem in
                        ListRowButton(listItem: listItem)
                            .environment(\.managedObjectContext, self.moc)
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.map { listItems[$0] }.forEach(moc.delete)
                        try? moc.save()
                        WidgetCenter.shared.reloadAllTimelines()
                    })
                }
            }
        }
        .animation(.easeInOut)
        .environment(\.editMode, self.$editMode)
        .animation(isSearching ? .none : .default)
        .navigationBarTitle("Shopping List")
        .listStyle(InsetGroupedListStyle())
        .toolbar {
//            ContentViewToolbar(listItems: listItems, selectKeeper: $selectKeeper, editMode: $editMode, sortBy: $sortBy, sortReversed: $sortReversed)
//                .environment(\.managedObjectContext, self.moc)
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
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environment(\.colorScheme, .dark)
    }
}
