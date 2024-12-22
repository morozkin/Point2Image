//
//  DistanceBadge.swift
//  Point2Image
//
//  Created by Denis.Morozov on 11.12.2024.
//

import SwiftUI

struct DistanceBadge: View {
  var distance: String
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "figure.walk")
        .foregroundStyle(.green)
      
      Text("You've walked \(distance)")
        .foregroundStyle(.primary)
    }
    .padding(.all, 10)
    .background(.regularMaterial)
    .clipShape(Capsule())
    .shadow(color: .black.opacity(0.08), radius: 5, x: 1, y: 1)
    .shadow(color: .gray.opacity(0.05), radius: 5, x: 0, y: -5)
  }
}

#Preview {
  DistanceBadge(distance: "100 m")
}
