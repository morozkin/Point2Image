//
//  FlickrService.swift
//  Point2Image
//
//  Created by Denis.Morozov on 09.12.2024.
//

import Foundation
import os

// move to a separate file
struct FlickrPhoto: Codable {
  let id: String
  let secret: String
  let server: String
  let latitude: String
  let longitude: String
}

private struct FlickrPhotosResponse: Codable {
  struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let total: Int
    let photo: [FlickrPhoto]
  }
  
  let stat: String
  let photos: FlickrPhotos?
}

protocol FlickrService: Sendable {
  func getPhotosWithGeoData(latitude: Double, longitude: Double) async -> [FlickrPhoto]?
}

final class FlickrServiceImpl: FlickrService {
  private let logger = Logger(
    subsystem: "com.morozkin.Point2Image",
    category: "FlickrServiceImpl"
  )
  
  private let httpClient: HTTPClient
  private let urlComposer: FlickrAPIURLComposer
  
  init(
    httpClient: HTTPClient,
    urlComposer: FlickrAPIURLComposer
  ) {
    self.httpClient = httpClient
    self.urlComposer = urlComposer
  }
  
  func getPhotosWithGeoData(
    latitude: Double,
    longitude: Double
  ) async -> [FlickrPhoto]? {
    logger.debug(
      "Starting `getPhotosWithGeoData` request for latitude: \(latitude); longitude: \(longitude)"
    )
    
    let url = urlComposer.composeGetWithGeoDataURL(latitude: latitude, longitude: longitude)
    let result = await httpClient.get(url: url)
    
    switch result {
    case let .success(response):
      logger.debug(
        "Finished `getPhotosWithGeoData` request with success for latitude: \(latitude); longitude: \(longitude)"
      )
      
      guard
        response.response.statusCode == 200,
        response.response.mimeType == "application/json"
      else {
        return nil
      }
      
      do {
        let flickrPhotosResponse = try JSONDecoder().decode(FlickrPhotosResponse.self, from: response.data)
        return flickrPhotosResponse.photos?.photo
      } catch {
        logger.error(
          "Unable to parse `getPhotosWithGeoData` request's response with error: \(error)"
        )
        return nil
      }
      
    case let .failure(error):
      logger.error(
        "Finished `getPhotosWithGeoData` request with error [\(error)] for latitude: \(latitude); longitude: \(longitude)"
      )
      return nil
    }
  }
}
