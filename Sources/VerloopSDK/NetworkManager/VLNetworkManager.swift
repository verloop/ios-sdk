//
//  VLNetworkManager.swift
//  VerloopSDK
//
//  Created by Mujahid Ali on 22/02/2024.
//  Copyright © 2024 Verloop. All rights reserved.
//

import Foundation

struct VLNetworkManagerRequestComponents {
    var headers: [String: String]?
    var method: VLHTTPMethod
    var parameters: [String: String]?
}

enum VLHTTPMethod: String {
    case get = "GET"
}

enum VLNetworkError: Error {
    case invalidURL
    case invalidRequest
    case failedRequest(Error)
}

protocol VLNetworkManagerProtocol {
    func request(url: String, requestComponents: VLNetworkManagerRequestComponents?, completion: @escaping (Result<Data?, VLNetworkError>) -> Void)
}

final class VLNetworkManager {
    
    static let shared = VLNetworkManager()
    private init() {}
    private let session = URLSession.shared
    
    func request(url: String, requestComponents: VLNetworkManagerRequestComponents?, completion: @escaping (Result<Data?, VLNetworkError>) -> Void) {
        
        guard let urlRequest = createURLRequest(url: url, requestComponents: requestComponents) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.failedRequest(error)))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(.invalidRequest))
                return
            }
            
            completion(.success(responseData))
        }
        task.resume()
    }
    
    private func createURLRequest(url: String, requestComponents: VLNetworkManagerRequestComponents?) -> URLRequest? {
        guard var urlComponents = URLComponents(string: url) else { return nil }
        
        if let queryParams = requestComponents?.parameters {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let composedURL = urlComponents.url else { return nil }
        
        var request = URLRequest(url: composedURL)
        request.httpMethod = requestComponents?.method.rawValue
        
        if let headers = requestComponents?.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
