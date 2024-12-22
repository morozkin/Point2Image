//
//  TimelineView.swift
//  Point2Image
//
//  Created by Denis.Morozov on 20.12.2024.
//

import SwiftUI

struct TimelineView: View {
  var images: [ImageListViewModel.CaptionedImage]
  
  var body: some View {
    List {
      ForEach(images) { image in
        AsyncImage(url: image.url) { phase in
          switch phase {
          case .empty, .failure:
            Color.gray
              .opacity(0.2)
              .frame(width: UIScreen.main.bounds.width - 20.0, height: UIScreen.main.bounds.width * 0.6)
              .clipShape(
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
              )
            
          case let .success(imageView):
            imageView
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: UIScreen.main.bounds.width - 20.0, height: UIScreen.main.bounds.width * 0.6)
              .clipShape(
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
              )
              .overlay(alignment: .bottomTrailing) {
                ImageCaption(caption: image.caption)
                  .padding(
                    EdgeInsets(top: 0.0, leading: 0.0, bottom: 10.0, trailing: 10.0)
                  )
              }
            
          @unknown default:
            fatalError()
          }
        }
        .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
  }
}
