//
//  Event+CoreDataClass.swift
//  DIGIFENCE
//
//  Created by admin85 on 08/03/25.
//

// Event+CoreDataClass.swift
import Foundation
import CoreData
import UIKit

@objc(Event)
public class Event: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var image: Data
    @NSManaged public var venue: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var date: String
    @NSManaged public var time: String
    @NSManaged public var attendeeName: String
    @NSManaged public var attendeeEmail: String
    @NSManaged public var attendeePhone: String
    @NSManaged public var userId: String 
}
// Event+CoreDataClass.swift
extension Event {
    convenience init(eventData: EventData) {
        self.init(context: CoreDataManager.shared.context)
        self.name = eventData.name
        self.image = eventData.image.pngData()!
        self.venue = eventData.venue
        self.startDate = eventData.date
        self.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: eventData.date)!
        self.date = DateFormatter.localizedString(from: eventData.date, dateStyle: .medium, timeStyle: .none)
        self.time = DateFormatter.localizedString(from: eventData.date, dateStyle: .none, timeStyle: .short)
        self.attendeeName = eventData.adhereName
        self.attendeeEmail = eventData.adhereEmail
        self.attendeePhone = eventData.adherePhone
    }
    
    func toEventData() -> EventData {
        return EventData(
            name: self.name,
            image: UIImage(data: self.image)!,
            venue: self.venue,
            date: self.startDate,
            adhereName: self.attendeeName,
            adhereEmail: self.attendeeEmail,
            adherePhone: self.attendeePhone
        )
    }
}
