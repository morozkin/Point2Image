//
//  ImageListViewModel.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import Combine
import Foundation
import Observation

@Observable
@MainActor
final class ImageListViewModel {
  struct CaptionedImage: Identifiable {
    let id: String
    let url: URL
    let caption: String
  }
  
  enum State {
    case empty
    case noLocationAccessPermissions
    case timeline(distance: String, images: [CaptionedImage], isRecording: Bool)
    
    var isRecording: Bool {
      switch self {
      case .empty, .noLocationAccessPermissions:
        false
      case let .timeline(_, _, isRecording):
        isRecording
      }
    }
    
    var isRecordingAvailable: Bool {
      switch self {
      case .noLocationAccessPermissions:
        false
      case .empty, .timeline:
        true
      }
    }
  }
  
  private(set) var state = State.noLocationAccessPermissions
  
  private let distanceFormatter = Measurement<UnitLength>.FormatStyle(width: .abbreviated, usage: .road)
  
  private let locationServiceAuthStatusManager: LocationServiceAuthStatusManager
  private let locationSessionStreamFactory: LocationSessionDataStreamFactory
  private let flickrService: FlickrService
  
  @ObservationIgnored
  private var cancellables = [AnyCancellable]()
  
  @ObservationIgnored
  private var trackingTask: Task<Void,Never>? = nil
  
  @ObservationIgnored
  private var displayedImageIds = Set<String>()
  
  init(
    locationServiceAuthStatusManager: LocationServiceAuthStatusManager,
    locationSessionStreamFactory: LocationSessionDataStreamFactory,
    flickrService: FlickrService
  ) {
    self.locationServiceAuthStatusManager = locationServiceAuthStatusManager
    self.locationSessionStreamFactory = locationSessionStreamFactory
    self.flickrService = flickrService
    
    setupBindings()
  }
  
  // MARK: - Public methods
  
  func startTracking() {
    guard state.isRecordingAvailable, !state.isRecording else {
      return
    }
    
    displayedImageIds.removeAll()
    
    trackingTask = Task {
      guard await locationServiceAuthStatusManager.requestAuthorization() == .authorized else { return }
      
      state = .timeline(
        distance: Measurement(value: 0, unit: UnitLength.meters).formatted(distanceFormatter),
        images: [],
        isRecording: true
      )
      
      let locationSessionDataStream = locationSessionStreamFactory.makeLocationSessionDataStream()
      
      for await locationSessionData in locationSessionDataStream {
        guard let locationPoint = locationSessionData.locationPoints.last else { continue }
        
        let photos = await flickrService.getPhotosWithGeoData(
          latitude: locationPoint.latitude,
          longitude: locationPoint.longitude
        )
        
        if let photo = photos?.first(where: { !displayedImageIds.contains($0.id) }) {
          displayedImageIds.insert(photo.id)
          
          var existingImages: [CaptionedImage]
          if case let .timeline(_, images, _) = state {
            existingImages = images
          } else {
            existingImages = []
          }
          
          // Extract this logic somewhere...
          let url = URL(string: "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_c.jpg")!
          
          existingImages.insert(CaptionedImage(id: photo.id, url: url, caption: "\(photo.latitude), \(photo.longitude)"), at: 0)
          
          state = .timeline(
            distance: locationSessionData.distance.formatted(distanceFormatter),
            images: existingImages,
            isRecording: true
          )
        }
      }
      
      if Task.isCancelled {
        return
      }
      
      if case let .timeline(distance, images, _) = state {
        state = .timeline(
          distance: distance,
          images: images,
          isRecording: false
        )
      }
    }
  }
  
  func stopTracking() {
    guard
      case let .timeline(distance, images, isRecording) = state,
      isRecording == true
    else {
      return
    }
    
    trackingTask?.cancel()
    trackingTask = nil
    
    state = .timeline(distance: distance, images: images, isRecording: false)
  }
  
  // MARK: - Private methods
  
  private func setupBindings() {
    locationServiceAuthStatusManager.authorizationStatusPublisher
      .receive(on: RunLoop.main)
      .sink { [unowned self] authState in
        switch authState {
        case .authorized:
          self.state = .empty
          
        case .denied:
          self.trackingTask?.cancel()
          self.trackingTask = nil
          
          self.state = .noLocationAccessPermissions
          
        case .notDetermined:
          self.state = .empty
        }
      }
      .store(in: &cancellables)
  }
}
