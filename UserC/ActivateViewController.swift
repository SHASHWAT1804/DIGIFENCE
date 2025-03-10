import UIKit
import LocalAuthentication
import MapKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    let tableView = UITableView()
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    
    var userAnnotation = MKPointAnnotation()
    let profileButton = UIButton(type: .system)
    let largeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Events"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = .systemBlue
        return label
    }()
   
    // Updated Event Data Structure
    var events = [
        ["name": "Tech Conference", "date": "2025-02-10", "time": "10:00 AM", "location": "28.3669,77.5413",
         "details": "A conference about technology trends.", "image": "Diljit",
         "description": "Join industry leaders discussing future tech innovations. Keynote speakers include renowned experts in AI and quantum computing.",
         "hostName": "Tech Summit Organizers",
         "hostEmail": "techsummit@email.com",
         "hostPhone": "(555) 123-4567"],
        
        ["name": "Art Workshop", "date": "2025-03-05", "time": "2:00 PM", "location": "13.026659,80.23618",
         "details": "A workshop to explore art techniques.", "image": "cultural",
         "description": "Hands-on session exploring modern painting techniques. Materials provided.",
         "hostName": "Art Studio Collective",
         "hostEmail": "artstudio@email.com",
         "hostPhone": "(555) 890-1234"],
        
        ["name": "Music Festival", "date": "2025-04-15", "time": "5:00 PM", "location": "40.7128,-74.0060",
         "details": "A festival featuring live music performances.", "image": "Sunburn",
         "description": "Two-day outdoor festival with multiple stages and food vendors.",
         "hostName": "Festival Productions",
         "hostEmail": "festival@email.com",
         "hostPhone": "(555) 567-8901"]
    ]
    
    @IBOutlet weak var profile: UIBarButtonItem!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupNavigation()
            setupTableView()
            setupMap()
            setupLocationTracking()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        }
    
    
        func setupNavigation() {
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            navBar.backgroundColor = .white
            
            let navigationItem = UINavigationItem(title: "Events")
            
//            profileButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//            profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
//            profileButton.tintColor = .systemBlue
//            profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
//
//            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
            
            view.addSubview(navBar)
            navBar.items = [navigationItem]
            
            navBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navBar.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(EventCell.self, forCellReuseIdentifier: "EventCell")
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.separatorStyle = .none
            tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            view.addSubview(tableView)
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 5)
            ])
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return events.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell else {
                return UITableViewCell()
            }
            let event = events[indexPath.row]
            cell.eventNameLabel.text = event["name"]
            cell.eventDateLabel.text = "Date: \(event["date"] ?? "")"
            cell.eventTimeLabel.text = "Time: \(event["time"] ?? "")"
            cell.eventDescriptionLabel.text = event["description"]
            cell.hostNameLabel.text = event["hostName"]
            cell.hostEmailLabel.text = event["hostEmail"]
            cell.hostPhoneLabel.text = event["hostPhone"]
            if let imageName = event["image"] {
                cell.eventImageView.image = UIImage(named: imageName)
            }
            cell.activateButton.tag = indexPath.row
            cell.locationButton.tag = indexPath.row
            cell.activateButton.addTarget(self, action: #selector(activatePassTapped(_:)), for: .touchUpInside)
            cell.locationButton.addTarget(self, action: #selector(locationButtonTapped(_:)), for: .touchUpInside)
            return cell
        }
        
//    @objc func profileButtonTapped(_ sender: UIButton) {
//            guard let profileVC = UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController else {
//                    print("Error: Could not instantiate ProfileViewController")
//                    return
//            }
//            profileVC.modalPresentationStyle = .fullScreen
//            profileVC.modalTransitionStyle = .coverVertical
//            profileVC.isModalInPresentation = true
//            present(profileVC, animated: true, completion: nil)
//        }
        
        @objc func activatePassTapped(_ sender: UIButton) {
            sender.isEnabled = false
            sender.backgroundColor = .systemGray
            sender.setTitleColor(.white, for: .normal)
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "Access ePass") { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            let alert = UIAlertController(title: "ePass Activated",
                                                       message: "Your ePass code: \(UUID().uuidString.prefix(8))",
                                                       preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        } else {
                            sender.isEnabled = true
                            sender.backgroundColor = .systemRed
                            let alert = UIAlertController(title: "Authentication Failed",
                                                       message: "Unable to authenticate.",
                                                       preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            } else {
                sender.isEnabled = true
                sender.backgroundColor = .systemRed
                let alert = UIAlertController(title: "Biometrics Unavailable",
                                           message: "Face ID or Touch ID is not available on this device.",
                                           preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    
        
    func setupMap() {
            mapView.delegate = self
            mapView.isHidden = true // Keep hidden unless showing location
            view.addSubview(mapView)
            mapView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: view.topAnchor),
                mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

    @objc func locationButtonTapped(_ sender: UIButton) {
        let event = events[sender.tag]
        guard let locationString = event["location"] else { return }
        let coords = locationString.split(separator: ",")
        guard coords.count == 2,
              let lat = Double(coords[0]),
              let lon = Double(coords[1]) else { return }
        
        // Create URL for Apple Maps
        guard let url = URL(string: "maps://?saddr=&daddr=\(lat),\(lon)") else { return }
        
        // Check if Maps app is available
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback to web version if Maps app isn't available
            guard let fallbackUrl = URL(string: "http://maps.apple.com/?saddr=&daddr=\(lat),\(lon)") else { return }
            UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
        }
    }

        // MARK: - Location Tracking
    func setupLocationTracking() {
        locationManager.delegate = self
        
        // Request both permissions
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // Only enable background updates if authorized
        if Bundle.main.infoDictionary?["UIBackgroundModes"] != nil {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            locationManager.allowsBackgroundLocationUpdates = false
        }
        
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
        case .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = false
        default:
            locationManager.allowsBackgroundLocationUpdates = false
        }
    }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to update location: \(error.localizedDescription)")
        }
    }

    class EventCell: UITableViewCell {
        private let mainStackView = UIStackView()
        let eventImageView = UIImageView()
        let eventNameLabel = UILabel()
        let eventDateLabel = UILabel()
        let eventTimeLabel = UILabel()
        let eventDescriptionLabel = UILabel()
        let hostNameLabel = UILabel()
        let hostEmailLabel = UILabel()
        let hostPhoneLabel = UILabel()
        let activateButton = UIButton(type: .system)
        let locationButton = UIButton(type: .system)
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
            setupConstraints()
            setupGestures()
        }
        
        private func setupViews() {
            eventImageView.contentMode = .scaleAspectFill
            eventImageView.clipsToBounds = true
            eventImageView.layer.cornerRadius = 12
            eventImageView.layer.borderWidth = 1
            eventImageView.layer.borderColor = UIColor.systemGray5.cgColor
            
            eventNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            eventNameLabel.numberOfLines = 2
            eventNameLabel.minimumScaleFactor = 0.8
            
            eventDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            eventDateLabel.textColor = .systemGray
            
            eventTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            eventTimeLabel.textColor = .systemGray
            
            eventDescriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            eventDescriptionLabel.numberOfLines = 0
            eventDescriptionLabel.textColor = .systemGray
            
            hostNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            hostNameLabel.textColor = .systemBlue
            
            hostEmailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            hostEmailLabel.textColor = .systemPurple
            
            hostPhoneLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            hostPhoneLabel.textColor = .systemGreen
            
            setupButtons()
            setupStackViews()
        }
        
        private func setupButtons() {
            activateButton.setTitle("Activate", for: .normal)
            activateButton.backgroundColor = .systemRed
            activateButton.setTitleColor(.white, for: .normal)
            activateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            activateButton.layer.cornerRadius = 8
            
            let locationIcon = UIImage(systemName: "location.fill")
            locationButton.setImage(locationIcon, for: .normal)
            locationButton.tintColor = .systemRed
            locationButton.backgroundColor = UIColor.systemGray6
            locationButton.layer.shadowColor = UIColor.black.cgColor
            locationButton.layer.shadowOffset = CGSize(width: 2, height: 2)
            locationButton.layer.shadowOpacity = 0.2
            locationButton.layer.shadowRadius = 2
            locationButton.layer.borderWidth = 1
            locationButton.layer.borderColor = UIColor.systemBlue.cgColor
            locationButton.layer.cornerRadius = 8
        }
        
        private func setupStackViews() {
            mainStackView.axis = .horizontal
            mainStackView.spacing = 16
            mainStackView.alignment = .top
            
            let rightStackView = UIStackView()
            rightStackView.axis = .vertical
            rightStackView.spacing = 8
            
            let dateTimeStackView = UIStackView()
            dateTimeStackView.axis = .vertical
            dateTimeStackView.spacing = 4
            dateTimeStackView.distribution = .fillEqually
            
            dateTimeStackView.addArrangedSubview(eventDateLabel)
            dateTimeStackView.addArrangedSubview(eventTimeLabel)
            
            let detailsStackView = UIStackView(arrangedSubviews: [eventDescriptionLabel, hostNameLabel, hostEmailLabel, hostPhoneLabel])
            detailsStackView.axis = .vertical
            detailsStackView.spacing = 4
            
            let buttonsStackView = UIStackView(arrangedSubviews: [activateButton, locationButton])
            buttonsStackView.axis = .horizontal
            buttonsStackView.spacing = 8
            buttonsStackView.alignment = .center
            
            rightStackView.addArrangedSubview(eventNameLabel)
            rightStackView.addArrangedSubview(dateTimeStackView)
            rightStackView.addArrangedSubview(detailsStackView)
            rightStackView.addArrangedSubview(buttonsStackView)
            
            mainStackView.addArrangedSubview(eventImageView)
            mainStackView.addArrangedSubview(rightStackView)
            
            contentView.addSubview(mainStackView)
        }
        
        private func setupConstraints() {
            mainStackView.translatesAutoresizingMaskIntoConstraints = false
            eventImageView.translatesAutoresizingMaskIntoConstraints = false
            activateButton.translatesAutoresizingMaskIntoConstraints = false
            locationButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
                
                eventImageView.widthAnchor.constraint(equalToConstant: 100),
                eventImageView.heightAnchor.constraint(equalToConstant: 100),
                
                activateButton.heightAnchor.constraint(equalToConstant: 40),
                locationButton.heightAnchor.constraint(equalToConstant: 40),
                locationButton.widthAnchor.constraint(equalToConstant: 40)
            ])
            
            contentView.layer.cornerRadius = 16
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemGray6.cgColor
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            contentView.layer.shadowOpacity = 0.15
            contentView.layer.shadowRadius = 4
            contentView.clipsToBounds = false
        }
        
        private func setupGestures() {
            let emailTap = UITapGestureRecognizer(target: self, action: #selector(handleEmailTap))
            hostEmailLabel.addGestureRecognizer(emailTap)
            hostEmailLabel.isUserInteractionEnabled = true
            
            let phoneTap = UITapGestureRecognizer(target: self, action: #selector(handlePhoneTap))
            hostPhoneLabel.addGestureRecognizer(phoneTap)
            hostPhoneLabel.isUserInteractionEnabled = true
        }
        
        @objc private func handleEmailTap() {
            guard let email = hostEmailLabel.text else { return }
            if let url = URL(string: "mailto:\(email)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        @objc private func handlePhoneTap() {
            guard let phone = hostPhoneLabel.text else { return }
            let formattedPhone = phone.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            if let url = URL(string: "tel:\(formattedPhone)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
