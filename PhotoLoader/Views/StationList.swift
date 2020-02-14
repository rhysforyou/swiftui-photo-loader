//
//  StationList.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import SwiftUI

struct StationList: View {
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
                    Text(metadata.author)
                }
            }
        }
        .onAppear(perform: resource.refresh)
        .onDisappear(perform: resource.cancel)
        .navigationBarTitle("Photos")
        .navigationBarItems(trailing: refreshButton)
    }
}

struct StationList_Previews: PreviewProvider {
    static var previews: some View {
        StationList()
    }
}
