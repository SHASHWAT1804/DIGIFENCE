import Foundation
import CoreLocation

protocol FenceDataManagerDelegate: AnyObject {
    func didUpdateFencePoints(points: [FencePoint])
}

class FenceDataManager {
    weak var delegate: FenceDataManagerDelegate?
    private let fenceKey = "savedFencePoints"
    
    var points: [FencePoint] = [] {
        didSet {
            savePointsToUserDefaults()
            delegate?.didUpdateFencePoints(points: points)
        }
    }
    
    func addPoint(_ point: FencePoint) {
        points.append(point)
    }

    func updatePoint(at index: Int, with coordinate: CLLocationCoordinate2D) {
        guard points.indices.contains(index) else { return }
        points[index].coordinate = coordinate
    }

    func resetPoints() {
        points.removeAll()
    }

    func savePointsToUserDefaults() {
        let data = points.map { ["latitude": $0.coordinate.latitude, "longitude": $0.coordinate.longitude, "pointNumber": $0.pointNumber] }
        UserDefaults.standard.set(data, forKey: fenceKey)
    }

    func loadPointsFromUserDefaults() {
        guard let savedData = UserDefaults.standard.array(forKey: fenceKey) as? [[String: Any]] else { return }
        points = savedData.compactMap { dict in
            guard let latitude = dict["latitude"] as? CLLocationDegrees,
                  let longitude = dict["longitude"] as? CLLocationDegrees,
                  let pointNumber = dict["pointNumber"] as? Int else { return nil }
            return FencePoint(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), pointNumber: pointNumber)
        }
    }
}

struct FencePoint {
    var coordinate: CLLocationCoordinate2D
    var pointNumber: Int
}
