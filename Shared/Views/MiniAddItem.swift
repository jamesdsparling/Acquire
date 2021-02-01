//
//  MiniAddItem.swift
//  Acquire
//
//  Created by James Sparling on 11/01/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct MiniAddItem: View {
    @Environment(\.managedObjectContext) private var moc
    var listItems: FetchedResults<ListItem>
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showingAdd: Bool
    @State var jPickerShowing = false
    @Binding var showingAddSheet: Bool
    @Binding var editMode: EditMode
    
    @Binding var newName: String
    @Binding var newType: String
    @Binding var newEmoji: String
    @Binding var newQuantity: Int16
    
    var itemTypes: [String]
    
    var body: some View {
        VStack {
            if showingAdd {
                VStack {
                    if !jPickerShowing {
                        HStack {
                            TextField("Emoji", text: $newEmoji)
                                .frame(maxWidth: 70)
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .background(
                                    Color(UIColor.systemGray5)
                                        .cornerRadius(50)
                                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                                )
                            //                                Divider()
                            TextField("Name", text: $newName)
                                .padding(10)
                                .background(
                                    Color(UIColor.systemGray5)
                                        .cornerRadius(50)
                                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                                )
                        }
                    }
                    JamesPicker(selection: $newType, presets: itemTypes, isTyping: $jPickerShowing)
                        .padding(10)
                        .background(
                            Color(UIColor.systemGray5)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                        )
                    if !jPickerShowing {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showingAdd = false
                                }
                                
                            }) {
                                Text("Cancel")
                                    .padding(10)
                            }
                            .background(
                                Color(UIColor.systemGray5)
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                            )
                            .foregroundColor(Color.red)
                            Spacer()
                            
                            Button(action: {showingAddSheet = true}) {
                                Text("More Options")
                                    .padding(10)
                            }
                            .background(
                                Color(UIColor.systemGray5)
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                            )
                            Spacer()
                            
                            Button(action: {
                                saveItem(name: newName, type: newType, emoji: newEmoji, quantity: 1)
                            }) {
                                Text("Done")
                                    .padding(10)
                            }
                            .background(
                                Color(UIColor.systemGray5)
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                            )
                            .disabled(newName == "" || newEmoji.count > 1)
                            
                            Spacer()
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(20)
            } else {
                Button(action: {
                    newName = ""
                    newType = ""
                    newEmoji = ""
                    newQuantity = 1
                    showingAdd = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                            .font(.headline)
                    }
                    .padding(20)
                }
                
            }
        }
        .cornerRadius(50)
        .background(
            Color(UIColor.systemGray6)
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
        )
        .padding(.bottom, 20)
        //        .animation(.easeInOut)
    }
    
    func saveItem(name: String, type: String, emoji: String, quantity: Int16) {
        let newItem = ListItem(context: moc)
        newItem.name = name
        newItem.type = type
        newItem.emoji = emoji
        newItem.quantity = quantity
        newItem.date = Date()
        
        if let oldItem = listItems.first(where: { $0.name == name }) {
            newItem.quantity += oldItem.quantity
            moc.delete(oldItem)
        }
        
        try? self.moc.save()
        WidgetCenter.shared.reloadAllTimelines()
        showingAdd = false
    }
}

struct MiniAddItem_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
