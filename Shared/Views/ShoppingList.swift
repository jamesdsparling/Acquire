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
    
    @AppStorage("currencySymbol") var currencySymbol: String = "£"
    
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
        
//        selection: $selectKeeper
        List() {
            Section {
                TextInputBar(text: $searchText, label: "🔎  Search...", buttonType: .cancel, isEditing: $isSearching)
            }
            Section {
                ForEach(sortedList.filter { $0.quantity > 0 && (searchText.isEmpty ? true : ($0.emoji!.lowercased() + $0.name!.lowercased()).contains(searchText.lowercased())) }, id: \.name) { listItem in
                     
                }
                .onDelete{indexSet in
                    for index in indexSet {
                        let item = (sortedList.filter { $0.quantity > 0 && (searchText.isEmpty ? true : ($0.emoji!.lowercased() + $0.name!.lowercased()).contains(searchText.lowercased())) })[index]
                        moc.delete(item)
                    }
                }
//                .onMove(perform: {print("Delete")})
            }
            if sortedList.contains(where: { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }) {
                Section(header: Text("Preveious Items")) {
                    ForEach(sortedList.filter { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) }, id: \.name) { listItem in
                        ListRowButton(listItem: listItem)
                            .environment(\.managedObjectContext, self.moc) 
                    }
                    .onDelete{indexSet in
                        for index in indexSet {
                            let item = (sortedList.filter { $0.quantity == 0 && (searchText.isEmpty ? true : $0.name!.lowercased().contains(searchText.lowercased())) })[index]
                            moc.delete(item)
                        }
                    }
//                    .onMove(perform: {print("Delete")})
                }
            }
        }
        .animation(.easeInOut)
//        .environment(\.editMode, self.$editMode)
        .animation(isSearching ? .none : .default)
        .navigationBarTitle(listItems.reduce(0, {$0 + ($1.price * Float($1.quantity))}) == 0 ? "Shopping List" : currencySymbol + String(format: "%.2f", listItems.reduce(0, {$0 + ($1.price * Float($1.quantity))})))
        .listStyle(InsetGroupedListStyle())
        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                CustomEditButton(sortBy: $sortBy, sortReversed: $sortReversed, selectKeeper: $selectKeeper, editMode: $editMode)
//            }

            ToolbarItem(placement: .navigationBarTrailing) {
//                if editMode == .inactive {
                    SortMenu(sortBy: $sortBy, sortReversed: $sortReversed)
//                } else {
//                    Button(action: {
//                        for deleteName in selectKeeper {
//                            moc.delete(listItems.first(where: {$0.name == deleteName})!)
//                            try? self.moc.save()
//                            WidgetCenter.shared.reloadAllTimelines()
//                        }
//                        selectKeeper = Set<String>()
//                        editMode.toggle()
//                        print(selectKeeper)
//                    }) {
//                        Image(systemName: "trash")
//                    }
////                    .disabled(selectKeeper.count == 0)
//                }
            }
        }
    }
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
//            .environment(\.colorScheme, .dark)
    }
}
