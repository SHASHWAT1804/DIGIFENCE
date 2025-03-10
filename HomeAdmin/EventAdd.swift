import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomEventDelegate, EventDetailPopupDelegate {
    struct Event {
        var image: UIImage?
        var name: String
        var date: String
        var time: String?
        var venue: String
        var adhereName: String
        var adhereEmail: String
        var adherePhone: String
    }
    
    @IBOutlet weak var eventTableView: UITableView!
    var eventData: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedEvents()
        title = "Events"
        view.backgroundColor = .systemBackground
        
        eventTableView.register(EventDataTableViewCell.self, forCellReuseIdentifier: "EventDataTableViewCell")
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            fetchEventsForCurrentUser()
        }
    }
    
    private func fetchEventsForCurrentUser() {
        FirebaseService.shared.fetchEventsForCurrentUser { [weak self] events in
            //self?.eventData = events
            self?.eventTableView.reloadData()
        }
    }
    
    private func loadSavedEvents() {
        let savedEvents = CoreDataManager.shared.fetchEvents()
        eventData = savedEvents.map { event -> Event in
            return Event(
                image: UIImage(data: event.image)!,
                name: event.name,
                date: event.date,
                time: event.time,
                venue: event.venue,
                adhereName: event.attendeeName,
                adhereEmail: event.attendeeEmail,
                adherePhone: event.attendeePhone
            )
        }
        eventTableView.reloadData()
    }
    
    // MARK: - UITableView Data Source & Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventDataTableViewCell", for: indexPath) as? EventDataTableViewCell else {
            return UITableViewCell()
        }
        
        let event = eventData[indexPath.row]
        cell.eventOImage.image = event.image
        cell.eventOName.text = event.name
        cell.eventODate.text = event.date
        cell.eventOTime.text = event.time
        cell.eventOVenue.text = event.venue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedEvent = eventData[indexPath.row]
        
        let eventDetailVC = EventDetailPopupViewController()
        eventDetailVC.eventImage = selectedEvent.image
        eventDetailVC.eventName = selectedEvent.name
        eventDetailVC.venue = selectedEvent.venue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        eventDetailVC.date = dateFormatter.date(from: selectedEvent.date) ?? Date()
        eventDetailVC.time = timeFormatter.date(from: selectedEvent.time ?? "") ?? Date()
        
        eventDetailVC.adhereName = selectedEvent.adhereName
        eventDetailVC.adhereEmail = selectedEvent.adhereEmail
        eventDetailVC.adherePhone = selectedEvent.adherePhone
        
        eventDetailVC.delegate = self
        eventDetailVC.eventIndex = indexPath.row
        
        let navigationController = UINavigationController(rootViewController: eventDetailVC)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Adding New Events
    @objc func didTapAdd() {
        let customEventVC = CustomEventViewController()
        customEventVC.delegate = self
        let navigationController = UINavigationController(rootViewController: customEventVC)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - CustomEventDelegate Methods
    func didSaveEvent(name: String, date: String, time: String, image: UIImage, venue: String, adhereName: String, adhereEmail: String, adherePhone: String) {
        let newEvent = Event(
            image: image,
            name: name,
            date: date,
            time: time,
            venue: venue,
            adhereName: adhereName,
            adhereEmail: adhereEmail,
            adherePhone: adherePhone
        )
        eventData.append(newEvent)
        eventTableView.reloadData()
    }
    
    func didUpdateEvent(at index: Int, with updatedEvent: Event) {
        eventData[index] = updatedEvent
        eventTableView.reloadData()
    }
    
    func didDeleteEvent(at index: Int) {
        eventData.remove(at: index)
        eventTableView.reloadData()
    }
}
