//
//  URL+Static.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 15/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import Foundation

extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
