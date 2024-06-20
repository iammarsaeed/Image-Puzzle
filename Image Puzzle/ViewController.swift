//
//  PuzzleCollectionViewController.swift
//  Image Puzzle
//
//  Created by Ammar on 20/06/2024.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var puzzle: [Puzzle] = []
    var index: Int = 0
    var imageUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        downloadAndSliceImage()
    }
    
    func downloadAndSliceImage() {
        guard let imageUrl = self.imageUrl else {
            print("Image URL is nil")
            useStaticImage()
            return
        }
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image")
                // Fallback to static image on failure
                self.useStaticImage()
                return
            }
            
            if let image = UIImage(data: data) {
                let slices = self.sliceImage(image: image, into: 3)
                let filePaths = slices.compactMap { self.saveImageToDocuments(image: $0) }
                let puzzle = Puzzle(title: "PuzzleImage", solvedImages: filePaths, unsolvedImages: filePaths.shuffled())
                self.puzzle.append(puzzle)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                // Fallback to static image if downloaded data cannot be converted to UIImage
                self.useStaticImage()
            }
        }
        task.resume()
    }
    
    func useStaticImage() {
        let staticImageName = "Charuzard"  // Assuming "Charizard" is the name of your static image
        guard let staticImage = UIImage(named: staticImageName) else {
            print("Static image named '\(staticImageName)' not found")
            return
        }
        
        let slices = self.sliceImage(image: staticImage, into: 3)
        let filePaths = slices.compactMap { self.saveImageToDocuments(image: $0) }
        let puzzle = Puzzle(title: "PuzzleImage", solvedImages: filePaths, unsolvedImages: filePaths.shuffled())
        self.puzzle.append(puzzle)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func sliceImage(image: UIImage, into parts: Int) -> [UIImage] {
        let width = image.size.width / CGFloat(parts)
        let height = image.size.height / CGFloat(parts)
        var images: [UIImage] = []
        
        for y in 0..<parts {
            for x in 0..<parts {
                let rect = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height)
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let partImage = UIImage(cgImage: cgImage)
                    images.append(partImage)
                }
            }
        }
        return images
    }
    
    func saveImageToDocuments(image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        let fileName = UUID().uuidString + ".png"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save image:", error)
            return nil
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
            
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if index < puzzle.count {
            return puzzle[index].unsolvedImages.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        let imagePath = puzzle[index].unsolvedImages[indexPath.item]
        if let image = UIImage(contentsOfFile: imagePath) {
            cell.puzzleImage.image = image
        }
        return cell
    }

}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 15, bottom: 40, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        var customCollectionWidth: CGFloat!
        customCollectionWidth = collectionViewWidth / 3 - 10
       
        return CGSize(width: customCollectionWidth, height: customCollectionWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.puzzle[index].unsolvedImages[indexPath.item]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        if puzzle[index].unsolvedImages == puzzle[index].solvedImages {
            Alert.showSolvedPuzzleAlert(on: self)
            collectionView.dragInteractionEnabled = false
            if index == puzzle.count - 1 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        
        if let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                puzzle[index].unsolvedImages.swapAt(sourceIndexPath.item, destinationIndexPath.item)
                collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
                
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }

