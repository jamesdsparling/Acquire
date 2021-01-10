//
//  Persistence.swift
//  Acquire
//
//  Created by James Sparling on 05/01/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<2 {
            let newItem = ListItem(context: viewContext)
            newItem.name = "Test Item"
            newItem.type = "Other"
            newItem.emoji = "🙃"
            newItem.quantity = 1
            newItem.date = Date()
        }
        try? viewContext.save()
        return result
    }()
    
    let container: NSPersistentContainer
    

    init(inMemory: Bool = false) {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.jamesdsparling.Acquire")!
        let storeURL = containerURL.appendingPathComponent("Model.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        container = NSPersistentContainer(name: "Model")
        container.persistentStoreDescriptions = [description]
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
