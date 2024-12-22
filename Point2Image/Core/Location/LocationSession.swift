//
//  LocationSession.swift
//  Point2Image
//
//  Created by Denis.Morozov on 08.12.2024.
//

import Combine
import CoreLocation
import Foundation
import os

struct LocationSessionData {
  let distance: Measurement<UnitLength>
  fileprivate let location: [CLLocation]
  
  var locationPoints: [CLLocationCoordinate2D] {
    location.map { $0.coordinate }
  }
  
  fileprivate static let Empty = LocationSessionData(distance: .init(value: 0, unit: .meters), location: [])
}

// MARK: - LocationSessionDataStreamFactory

protocol LocationSessionDataStreamFactory: Sendable {
  func makeLocationSessionDataStream() -> AsyncStream<LocationSessionData>
}

final class LocationSessionDataStreamFactoryImpl: LocationSessionDataStreamFactory {
  private let locationManager: LocationManager
  
  init(locationManager: LocationManager) {
    self.locationManager = locationManager
  }
  
  func makeLocationSessionDataStream() -> AsyncStream<LocationSessionData> {
    let localLocationManager = locationManager
    
    return AsyncStream { continuation in
      let session = LocationSession(
        locationManager: localLocationManager,
        continuation: continuation
      )
      
      continuation.onTermination = { @Sendable _ in
        session.stopTracking()
      }
      
      session.startTracking()
    }
  }
}

// MARK: - LocationSession

private final class LocationSession: @unchecked Sendable {
  private enum State {
    case initialized
    case running
    case finished
  }
  
  private let state = OSAllocatedUnfairLock(initialState: State.initialized)
  
  private var cancellables = [AnyCancellable]()
  
  private let locationManager: LocationManager
  private let continuation: AsyncStream<LocationSessionData>.Continuation
  
  // MARK: - Init
  
  init(
    locationManager: LocationManager,
    continuation: AsyncStream<LocationSessionData>.Continuation
  ) {
    self.locationManager = locationManager
    self.continuation = continuation
  }
  
  // MARK: - Public methods
  
  func startTracking() {
    guard
      state.withLock({ $0 }) == .initialized,
      locationManager.authorizationStatus == .authorized
    else {
      return
    }
    
    state.withLock {
      $0 = .running
    }
    
    subscribeToUpdates()
    
    locationManager.startUpdatingLocation()
  }
  
  func stopTracking() {
    guard state.withLock({ $0 }) == .running else { return }
    
    let oldState = state.withLock {
      let old = $0
      $0 = .finished
      return old
    }
    
    if oldState == .running {
      cleanUp()
    }
  }
  
  // MARK: - Private methods
  
  private func subscribeToUpdates() {
    locationManager.liveUpdates
      .first { update in
        switch update {
        case .error:
          true
        case .location:
          false
        }
      }
      .sink { [unowned self] _ in
        let oldState = state.withLock {
          let old = $0
          $0 = .finished
          return old
        }
        
        if oldState == .running {
          cleanUp()
        }
        
        continuation.finish()
      }
      .store(in: &cancellables)
    
    locationManager.liveUpdates
      .filter { update in
        if case .location = update {
          return true
        } else {
          return false
        }
      }
      .removeDuplicates(by: { oldUpdate, newUpdate in
        guard
          case let .location(oldLocation) = oldUpdate,
          case let .location(newLocation) = newUpdate
        else {
          return false
        }
        
        // assume two locations are similar if they are less than 50 meters apart
        return newLocation.distance(from: oldLocation) < 50
      })
      .scan(LocationSessionData.Empty, { prevData, locationUpdate in
        let location: CLLocation
        if case let .location(loc) = locationUpdate {
          location = loc
        } else {
          fatalError()
        }
        
        let allLocations = prevData.location + [location]
        
        return LocationSessionData(
          distance: allLocations.distance,
          location: allLocations
        )
      })
      .sink { [unowned self] data in
        continuation.yield(data)
      }
      .store(in: &cancellables)
  }
  
  private func cleanUp() {
    locationManager.stopUpdatingLocation()
    cancellables.forEach { $0.cancel() }
  }
}

private extension Array where Element: CLLocation {
  var distance: Measurement<UnitLength> {
    guard count > 1 else {
      return Measurement(value: 0, unit: .meters)
    }
    
    let distanceInMeters = reduce((location: self[0], distance: 0)) { partialResult, nextLocation in
      return (
        nextLocation,
        partialResult.distance + partialResult.location.distance(from: nextLocation)
      )
    }.distance
    
    return Measurement(value: distanceInMeters, unit: .meters)
  }
}
