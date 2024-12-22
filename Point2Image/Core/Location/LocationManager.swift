//
//  LocationServiceAuthStatusProvider.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import CoreLocation
import Combine
import os

enum LocationUpdate {
  case location(CLLocation)
  case error(Error)
}

protocol LocationManager: LocationServiceAuthStatusManager, Sendable {
  var liveUpdates: AnyPublisher<LocationUpdate, Never> { get }
  
  func startUpdatingLocation()
  func stopUpdatingLocation()
}

final class CLLocationManagerWrapper: NSObject, LocationManager, CLLocationManagerDelegate, @unchecked Sendable {
  private let logger: Logger = Logger(
    subsystem: "com.morozkin.Point2Image",
    category: "CLLocationManagerWrapper"
  )
  
  // MARK: - LocationServiceAuthStatusProvider properties
  
  private let authorizationStatusSubject: CurrentValueSubject<LocationServiceAuthStatus, Never>

  var authorizationStatus: LocationServiceAuthStatus {
    authorizationStatusSubject.value
  }
  
  let authorizationStatusPublisher: AnyPublisher<LocationServiceAuthStatus, Never>
  
  // MARK: - LocationManager properties
  
  private let _liveUpdates = PassthroughSubject<LocationUpdate, Never>()
  let liveUpdates: AnyPublisher<LocationUpdate, Never>
  
  // MARK: -
  
  private let updateRequestsCount = OSAllocatedUnfairLock(initialState: 0)
  
  private let locationManager: CLLocationManager
  
  // MARK: - Init
  
  init(locationManager: CLLocationManager) {
    self.locationManager = locationManager
    self.authorizationStatusSubject = CurrentValueSubject(locationManager.authorizationStatus.toLocationServiceAuthState())
    
    self.authorizationStatusPublisher = authorizationStatusSubject
      .removeDuplicates()
      .eraseToAnyPublisher()
    
    self.liveUpdates = _liveUpdates
      .buffer(size: 10, prefetch: .byRequest, whenFull: .dropOldest)
      .eraseToAnyPublisher()
    
    super.init()
    
    locationManager.delegate = self
  }
  
  // MARK: - Public methods
  
  func requestAuthorization() async -> LocationServiceAuthStatus {
    switch authorizationStatus {
    case .authorized:
      return .authorized
    
    case .notDetermined:
      logger.debug("Requesting WhenInUse authorization")
      
      locationManager.requestWhenInUseAuthorization()
      return await authorizationStatusSubject.values
        .first { $0 != .notDetermined } ?? .notDetermined
    
    case .denied:
      return .denied
    }
  }
  
  func startUpdatingLocation() {
    let count = updateRequestsCount.withLock { counter in
      counter += 1
      return counter
    }
    
    guard count == 1 else { return }
    
    logger.debug("Start updating location")
    
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    let count = updateRequestsCount.withLock { counter in
      counter = max(0, counter - 1)
      return counter
    }
    
    guard count == 0 else { return }
    
    logger.debug("Stop updating location")
    
    locationManager.stopUpdatingLocation()
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    logger.debug("Location manager's authorization status has changed to \(status.rawValue)")
    authorizationStatusSubject.send(status.toLocationServiceAuthState())
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    logger.debug("Location manager has updated locations: \(locations)")
    locations.forEach {
      _liveUpdates.send(
        .location($0)
      )
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    logger.error("Location manager did fail with error: \(error)")
    
    if
      (error as NSError).domain == kCLErrorDomain,
      (error as NSError).code == CLError.denied.rawValue
    {
      _liveUpdates.send(
        .error(error)
      )
    }
  }
}

private extension CLAuthorizationStatus {
  func toLocationServiceAuthState() -> LocationServiceAuthStatus {
    return switch self {
    case .notDetermined:
        .notDetermined
    case .restricted:
        .denied
    case .denied:
        .denied
    case .authorizedAlways:
        .authorized
    case .authorizedWhenInUse:
        .authorized
    case .authorized:
        .authorized
    @unknown default:
      fatalError()
    }
  }
}
