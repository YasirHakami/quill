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
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var signuatorLabel: UILabel!
    @IBOutlet weak var paintImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func cellStap(with post:Post) -> UITableViewCell {
        signuatorLabel.text = post.signature
        contactLabel.text = post.contact
        priceLabel.text = post.price
        descripLabel.text = post.description
        paintImage.loadImageUsingCache(with: post.imageUrl)
        userNameLabel.text = post.user.name
        userImage.loadImageUsingCache(with: post.user.imageUrl)
        return self
    }
    
    override func prepareForReuse() {
        userImage.image = nil
        paintImage.image = nil
    }
}
