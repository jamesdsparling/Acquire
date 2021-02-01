//
//  ContentView.swift
//  Acquire (macOS)
//
//  Created by James Sparling on 06/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.date, ascending: false)],
        //        sortDescriptors: [],
        animation: .default)
    private var listItems: FetchedResults<ListItem>
    
    @State private var showingAddSheet = false
    var newItem = ListItem()
    @State private var sortBy = SortOptions.custom
    @State private var sortReversed = false
    @State var searchText = ""
    @State var selectKeeper = Set<String>()
    @State private var isSearching = false
    @State var typePresets = ["Food", "Drink", "Other"]
    
    var body: some View {
//        let sortedList = listItems.sorted(by: {
//            switch sortBy {
//            case .custom:
//                return sortReversed
//            case .dateAdded:
//                return sortReversed ? ($0.date > $1.date) : ($0.date < $1.date)
//            case .name:
//                return sortReversed ? ($0.name > $1.name) : ($0.name < $1.name)
//            case .quantity:
//                return sortReversed ? ($0.quantity > $1.quantity) : ($0.quantity < $1.quantity)
//            }
//        })
        
        NavigationView {
            VStack {
                List(selection: $selectKeeper) {
                    Section {
                        TextInputBar(text: $searchText, label: "🔎  Search...", buttonType: .cancel, isEditing: $isSearching)
                    }
                    Section {
                        ForEach(listItems.filter { $0.quantity > 0 && (searchText.isEmpty ? true : ($0.emoji!.lowercased() + $0.name!.lowercased()).contains(searchText.lowercased())) }, id: \.name) { listItem in
                            ListRowButton(listItem: listItem)
                                .environment(\.managedObjectContext, self.moc)
                        }
                        .onDelete(perform: delete)
                        //                        .onMove(perform: move)
                    }
                    if listItems.contains(where: { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }) {
                        Section(header: Text("Preveious Items")) {
                            ForEach(listItems.filter { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }, id: \.name) { listItem in
                                ListRowButton(listItem: listItem)
                                    .environment(\.managedObjectContext, self.moc)
                            }
                            .onDelete(perform: delete)
//                            .onMove(perform: move)
                        }
                    }
                }
                .animation(isSearching ? .none : .default)
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Item")
                                    .font(.headline)
                            }
                        }
                    }
                    
                    ToolbarItem {
                        SortMenu(sortBy: $sortBy, sortReversed: $sortReversed)
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    let listItemTypes = Set(listItems.map { $0.type ?? "Unknown Type"})
                    let filteredTypePresets = typePresets.filter({ !listItemTypes.contains($0) })
                    let typePresets = listItemTypes + filteredTypePresets
                    AddItem(showingAdd: $showingAddSheet, presets: typePresets)
                        .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        //            listItems.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        offsets.map { listItems[$0] }.forEach(moc.delete)
        try? moc.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
