//
//  HTTPLayerError.swift
//  HTTPLayer
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import Foundation

enum HTTPLayerError: String {
    case invalidURLError = "URL is invalid"
    case nilResponseDataError = "Data appears to be nil"
    case unableToParseImageError = "Unable to parse data into image"
    case bodyInGetRequestIsForbiden = "Body is forbiden in GET request"
    case internalServerError = "Internal Server error"
    case clientError = "Client error"
    
    var error: NSError {
        return HTTPLayerHelper.getError(with: self.rawValue)
    }
}
