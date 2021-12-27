//
//  QullCell.swift
//  Quill
//
//  Created by Yasir Hakami on 25/12/2021.
//

import Foundation
import UIKit
import Firebase

class QullCell:UITableViewCell{
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paintImage: UIImageView!{
        didSet{
            paintImage.layer.borderColor = UIColor.systemBackground.cgColor
            paintImage.layer.borderWidth = 3.0
        }
    }
    @IBOutlet weak var userImage: UIImageView!{
        didSet {
            userImage.layer.borderColor = UIColor.systemGray.cgColor
            userImage.layer.borderWidth = 2.0
            userImage.layer.cornerRadius = userImage.bounds.height / 2
            userImage.layer.masksToBounds = true
            userImage.isUserInteractionEnabled = true
        }
        
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func cellStap(with post:Post) -> UITableViewCell {
        priceLabel.text = post.price + " SAR"
        descripLabel.text = post.description
        paintImage.loadImageUsingCache(with: post.imageUrl)
        userImage.loadImageUsingCache(with: post.user.imageUrl)
        return self
    }
    
    override func prepareForReuse() {
        userImage.image = nil
        paintImage.image = nil
    }
}
