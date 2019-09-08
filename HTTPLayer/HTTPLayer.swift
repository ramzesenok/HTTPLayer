//
//  HTTPLayer.swift
//  HTTPLayer
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import UIKit

class HTTPLayer {
    static let shared = HTTPLayer()
    
    @discardableResult
    func getImage(from url: String, completion: @escaping((Result<UIImage, Error>) -> ())) -> URLSessionDataTask? {
        return HTTPLayer.shared.get(url: url) { (result: Result<Data, Error>) in
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
    func get<T: Decodable>(url: String, queryParams: [String: Any] = [:], headers: [String: String] = [:], completion: @escaping((Result<T, Error>) -> ())) -> URLSessionDataTask? {
        return HTTPLayer.shared.get(url: url, queryParams: queryParams, headers: headers) { (result: Result<Data, Error>) in
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
    
    func get(url: String, queryParams: [String: Any] = [:], headers: [String: String] = [:], completion: @escaping((Result<Data, Error>) -> ())) -> URLSessionDataTask? {
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
        
        var request = URLRequest(url: finalUrl)
        
        headers.forEach { (arg) in
            let (key, value) = arg
            
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("\nGET \(finalUrl)\n")
            
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
