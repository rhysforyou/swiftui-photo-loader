//
//  PhotoDetail.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import SwiftUI

struct ImageDecodingError: Error, LocalizedError {
    var errorDescription: String? {
        return "Unable to decode image data"
    }
}

struct PhotoDetail: View {
    let metadata: PhotoMetadata
    @ObservedObject var imageResource: NetworkResource<UIImage>

    init(metadata: PhotoMetadata) {
        self.metadata = metadata
        self.imageResource = NetworkResource(url: metadata.downloadURL) { data, response in
            if let image = UIImage(data: data) {
                return image
            }
            throw ImageDecodingError()
        }
    }

    var body: some View {
        List {
            if imageResource.error != nil {
                Button(action: imageResource.refresh) {
                    HStack {
                        Image(systemName: "xmark.octagon")
                        Text(imageResource.error!.localizedDescription)
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.red)
            }

            ZStack {
                Color(UIColor.secondarySystemBackground)
                if imageResource.value != nil {
                    Image(uiImage: imageResource.value!)
                        .resizable()
                }
            }
            .aspectRatio(CGFloat(metadata.width) / CGFloat(metadata.height), contentMode: .fit)
            .cornerRadius(8)

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
        .navigationBarTitle("Details", displayMode: .inline)
        .onAppear(perform: imageResource.refresh)
        .onDisappear(perform: imageResource.cancel)
    }
}
