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
    
    func getImage(from url: String, completion: @escaping((Result<UIImage, Error>) -> ())) {
        HTTPLayer.shared.get(url: url) { (result: Result<Data, Error>) in
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
    
    func get<T: Decodable>(url: String, queryParams: [String: Any] = [:], completion: @escaping((Result<T, Error>) -> ())) {
        HTTPLayer.shared.get(url: url, queryParams: queryParams) { (result: Result<Data, Error>) in
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
    
    func get(url: String, queryParams: [String: Any] = [:], completion: @escaping((Result<Data, Error>) -> ())) {
        guard var urlComponents = URLComponents(string: url) else {
            completion(.failure(HTTPLayerError.inalidURLError.error))
            
            return
        }
        
        urlComponents.query = HTTPLayerHelper.generateQuery(from: queryParams)
        
        guard let finalUrl = urlComponents.url else {
            completion(.failure(HTTPLayerError.inalidURLError.error))
            
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalUrl) { (data, response, error) in
            print("\nGET \(finalUrl)\n")
            
            guard error == nil else {
                completion(.failure(error!))
                
                return
            }
            
            if let contents = data {
                completion(.success(contents))
            } else {
                completion(.failure(HTTPLayerError.nilResponseDataError.error))
            }
        }
        
        task.resume()
    }
}
