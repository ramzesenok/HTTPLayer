//
//  HTTPLayerHelper.swift
//  HTTPLayer
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import Foundation

class HTTPLayerHelper {
    static func generateQuery(from params: [String: Any]) -> String {
        var query = ""
        
        params.forEach({ (arg: (key: String, value: Any)) in
            query.append("\(arg.key)=\(arg.value)&")
        })
        
        if !query.isEmpty {
            query.removeLast() // to remove redundant '&'
        }
    }
}
