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
