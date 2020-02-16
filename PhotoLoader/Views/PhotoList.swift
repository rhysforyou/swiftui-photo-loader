//
//  PhotoList.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import SwiftUI

struct PhotoList: View {
    @ObservedObject var resource: NetworkResource<[PhotoMetadata]>

    init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        resource = NetworkResource(url: URL(string: "https://picsum.photos/v2/list")!, decoder: decoder)
    }

    var refreshButton: some View {
        Button(action: resource.refresh, label: {
            if resource.isLoading {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            } else {
                Image(systemName: "arrow.clockwise")
                    .accessibility(label: Text("Refresh"))
            }
        }).disabled(resource.isLoading)
    }

    var body: some View {
        List {
            if resource.error != nil {
                HStack {
                    Image(systemName: "xmark.octagon")
                    Text(resource.error!.localizedDescription)
                }
                .foregroundColor(.white)
                .listRowBackground(Color.red)
            }

            ForEach(resource.value ?? []) { metadata in
                NavigationLink(destination: PhotoDetail(metadata: metadata)) {
                    PhotoListItem(metadata: metadata)
                }
            }
        }
        .onAppear(perform: resource.refresh)
        .onDisappear(perform: resource.cancel)
        .navigationBarTitle("Photos")
        .navigationBarItems(trailing: refreshButton)
    }
}

struct PhotoListItem: View {
    let metadata: PhotoMetadata
    @ObservedObject var thumbnailResource: NetworkResource<Image>

    init(metadata: PhotoMetadata) {
        self.metadata = metadata
        self.thumbnailResource = NetworkResource(imageURL: metadata.thumbnailURL)
    }

    var body: some View {
        HStack {
            Group {
                if thumbnailResource.value != nil {
                    thumbnailResource.value!
                        .resizable()
                } else {
                    Color(UIColor.secondarySystemBackground)
                }
            }
            .frame(width: 44, height: 44)
            .cornerRadius(8)
            Text(metadata.author)
        }
        .onAppear(perform: thumbnailResource.refresh)
        .onDisappear(perform: thumbnailResource.cancel)
    }
}

#if DEBUG

struct PhotoListItem_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListItem(metadata: .fixtureData)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

#endif
