import UIKit
import EventKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


protocol CustomEventDelegate: AnyObject {
    func didSaveEvent(name: String, date: String, time: String, image: UIImage, venue: String, adhereName: String, adhereEmail: String, adherePhone: String)
}


class CustomEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: CustomEventDelegate?
    
    let eventStore = EKEventStore()
    
    private let eventTitleTextField = UITextField()
    private let venueTextField = UITextField()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let attendeeNameTextField = UITextField()
    private let attendeeEmailTextField = UITextField()
    private let attendeePhoneTextField = UITextField()
    private let geofenceButton = UIButton() // Mark Fence button
    private let eventImageView = UIImageView()
    private let chooseImageButton = UIButton()
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        startDateChanged()
        requestCalendarAccess()
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Event"
        
        // Setup Event Title TextField
        eventTitleTextField.placeholder = "Event Title"
        eventTitleTextField.borderStyle = .roundedRect
        
        // Setup Venue TextField
        venueTextField.placeholder = "Venue"
        venueTextField.borderStyle = .roundedRect
        
        // Setup Start and End Date Pickers
        startDatePicker.datePickerMode = .dateAndTime
        endDatePicker.datePickerMode = .dateAndTime
        
        let startDateLabel = UILabel()
        startDateLabel.text = "Starts"
        startDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        let endDateLabel = UILabel()
        endDateLabel.text = "Ends"
        endDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Setup Attendee Information TextFields
        attendeeNameTextField.placeholder = "Coordinator Name"
        attendeeNameTextField.borderStyle = .roundedRect
        
        attendeeEmailTextField.placeholder = "Coordinator Email"
        attendeeEmailTextField.borderStyle = .roundedRect
        
        attendeePhoneTextField.placeholder = "Coordinator Phone"
        attendeePhoneTextField.borderStyle = .roundedRect
        
        // Setup Event Image View
        eventImageView.contentMode = .scaleAspectFit
        eventImageView.backgroundColor = .secondarySystemFill
        eventImageView.layer.cornerRadius = 8
        eventImageView.clipsToBounds = true
        
        // Add Temporary Text Label Over Event Image View
        let eventImagePlaceholderLabel = UILabel()
        eventImagePlaceholderLabel.text = "Upload Event Poster"
        eventImagePlaceholderLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        eventImagePlaceholderLabel.textAlignment = .center
        eventImagePlaceholderLabel.textColor = .systemGray
        eventImagePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.addSubview(eventImagePlaceholderLabel)
        
        NSLayoutConstraint.activate([
            eventImagePlaceholderLabel.centerXAnchor.constraint(equalTo: eventImageView.centerXAnchor),
            eventImagePlaceholderLabel.centerYAnchor.constraint(equalTo: eventImageView.centerYAnchor)
        ])
        
        // Setup Choose Image Button
        chooseImageButton.setTitle("Choose Image", for: .normal)
        chooseImageButton.setTitleColor(.systemBlue, for: .normal)
        chooseImageButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        
        // Setup Geofence Button
        geofenceButton.setTitle("Mark Fence", for: .normal)
        geofenceButton.setTitleColor(.white, for: .normal)
        geofenceButton.backgroundColor = .systemBlue
        geofenceButton.layer.cornerRadius = 8
        geofenceButton.addTarget(self, action: #selector(navigateToGeofence), for: .touchUpInside)
        
        // Add UI elements to the view
        [eventTitleTextField, venueTextField, startDateLabel, startDatePicker, endDateLabel, endDatePicker,
         attendeeNameTextField, attendeeEmailTextField, attendeePhoneTextField, eventImageView,
         chooseImageButton, geofenceButton].forEach { view.addSubview($0) }
        
        setupConstraints(startDateLabel: startDateLabel, endDateLabel: endDateLabel)
    }
    
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style:.done, target: self, action: #selector(saveEvent))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style:.plain, target: self, action: #selector(cancelEvent))
    }
    
    private func setupConstraints(startDateLabel: UILabel, endDateLabel: UILabel) {
        let padding: CGFloat = 16
        
        eventTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        venueTextField.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        attendeeNameTextField.translatesAutoresizingMaskIntoConstraints = false
        attendeeEmailTextField.translatesAutoresizingMaskIntoConstraints = false
        attendeePhoneTextField.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        chooseImageButton.translatesAutoresizingMaskIntoConstraints = false
        geofenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            eventTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            eventTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            eventTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            venueTextField.topAnchor.constraint(equalTo: eventTitleTextField.bottomAnchor, constant: padding),
            venueTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            venueTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            startDateLabel.topAnchor.constraint(equalTo: venueTextField.bottomAnchor, constant: padding),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            startDatePicker.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 4),
            startDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            startDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            endDateLabel.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor, constant: padding),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            endDatePicker.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 4),
            endDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            endDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            attendeeNameTextField.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: padding),
            attendeeNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            attendeeNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            attendeeEmailTextField.topAnchor.constraint(equalTo: attendeeNameTextField.bottomAnchor, constant: padding),
            attendeeEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            attendeeEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            attendeePhoneTextField.topAnchor.constraint(equalTo: attendeeEmailTextField.bottomAnchor, constant: padding),
            attendeePhoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            attendeePhoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            eventImageView.topAnchor.constraint(equalTo: attendeePhoneTextField.bottomAnchor, constant: padding),
            eventImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            eventImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            eventImageView.heightAnchor.constraint(equalToConstant: 200),
            
            chooseImageButton.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: padding),
            chooseImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chooseImageButton.widthAnchor.constraint(equalToConstant: 150),
            chooseImageButton.heightAnchor.constraint(equalToConstant: 40),
            
            geofenceButton.topAnchor.constraint(equalTo: chooseImageButton.bottomAnchor, constant: padding), // Reduced padding
            geofenceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            geofenceButton.widthAnchor.constraint(equalToConstant: 250),
            geofenceButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            if granted && error == nil {
                print("Calendar access granted")
            } else {
                print("Calendar access denied or error occurred: \(String(describing: error))")
                let alert = UIAlertController(title: "Permission Denied", message: "Please grant access to your calendar.", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style:.default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
            eventImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    @objc  func saveEvent() {
        guard let eventName = eventTitleTextField.text, !eventName.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for the event.")
            return
        }
        guard let eventImage = selectedImage else {
            showAlert(title: "Missing Image", message: "Please choose an image for the event.")
            return
        }
        guard let venueName = venueTextField.text, !venueName.isEmpty else {
            showAlert(title: "Missing Venue", message: "Please enter the venue for the event.")
            return
        }
        let eventDate = DateFormatter.localizedString(from: startDatePicker.date, dateStyle:.medium, timeStyle:.short)
        let eventTime = DateFormatter.localizedString(from: startDatePicker.date, dateStyle:.none, timeStyle:.short)
        
        if !checkIfEventExists(eventName: eventName, startDate: startDatePicker.date) {
            addEventToCalendar(eventName: eventName, venue: venueName, startDate: startDatePicker.date, endDate: endDatePicker.date, attendeeName: attendeeNameTextField.text ?? "", attendeeEmail: attendeeEmailTextField.text ?? "", attendeePhone: attendeePhoneTextField.text ?? "")
            
            // Save to Firestore
            saveEventData(
                imageURL: nil,
                title: eventName,
                venue: venueName,
                startDate: startDatePicker.date,
                endDate: endDatePicker.date,
                coordinatorName: attendeeNameTextField.text ?? "",
                coordinatorContact: attendeePhoneTextField.text ?? "",
                coordinatorEmail: attendeeEmailTextField.text ?? ""
            )
        } else {
            showAlert(title: "Event Already Exists", message: "An event with this name already exists on this date.")
            return
        }
        
        delegate?.didSaveEvent(name: eventName, date: eventDate, time: eventTime, image: eventImage, venue: venueName, adhereName: attendeeNameTextField.text ?? "", adhereEmail: attendeeEmailTextField.text ?? "", adherePhone: attendeePhoneTextField.text ?? "")
        dismiss(animated: true)
    }
    
    func saveEventData(imageURL: String?, title: String, venue: String, startDate: Date, endDate: Date,
                       coordinatorName: String, coordinatorContact: String, coordinatorEmail: String
    ) {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        let eventData: [String: Any] = [
            "title": title,
            "venue": venue,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "coordinator": [
                "name": coordinatorName,
                "contact": coordinatorContact,
                "email": coordinatorEmail
            ],
            "imageURL": imageURL ?? "",
            "userID": userID,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("events").addDocument(data: eventData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Save Error", message: error.localizedDescription)
                } else {
                    print("Event saved successfully to Firestore")
                }
            }
        }
    }
    
  
    
        
    // MARK: - Alert Helper
        func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
             let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
             self.present(alert, animated: true)
        }

    private func checkIfEventExists(eventName: String, startDate: Date) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: startDate.addingTimeInterval(24 * 60 * 60), calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.contains(where: { $0.title == eventName })
    }


    private func addEventToCalendar(eventName: String, venue: String, startDate: Date, endDate: Date, attendeeName: String, attendeeEmail: String, attendeePhone: String) {
        let event = EKEvent(eventStore: eventStore)
        event.title = eventName
        event.location = venue
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved successfully")
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to save event. Please try again.")
        }
    }
    @objc func startDateChanged() {
            // Ensure end date is at least 1 minute after the selected start date.
            let minEndDate = startDatePicker.date.addingTimeInterval(60)
            endDatePicker.minimumDate = minEndDate
            if endDatePicker.date < minEndDate {
                endDatePicker.date = minEndDate
            }
        }

    @objc private func cancelEvent() {
        dismiss(animated: true)
    }

    @objc private func navigateToGeofence() {
        let geofenceVC = GeofenceViewController()
        navigationController?.pushViewController(geofenceVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default))
        present(alert, animated: true)
    }
}
