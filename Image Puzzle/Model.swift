//
//  Model.swift
//  Image Puzzle
//
//  Created by Ammar on 20/06/2024.
//

import Foundation

class Puzzle: Codable {
    var title: String
    var solvedImages: [String]
    var unsolvedImages: [String]
    
    init(title: String, solvedImages: [String], unsolvedImages: [String]) {
        self.title = title
        self.solvedImages = solvedImages
        self.unsolvedImages = unsolvedImages
    }
    
    convenience init(title: String, solvedImages: [String]) {
        self.init(title: title, solvedImages: solvedImages, unsolvedImages: solvedImages.shuffled())
    }
}
