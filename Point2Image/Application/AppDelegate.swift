//
//  AppDelegate.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  private(set) var appCointainer: AppContainer!
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    appCointainer = AppContainer()
    return true
  }
}
