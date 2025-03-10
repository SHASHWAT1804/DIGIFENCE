// FencePoint.swift
import CoreLocation

struct FenceP {
    var coordinate: CLLocationCoordinate2D
    var pointNumber: Int
}

// FenceDataManager.swift
import Foundation

protocol FenceDataMDelegate: AnyObject {
    func didUpdateFencePoints(points: [FencePoint])
}

class FenceDataM {
    private(set) var points: [FencePoint] = []
    weak var delegate: FenceDataManagerDelegate?
    
    func addPoint(_ point: FencePoint) {
        points.append(point)
        delegate?.didUpdateFencePoints(points: points)
    }
    
    func updatePoint(at index: Int, with coordinate: CLLocationCoordinate2D) {
        guard index >= 0 && index < points.count else { return }
        points[index].coordinate = coordinate
        delegate?.didUpdateFencePoints(points: points)
    }
    
    func resetPoints() {
        points.removeAll()
        delegate?.didUpdateFencePoints(points: points)
    }
}
