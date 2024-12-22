//
//  Point2ImageApp.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import SwiftUI

@main
struct Point2ImageApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView(
        viewModel: appDelegate.appCointainer.makeImageListViewModel()
      )
    }
  }
}
