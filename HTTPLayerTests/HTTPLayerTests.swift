//
//  HTTPLayerTests.swift
//  HTTPLayerTests
//
//  Created by Roman Mirzoyan on 16.06.19.
//  Copyright © 2019 Roman Mirzoyan. All rights reserved.
//

import XCTest
@testable import HTTPLayer

class HTTPLayerTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testImageDownloadingAndAssigning() {
        var image = UIImage()
        let imageView = UIImageView()
        
        let imageExpectation = XCTestExpectation(description: "Rates have been loaded")
        let imageViewExpectation = XCTestExpectation(description: "Rates have been loaded")
        
        HTTPLayer.shared.getImage(from: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") { (result) in
            switch result {
            case .success(let img):
                image = img
            case .failure(_):
                break
            }
            
            imageExpectation.fulfill()
        }
        
        imageView.setImage(from: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") {
            imageViewExpectation.fulfill()
        }
        
        wait(for: [imageExpectation, imageViewExpectation], timeout: 5)
        
        XCTAssert(imageView.image?.pngData() == image.pngData())
    }
}
