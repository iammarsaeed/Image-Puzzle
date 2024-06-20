//
//  ImageCollectionViewCell.swift
//  Image Puzzle
//
//  Created by Ammar on 20/06/2024.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var puzzleImage: UIImageView!
    
    override func awakeFromNib() {
        self.frame = puzzleImage.frame
    }
    
}
