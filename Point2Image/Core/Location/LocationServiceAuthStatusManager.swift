//
//  LocationServiceAuthStatusManager.swift
//  Point2Image
//
//  Created by Denis.Morozov on 12.12.2024.
//

import Combine

enum LocationServiceAuthStatus {
  case authorized
  case notDetermined
  case denied
}

protocol LocationServiceAuthStatusProvider {
  var authorizationStatus: LocationServiceAuthStatus { get }
  var authorizationStatusPublisher: AnyPublisher<LocationServiceAuthStatus, Never> { get }
}

protocol LocationServiceAuthStatusManager: LocationServiceAuthStatusProvider, Sendable {
  func requestAuthorization() async -> LocationServiceAuthStatus
}
