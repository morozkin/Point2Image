//
//  ContentView.swift
//  Point2Image
//
//  Created by Denis.Morozov on 06.12.2024.
//

import SwiftUI

struct ContentView: View {
  var viewModel: ImageListViewModel
  
  var body: some View {
    Group {
      switch viewModel.state {
      case .empty:
        StartView()
        
      case .noLocationAccessPermissions:
        NoLocationAccessPermissionsView()
        
      case let .timeline(distance, images, _):
        Group {
          if !images.isEmpty {
            TimelineView(images: images)
          } else {
            LoadingView()
          }
        }
        .safeAreaInset(edge: .top) {
          DistanceBadge(distance: distance)
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      if viewModel.state.isRecordingAvailable {
        RecordButton(isRecording: viewModel.state.isRecording) {
          if !viewModel.state.isRecording {
            viewModel.startTracking()
          } else {
            viewModel.stopTracking()
          }
        }
      }
    }
  }
}
