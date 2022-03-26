//
//  DataStoreManager.swift
//  Notes
//
//  Created by Me on 26.03.2022.
//

import Foundation
import CoreData

class DataStoreManager {
    
    static var shared = DataStoreManager()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Metods
    func fetchData( notes: [Note]) -> [Note]{
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
 
        var myTasks = notes
        do {
            myTasks = try context.fetch(fetchRequest)
     
        } catch let error {
            print(error)
        }
        return myTasks

    }
    
    func createInitialNote() {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
        guard let note = NSManagedObject(entity: entityDescription, insertInto: context) as? Note else { return }
        note.title = "Hello"
        note.text = "Have a good day"
        save()
    }
    
    func addNew(titleValue: String, textValue: String) -> Note? {

        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return nil}
        guard let note = NSManagedObject(entity: entityDescription, insertInto: context) as? Note else { return nil}
        
        note.title = titleValue
        note.text = textValue
        
        save()
        return note
    }
    
    func update() {
        save()
    }
    
    func delete(note: Note) {
        context.delete(note)
        save()
    }
    
    //MARK: - private metods
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
}
