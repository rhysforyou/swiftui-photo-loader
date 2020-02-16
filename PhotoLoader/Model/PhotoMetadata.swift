//
//  PhotoMetadata.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import Foundation

struct PhotoMetadata: Decodable, Identifiable {
    var id: String
    var author: String
    var width: Int
    var height: Int
    var contentURL: URL
    var downloadURL: URL

    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadURL = "downloadUrl"
        case contentURL = "url"
    }
}

#if DEBUG

extension PhotoMetadata {
    static var fixtureData = PhotoMetadata(
        id: "1003",
        author: "E+N Photographies",
        width: 1181,
        height: 1772,
        contentURL: URL(staticString: "https://unsplash.com/photos/U5rMrSI7Pn4"),
        downloadURL: URL(staticString: "https://picsum.photos/id/1025/4951/3301")
    )
}

#endif
