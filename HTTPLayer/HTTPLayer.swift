//
//  HTTPLayer.swift
//  HTTPLayer
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import UIKit

class HTTPLayer {
    enum HTTPMethod: String {
        case get, post, put, delete, options, head, trace, connect
        
        var value: String { self.rawValue.uppercased() }
    }
    
    static let shared = HTTPLayer()
    
    @discardableResult
    func getImage(from url: String, completion: @escaping((Result<UIImage, Error>) -> ())) -> URLSessionDataTask? {
        return HTTPLayer.shared.requestData(method: .get, url: url) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(HTTPLayerError.unableToParseImageError.error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    @discardableResult
    func request<T: Decodable>(method: HTTPMethod, url: String, queryParams: [String: Any] = [:], body: [String: Any] = [:], headers: [String: String] = [:], completion: @escaping((Result<T, Error>) -> ())) -> URLSessionDataTask? {
        return HTTPLayer.shared.requestData(method: method, url: url, queryParams: queryParams, body: body, headers: headers) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let modelObj = try JSONDecoder().decode(T.self, from: data)
                    
                    completion(.success(modelObj))
                } catch let err {
                    completion(.failure(err))
                    
                    do {
                        print("Wrong response:\n\(try JSONSerialization.jsonObject(with: data, options: .mutableContainers))\n")
                    } catch {
                        print("Unable to parse JSON")
                    }
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    @discardableResult
    func requestData(method: HTTPMethod, url: String, queryParams: [String: Any] = [:], body: [String: Any] = [:], headers: [String: String] = [:], completion: @escaping((Result<Data, Error>) -> ())) -> URLSessionDataTask? {
        let completionBlock: (Result<Data, Error>) -> () = { data in
            DispatchQueue.main.async {
                completion(data)
            }
        }
        
        guard var urlComponents = URLComponents(string: url) else {
            completionBlock(.failure(HTTPLayerError.invalidURLError.error))
            
            return nil
        }
        
        urlComponents.query = HTTPLayerHelper.generateQuery(from: queryParams)
        
        guard let finalUrl = urlComponents.url else {
            completionBlock(.failure(HTTPLayerError.invalidURLError.error))
            
            return nil
        }
        
        if !body.isEmpty && method == .get {
            completionBlock(.failure(HTTPLayerError.bodyInGetRequestIsForbiden.error))
            
            return nil
        }
        
        var request = URLRequest(url: finalUrl)
        
        request.httpMethod = method.value
        request.httpBody = HTTPLayerHelper.generateQuery(from: body)?.data(using: .utf8)
        
        headers.forEach { (arg) in
            let (key, value) = arg
            
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("\n\(method.value) \(finalUrl)\n")
            
            guard error == nil else {
                completionBlock(.failure(error!))
                
                return
            }
            
            if let contents = data {
                completionBlock(.success(contents))
            } else {
                completionBlock(.failure(HTTPLayerError.nilResponseDataError.error))
            }
        }
        
        task.resume()
        
        return task
    }
}
