import UIKit
import MapKit
import CoreLocation

class GeofenceViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, FenceDataManagerDelegate {
    // MARK: - Outlets
    @IBOutlet var MapOView: MKMapView!

    // MARK: - Variables
    var fenceDataManager = FenceDataManager()
    var searchBar: UISearchBar!
    var fenceCreated = false
    var createFenceIcon: UIBarButtonItem!
    var locationManager = CLLocationManager()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if MapOView == nil {
            MapOView = MKMapView(frame: view.bounds)
            view.addSubview(MapOView)
        }
        MapOView.delegate = self

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        requestLocationPermission()
        let initialLocation = CLLocationCoordinate2D(latitude: 12.823782, longitude: 80.046156)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MapOView.setRegion(region, animated: true)

        setNavigationBarColor(backgroundColor: .black, textColor: .systemBlue)
        setupSearchBar()
        setupIcons()

        fenceDataManager.delegate = self
        fenceDataManager.loadPointsFromUserDefaults()
        displaySavedFencePoints()
    }

    private func displaySavedFencePoints() {
        for point in fenceDataManager.points {
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate
            annotation.title = "Point \(point.pointNumber)"
            MapOView.addAnnotation(annotation)
        }

        if fenceDataManager.points.count >= 3 {
            let sortedFencePoints = sortPointsInClockwiseOrder(points: fenceDataManager.points.map { $0.coordinate })
            let polygon = MKPolygon(coordinates: sortedFencePoints, count: sortedFencePoints.count)
            MapOView.addOverlay(polygon)
            fenceCreated = true
        }
    }

   
    func setNavigationBarColor(backgroundColor: UIColor, textColor: UIColor) {
        guard let navigationBar = navigationController?.navigationBar else {
            print("Navigation bar is not available.")
            return
        }
        navigationBar.barTintColor = backgroundColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        navigationBar.tintColor = textColor
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search for places"
        self.navigationItem.titleView = searchBar
    }

    private func setupIcons() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style:.plain, target: self, action: #selector(backTapped))
        let addPointIcon = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style:.plain, target: self, action: #selector(addPointTapped))
        createFenceIcon = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle.fill"), style:.plain, target: self, action: #selector(createFenceTapped))
        createFenceIcon.isEnabled = false
        let clearFenceIcon = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style:.plain, target: self, action: #selector(clearFenceTapped))
        let recenterIcon = UIBarButtonItem(image: UIImage(systemName: "location.north.fill"), style:.plain, target: self, action: #selector(recenterTapped))
        let toggleMapTypeIcon = UIBarButtonItem(image: UIImage(systemName: "globe.americas.fill"), style:.plain, target: self, action: #selector(toggleMapTypeTapped))
        
        self.navigationItem.leftBarButtonItems = [backButton, addPointIcon, createFenceIcon]
        self.navigationItem.rightBarButtonItems = [recenterIcon, clearFenceIcon, toggleMapTypeIcon]
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func addPointTapped() {
        guard !fenceCreated else {
            showAlert(title: "Fence Created", message: "Clear the existing fence to add new points.")
            return
        }
        let location = MapOView.centerCoordinate
        addFencePoint(at: location)
    }

    @objc func createFenceTapped() {
        guard fenceDataManager.points.count > 2 else {
            showAlert(title: "Error", message: "Need at least 3 points to create a fence.")
            return
        }
        let sortedFencePoints = sortPointsInClockwiseOrder(points: fenceDataManager.points.map { $0.coordinate })
        let polygon = MKPolygon(coordinates: sortedFencePoints, count: sortedFencePoints.count)
        MapOView.addOverlay(polygon)

        fenceCreated = true
        disableDraggableAnnotations()
        createFenceIcon.isEnabled = false
    }

    @objc func clearFenceTapped() {
        MapOView.removeOverlays(MapOView.overlays)
        MapOView.removeAnnotations(MapOView.annotations)
        fenceDataManager.resetPoints()
        fenceCreated = false
        createFenceIcon.isEnabled = false
    }

    @objc func recenterTapped() {
        guard let userLocation = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Unable to get the current location.")
            return
        }
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MapOView.setRegion(region, animated: true)
    }

    @objc func toggleMapTypeTapped() {
        MapOView.mapType = MapOView.mapType == .standard ? .hybrid : .standard
    }

    private func addFencePoint(at coordinate: CLLocationCoordinate2D) {
        let pointNumber = fenceDataManager.points.count + 1
        let newPoint = FencePoint(coordinate: coordinate, pointNumber: pointNumber)
        fenceDataManager.addPoint(newPoint)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Point \(pointNumber)"
        MapOView.addAnnotation(annotation)

        if fenceDataManager.points.count >= 3 {
            createFenceIcon.isEnabled = true
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func sortPointsInClockwiseOrder(points: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        let center = CLLocationCoordinate2D(
            latitude: points.map { $0.latitude }.reduce(0, +) / Double(points.count),
            longitude: points.map { $0.longitude }.reduce(0, +) / Double(points.count)
        )
        return points.sorted {
            atan2($0.latitude - center.latitude, $0.longitude - center.longitude) <
            atan2($1.latitude - center.latitude, $1.longitude - center.longitude)
        }
    }

    private func disableDraggableAnnotations() {
        for annotation in MapOView.annotations {
            if let view = MapOView.view(for: annotation) {
                view.isDraggable = false
            }
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else {
            showAlert(title: "Error", message: "Please enter a location.")
            return
        }

        performLocationSearch(query: query)
    }
    func requestLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationServicesDisabledAlert()
        default:
            locationManager.startUpdatingLocation()
        }
    }

    func showLocationServicesDisabledAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
        // Handle the error appropriately
    }

    // Perform location search using MKLocalSearch
    private func performLocationSearch(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MapOView.region // Search within the current map region

        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            if let error = error {
                self?.showAlert(title: "Search Error", message: error.localizedDescription)
                return
            }

            guard let response = response else {
                self?.showAlert(title: "Error", message: "No locations found.")
                return
            }

            // Remove any existing annotations
            self?.MapOView.removeAnnotations(self?.MapOView.annotations ?? [])

            // Process search results
            let mapItems = response.mapItems
            for item in mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self?.MapOView.addAnnotation(annotation)
            }

            // Center the map on the first search result
            if let firstItem = mapItems.first {
                let newRegion = MKCoordinateRegion(center: firstItem.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self?.MapOView.setRegion(newRegion, animated: true)
            }
        }
    }

    // MARK: - MapView Delegate Methods
    func mapView(_ MapOView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ MapOView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MapOView.dequeueReusableAnnotationView(withIdentifier: "draggableAnnotation") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "draggableAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.canShowCallout = true
        annotationView?.isDraggable = !fenceCreated
        annotationView?.markerTintColor = UIColor.systemBlue
        annotationView?.glyphText = annotation.title ?? ""
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard newState == .ending, let annotation = annotationView.annotation as? MKPointAnnotation,
              let title = annotation.title, title.starts(with: "Point") == true else { return }
        
        if let pointNumber = Int(title.replacingOccurrences(of: "Point ", with: "")) {
            let newCoordinate = annotation.coordinate
            fenceDataManager.updatePoint(at: pointNumber - 1, with: newCoordinate)
        }
    }

    // MARK: - FenceDataManagerDelegate
    func didUpdateFencePoints(points: [FencePoint]) {
        print("Fence points updated: \(points)")
    }
}
