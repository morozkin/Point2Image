//
//  LoadingView.swift
//  Point2Image
//
//  Created by Denis.Morozov on 20.12.2024.
//

import SwiftUI

struct LoadingView: View {
  var body: some View {
    VStack {
      Spacer()
      ProgressView()
      Spacer()
    }
  }
}

#Preview {
  LoadingView()
}
