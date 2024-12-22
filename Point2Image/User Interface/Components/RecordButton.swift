//
//  RecordButton.swift
//  Point2Image
//
//  Created by Denis.Morozov on 11.12.2024.
//

import SwiftUI

struct RecordButton: View {
  var isRecording: Bool
  var action: () -> Void
  
  var body: some View {
    ZStack {
      Circle()
        .fill(.ultraThinMaterial)
        .frame(width: 60, height: 60)
      
      Circle()
        .fill(.white)
        .frame(width: 50, height: 50)
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 3)
      
      if !isRecording {
        Circle()
          .fill(Color.green)
          .frame(width: 15, height: 15)
      } else {
        RoundedRectangle(cornerRadius: 2.0)
          .fill(Color.red)
          .frame(width: 15, height: 15)
      }
    }
    .gesture(
      TapGesture(count: 1).onEnded {
        action()
      }
    )
  }
}
