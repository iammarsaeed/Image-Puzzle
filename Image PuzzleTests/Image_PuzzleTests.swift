//
//  Image_PuzzleTests.swift
//  Image PuzzleTests
//
//  Created by Ammar on 09/06/2024.
//
import UIKit
import XCTest
@testable import Image_Puzzle

class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!
    
    override func setUp() {
        super.setUp()
        let layout = UICollectionViewFlowLayout()
        sut = ViewController(collectionViewLayout: layout)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
        
    func testDownloadAndSliceImage_Successful() {
        let expectation = self.expectation(description: "Download and slice image successful")
        
        self.sut.puzzle.removeAll()
        
        sut.downloadAndSliceImage()
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.sut.puzzle.count, 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    
    func testDownloadAndSliceImage_FallbackToStaticImage() {
        let expectation = self.expectation(description: "Fallback to static image")
        
        self.sut.puzzle.removeAll()
        
        self.sut.imageUrl = URL(string: "invalid_url")!
        
        sut.downloadAndSliceImage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            XCTAssertEqual(self.sut.puzzle.count, 1, "Expected one puzzle")
            XCTAssertEqual(self.sut.puzzle[0].unsolvedImages.count, 9, "Expected 9 unsolved images")
            XCTAssertEqual(self.sut.puzzle[0].solvedImages.count, 9, "Expected 9 solved images")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: { error in
            if let error = error {
                XCTFail("Error: \(error)")
            }
            XCTAssertEqual(self.sut.puzzle.count, 1, "Expected one puzzle only")
        })
    }


    
    func testCollectionView_NumberOfSections() {
        let numberOfSections = sut.numberOfSections(in: sut.collectionView)
        XCTAssertEqual(numberOfSections, 1)
    }
    
    func testCollectionView_NumberOfItemsInSection() {
        let itemsCount = sut.collectionView(sut.collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(itemsCount, 9)
    }
    
    func testSliceImage() {
        let image = UIImage(named: "Charuzard")!
        let slices = sut.sliceImage(image: image, into: 3)
        
        XCTAssertEqual(slices.count, 9)
    }
    
    func testSaveImageToDocuments() {
        let image = UIImage(named: "Charuzard")!
        let filePath = sut.saveImageToDocuments(image: image)
        
        XCTAssertNotNil(filePath)
    }
    
}
