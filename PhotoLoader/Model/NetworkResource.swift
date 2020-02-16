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
    private let cache: URLCache?
    private let parseResponse: (Data, URLResponse) throws -> Value

    private var refreshCancellable: Cancellable?

    init(urlRequest: URLRequest, cache: URLCache? = .shared, parseResponse: @escaping (Data, URLResponse) throws -> Value) {
        self.urlRequest = urlRequest
        self.cache = cache
        self.parseResponse = parseResponse
    }

    convenience init(url: URL, cache: URLCache? = .shared, parseResponse: @escaping (Data, URLResponse) throws -> Value) {
        let urlRequest = URLRequest(url: url)
        self.init(urlRequest: urlRequest,
                  cache: cache,
                  parseResponse: parseResponse)
    }

    func refresh() {
        isLoading = true
        error = nil
        refreshCancellable = responsePublisher
            .handleEvents(receiveOutput: storeCachedResponse)
            .tryMap(parseResponse)
            .receive(on: DispatchQueue.main)
            .print()
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

    private var responsePublisher: AnyPublisher<(data: Data, response: URLResponse), URLError> {
        if let cachedResponse = cache?.cachedResponse(for: urlRequest) {
            return Just((data: cachedResponse.data, response: cachedResponse.response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        } else {
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .eraseToAnyPublisher()
        }
    }

    private func storeCachedResponse(data: Data, response: URLResponse) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache?.storeCachedResponse(cachedResponse, for: urlRequest)
    }
}

extension NetworkResource where Value: Decodable {
    convenience init(url: URL, cache: URLCache? = .shared, decoder: JSONDecoder) {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        self.init(urlRequest: urlRequest, cache: cache) { data, _ -> Value in
            return try decoder.decode(Value.self, from: data)
        }
    }
}

struct ImageDecodingError: Error, LocalizedError {
    var errorDescription: String? {
        return "Unable to decode image data"
    }
}

extension NetworkResource where Value == Image {
    convenience init(imageURL: URL, cache: URLCache? = .shared) {
        self.init(url: imageURL, cache: cache) { data, response in
            if let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
            throw ImageDecodingError()
        }
    }
}
