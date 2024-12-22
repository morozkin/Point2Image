//
//  FlickrAPIURLComposer.swift
//  Point2Image
//
//  Created by Denis.Morozov on 10.12.2024.
//

import Foundation

protocol FlickrAPIURLComposer: Sendable {
  func composeGetWithGeoDataURL(latitude: Double, longitude: Double) -> URL
}

final class FlickrAPIURLComposerImpl: FlickrAPIURLComposer {
  private static let baseURL = "https://www.flickr.com"
  
  private let apiKey: String
  
  init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  func composeGetWithGeoDataURL(latitude: Double, longitude: Double) -> URL {
    var urlComponents = URLComponents(string: Self.baseURL)!
    
    urlComponents.path = "/services/rest"
    
    urlComponents.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "method", value: "flickr.photos.search"),
      URLQueryItem(name: "accuracy", value: "16"),
      URLQueryItem(name: "lat", value: String(latitude)),
      URLQueryItem(name: "lon", value: String(longitude)),
      URLQueryItem(name: "radius", value: "3"),
      URLQueryItem(name: "radius_units", value: "km"),
      URLQueryItem(name: "per_page", value: "10"),
      URLQueryItem(name: "extras", value: "geo"),
      URLQueryItem(name: "format", value: "json"),
      URLQueryItem(name: "nojsoncallback", value: "1")
    ]
    
    return urlComponents.url!
  }
}
