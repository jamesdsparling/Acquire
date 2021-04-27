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
    @Binding var newPrice: Float
    
    var itemTypes: [String]
    
    var currencyFormatter: NumberFormatter = {
            let f = NumberFormatter()
            // allow no currency symbol, extra digits, etc
            f.isLenient = true
            f.numberStyle = .currency
            return f
        }()
    
    var body: some View {
        
        let priceBinding = Binding<String>(
            get: {
                "£" + String(format: "%.2f", self.newPrice)
            },
            set: {
                var input = $0.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
                let splitInput = input.split(separator: ".")
                if splitInput.count > 1 {
                    if splitInput[1].count < 2 {
                        let startInput = "00" + splitInput[0]
                        let needed = 2 - splitInput[1].count
                        let end = startInput.index(startInput.endIndex, offsetBy: -needed)
                        input = startInput[..<end] + "." + startInput[end...] + splitInput[1]
                    } else if splitInput[1].count > 2 {
                        let end2 = splitInput[1].index(splitInput[1].endIndex, offsetBy: -2)
                        input = splitInput[0] + splitInput[1][..<end2] + "." + splitInput[1][end2...]
//                        input = String(newInput)
                    }
                }
//                print(input)
                self.newPrice = Float(input) ?? 0.00
            }
        )
        
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
                    HStack {
                        VStack {
                            JamesPicker(selection: $newType, presets: itemTypes, isTyping: $jPickerShowing)
                                .padding(10)
                                .background(
                                    Color(UIColor.systemGray5)
                                        .cornerRadius(25)
                                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                                )
                        }
                        if !jPickerShowing {
                            TextField("Price", text: priceBinding)
                                .frame(maxWidth: 70)
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .background(
                                    Color(UIColor.systemGray5)
                                        .cornerRadius(50)
                                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                                )
                                .keyboardType(.decimalPad)
                        }
                    }
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
                                saveItem(name: newName, type: newType, emoji: newEmoji, quantity: 1, price: newPrice)
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
                    newPrice = 0.00
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
    
    func saveItem(name: String, type: String, emoji: String, quantity: Int16, price: Float) {
        let newItem = ListItem(context: moc)
        newItem.name = name
        newItem.type = type
        newItem.emoji = emoji
        newItem.quantity = quantity
        newItem.price = price
        newItem.date = Date()
        print(price)
        
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
