//
//  StartView.swift
//  Point2Image
//
//  Created by Denis.Morozov on 11.12.2024.
//

import SwiftUI

struct StartView: View {
  var body: some View {
    VStack(spacing: 20) {
      Spacer()
      
      Image(systemName: "figure.walk.motion")
        .foregroundStyle(.green)
        .font(
          .system(size: 60, weight: .semibold)
        )
      
      Text("Let's have some movement!")
        .foregroundStyle(.primary)
        .font(.headline)
      
      Spacer()
    }
  }
}

#Preview {
  StartView()
}
