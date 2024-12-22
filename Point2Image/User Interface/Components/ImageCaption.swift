//
//  ImageCaption.swift
//  Point2Image
//
//  Created by Denis.Morozov on 11.12.2024.
//

import SwiftUI

struct ImageCaption: View {
  var caption: String
  
  var body: some View {
    HStack(spacing: 3.0) {
      Image(systemName: "mappin.and.ellipse.circle")
        .imageScale(.small)
        .fontWeight(.light)
      
      Text(caption)
        .font(.caption.monospacedDigit())
        .fontWeight(.semibold)
    }
    .foregroundStyle(.secondary)
    .padding(
      EdgeInsets(top: 3.0, leading: 5.0, bottom: 3.0, trailing: 8.0)
    )
    .background(.ultraThinMaterial)
    .clipShape(Capsule())
  }
}

#Preview {
  ImageCaption(caption: "37.330248, -122.027243")
}
