//
//  NetworkResource.swift
//  PhotoLoader
//
//  Created by Rhys Powell on 14/2/20.
//  Copyright © 2020 Rhys Powell. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class NetworkResource<Value>: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var value: Value?
    @Published var error: Error?

    private let urlRequest: URLRequest
    private let parseResponse: (Data, URLResponse) throws -> Value

    private var refreshCancellable: Cancellable?

    init(urlRequest: URLRequest, parseResponse: @escaping (Data, URLResponse) throws -> Value) {
        self.urlRequest = urlRequest
        self.parseResponse = parseResponse
    }

    convenience init(url: URL, parseResponse: @escaping (Data, URLResponse) throws -> Value) {
        let urlRequest = URLRequest(url: url)
        self.init(urlRequest: urlRequest, parseResponse: parseResponse)
    }

    func refresh() {
        isLoading = true
        error = nil
        refreshCancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap(parseResponse)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.error = error
                }
                self.isLoading = false
            }, receiveValue: { value in
                self.value = value
            })
    }

    func cancel() {
        refreshCancellable?.cancel()
        refreshCancellable = nil
    }
}

extension NetworkResource where Value: Decodable {
    convenience init(url: URL, decoder: JSONDecoder) {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        self.init(urlRequest: urlRequest) { data, _ -> Value in
            return try decoder.decode(Value.self, from: data)
        }
    }
}

struct ImageDecodingError: Error, LocalizedError {
    var errorDescription: String? {
        return "Unable to decode image data"
    }
}

extension NetworkResource where Value == UIImage {
    convenience init(imageURL: URL) {
        self.init(url: imageURL) { data, response in
            if let image = UIImage(data: data) {
                return image
            }
            throw ImageDecodingError()
        }
    }
}
