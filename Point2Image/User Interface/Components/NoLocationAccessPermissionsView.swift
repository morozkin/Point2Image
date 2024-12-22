//
//  NoLocationAccessPermissionsView.swift
//  Point2Image
//
//  Created by Denis.Morozov on 11.12.2024.
//

import SwiftUI

struct NoLocationAccessPermissionsView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "location.slash.circle.fill")
        .foregroundStyle(.green)
        .font(
          .system(size: 60, weight: .semibold)
        )
      
      Text("Access to location services is disabled.")
        .foregroundStyle(.primary)
        .font(.body)
      
      Link("Allow location access in the settings",
           destination: URL(string: UIApplication.openSettingsURLString)!)
    }
  }
}

#Preview {
  NoLocationAccessPermissionsView()
}
