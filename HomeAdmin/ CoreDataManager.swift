//
//   CoreDataManager.swift
//  DIGIFENCE
//
//  Created by admin85 on 08/03/25.
//

// CoreDataManager.swift
import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy private(set) var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EventsApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
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
    
    func saveEvent(eventData: EventData) throws {
        let event = Event(context: context)
        event.name = eventData.name
        event.image = eventData.image.pngData()!
        event.venue = eventData.venue
        event.startDate = eventData.date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: eventData.date)!
        event.date = DateFormatter.localizedString(from: eventData.date, dateStyle: .medium, timeStyle: .none)
        event.time = DateFormatter.localizedString(from: eventData.date, dateStyle: .none, timeStyle: .short)
        event.attendeeName = eventData.adhereName
        event.attendeeEmail = eventData.adhereEmail
        event.attendeePhone = eventData.adherePhone
        
        saveContext()
    }
    
    func fetchEvents() -> [Event] {
        let request: NSFetchRequest<Event> = Event.fetchRequest() as! NSFetchRequest<Event>
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching events: \(error)")
            return []
        }
    }
}

struct EventData {
    var name: String
    var image: UIImage
    var venue: String
    var date: Date
    var adhereName: String
    var adhereEmail: String
    var adherePhone: String
}
