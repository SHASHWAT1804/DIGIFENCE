//
//  FirebaseService.swift.swift
//  DIGIFENCE
//
//  Created by admin85 on 08/03/25.

// FirebaseService.swift
import Foundation
import Firebase
import CoreData
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}
    

        func saveEventToFirebase(event: Event) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            let eventsRef = db.collection("users").document(userId).collection("events")
            
            do {
                try eventsRef.document(event.name).setData([
                    "name": event.name,
                    "venue": event.venue,
                    "startDate": event.startDate,
                    "endDate": event.endDate,
                    "date": event.date,
                    "time": event.time,
                    "attendeeName": event.attendeeName,
                    "attendeeEmail": event.attendeeEmail,
                    "attendeePhone": event.attendeePhone,
                    "userId": userId
                ], merge: true)
            } catch {
                print("Error saving event to Firebase: \(error)")
            }
        }
        
        func fetchEventsForCurrentUser(completion: @escaping ([Event]) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                completion([])
                return
            }
            
            let db = Firestore.firestore()
            let eventsRef = db.collection("users").document(userId).collection("events")
            
            eventsRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching events: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let context = CoreDataManager.shared.context
                var events: [Event] = []
                
                documents.forEach { document in
                    let event = Event(context: context)
                    event.name = document["name"] as? String ?? ""
                    event.venue = document["venue"] as? String ?? ""
                    event.startDate = document["startDate"] as? Date ?? Date()
                    event.endDate = document["endDate"] as? Date ?? Date()
                    event.date = document["date"] as? String ?? ""
                    event.time = document["time"] as? String ?? ""
                    event.attendeeName = document["attendeeName"] as? String ?? ""
                    event.attendeeEmail = document["attendeeEmail"] as? String ?? ""
                    event.attendeePhone = document["attendeePhone"] as? String ?? ""
                    event.userId = document["userId"] as? String ?? ""
                    
                    events.append(event)
                }
                
                completion(events)
            }
        }
    }
