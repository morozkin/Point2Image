//
//  HTTPClient.swift
//  Point2Image
//
//  Created by Denis.Morozov on 09.12.2024.
//

import Foundation

struct HTTPResponse {
  let data: Data
  let response: HTTPURLResponse
}

protocol HTTPClient: Sendable {
  func get(url: URL) async -> Result<HTTPResponse, Error>
}

final class HTTPClientImpl: HTTPClient {
  func get(url: URL) async -> Result<HTTPResponse, any Error> {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse else {
        return .failure(URLError(.badServerResponse))
      }
      
      return .success(
        HTTPResponse(data: data, response: httpResponse)
      )
    } catch {
      return .failure(error)
    }
  }
}
