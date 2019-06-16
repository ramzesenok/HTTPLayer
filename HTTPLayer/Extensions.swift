//
//  Extensions.swift
//  HTTPLayer
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(from source: String, completion: @escaping (() -> ()) = ({() -> () in })) {
        HTTPLayer.shared.getImage(from: source) { (result: Result<UIImage, Error>) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(_):
                break
            }
            
            completion()
        }
    }
}
