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
    class TestPost: Codable {
        var id: Int?
        var title: String?
        var body: String?
    }
    
    func testGetRequestWithQueryParamsSucceeds() {
        let postsExpectation = XCTestExpectation(description: "Posts have been loaded")
        
        HTTPLayer.shared.request(method: .get, url: "https://jsonplaceholder.typicode.com/posts", queryParams: ["userId": 1]) { (result: Result<[TestPost], Error>) in
            switch result {
            case .success(let posts):
                XCTAssertEqual(posts.count, 10)
                
                postsExpectation.fulfill()
            case .failure(let error):
                XCTAssert(false, "Error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [postsExpectation], timeout: 5)
    }
    
    func testPostRequestWithBodySucceeds() {
        let postPostingExpectation = XCTestExpectation(description: "Post has been posted")
        
        HTTPLayer.shared.request(method: .post, url: "https://jsonplaceholder.typicode.com/posts", body: ["userId": 1, "title": "foo", "body": "bar"]) { (result: Result<TestPost, Error>) in
            switch result {
            case .success(let post):
                XCTAssertEqual(post.id, 101)
                XCTAssertEqual(post.title, "foo")
                XCTAssertEqual(post.body, "bar")
                
                postPostingExpectation.fulfill()
            case .failure(let error):
                XCTAssert(false, "Error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [postPostingExpectation], timeout: 5)
    }
    
    func testImageDownloadingAndAssigning() {
        var image = UIImage()
        let imageView = UIImageView()
        
        let imageExpectation = XCTestExpectation(description: "Image has been downloaded")
        let imageViewExpectation = XCTestExpectation(description: "ImageView gets it's image")
        
        HTTPLayer.shared.getImage(from: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") { (result) in
            switch result {
            case .success(let img):
                image = img
            case .failure(let error):
                XCTAssert(false, "Error: \(error.localizedDescription)")
            }
            
            imageExpectation.fulfill()
        }
        
        imageView.setImage(from: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") {
            imageViewExpectation.fulfill()
        }
        
        wait(for: [imageExpectation, imageViewExpectation], timeout: 5)
        
        XCTAssertEqual(imageView.image?.pngData(), image.pngData())
    }
}
