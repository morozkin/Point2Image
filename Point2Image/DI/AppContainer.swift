//
//  AppContainer.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import CoreLocation

final class AppContainer {
  private lazy var httpClient: HTTPClient = HTTPClientImpl()
  
  private var flickrService: FlickrService {
    FlickrServiceImpl(
      httpClient: httpClient,
      urlComposer: urlComposer
    )
  }
  
  private var urlComposer: FlickrAPIURLComposer {
    FlickrAPIURLComposerImpl(apiKey: "YOUR_API_KEY")
  }
  
  private let coreLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.activityType = CLActivityType.fitness
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.allowsBackgroundLocationUpdates = false
    locationManager.showsBackgroundLocationIndicator = true
    return locationManager
  }()
  
  private lazy var locationManager: LocationManager =
    CLLocationManagerWrapper(locationManager: coreLocationManager)
  
  private var locationSessionStreamFactory: LocationSessionDataStreamFactory {
    LocationSessionDataStreamFactoryImpl(locationManager: locationManager)
  }
  
  @MainActor
  func makeImageListViewModel() -> ImageListViewModel {
    ImageListViewModel(
      locationServiceAuthStatusManager: locationManager,
      locationSessionStreamFactory: locationSessionStreamFactory,
      flickrService: flickrService
    )
  }
}
