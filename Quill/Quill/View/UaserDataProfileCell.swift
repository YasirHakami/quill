//
//  UaserDataProfileCell.swift
//  Quill
//
//  Created by Yasir Hakami on 03/01/2022.
//

import Foundation
import UIKit
class UaserDataProfileCell:UICollectionViewCell{
    @IBOutlet weak var userPaintsimageView: UIImageView!
    
  
    
    @IBOutlet weak var descripLabel: UILabel!
    
    func collectionCellStap(with post:Post) -> UICollectionViewCell {
        descripLabel.text = post.description
        userPaintsimageView.loadImageUsingCache(with: post.imageUrl)
        
        
        return self
    }
    
    
    override func prepareForReuse() {
        userPaintsimageView.image = nil

    }
}
