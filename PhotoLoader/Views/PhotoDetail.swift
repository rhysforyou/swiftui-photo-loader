//
//  PhotoDetail.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import SwiftUI

struct PhotoDetail: View {
    let metadata: PhotoMetadata
    @ObservedObject var imageResource: NetworkResource<Image>

    init(metadata: PhotoMetadata) {
        self.metadata = metadata
        self.imageResource = NetworkResource(imageURL: metadata.downloadURL)
    }

    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            List {
                PhotoDetailError(
                    error: self.imageResource.error,
                    performRetry: self.imageResource.refresh
                )

                PhotoDetailImage(
                    metadata: self.metadata,
                    image: self.imageResource.value
                ).frame(maxHeight: geometry.size.height - 16)

                PhotoDetailMetadata(metadata: self.metadata)
            }
            .navigationBarTitle("Details", displayMode: .inline)
            .onAppear(perform: self.imageResource.refresh)
            .onDisappear(perform: self.imageResource.cancel)
        }
    }
}

private struct PhotoDetailError: View {
    var error: Error?
    var performRetry: () -> Void

    var body: some View {
        Group {
            if error != nil {
                Button(action: performRetry) {
                    HStack {
                        Image(systemName: "xmark.octagon")
                        Text(error!.localizedDescription)
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.red)
            }
        }
    }
}

private struct PhotoDetailMetadata: View {
    var metadata: PhotoMetadata

    var body: some View {
        Group {
            HStack {
                Image(systemName: "person.fill")
                Text(metadata.author)
            }

            HStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                Text("\(metadata.width) ✕ \(metadata.height) pixels")
            }

            Button(action: {
                UIApplication.shared.open(self.metadata.contentURL)
            }, label:  {
                HStack {
                    Image(systemName: "safari")
                    Text("View on Unsplash")
                }
            })
            .foregroundColor(Color.accentColor)
        }
    }
}

private struct PhotoDetailImage: View {
    let metadata: PhotoMetadata
    let image: Image?

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Color(UIColor.secondarySystemBackground)
                if image != nil {
                    image!.resizable()
                }
            }
            .aspectRatio(CGFloat(self.metadata.width) / CGFloat(self.metadata.height), contentMode: .fit)
            .cornerRadius(8)
            Spacer()
        }
    }
}

#if DEBUG

struct PhotoDetail_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            PhotoDetail(metadata: .fixtureData)
            PhotoDetail(metadata: .fixtureData)
                .previewLayout(.fixed(width: 375, height: 400))
        }
    }
}

#endif
