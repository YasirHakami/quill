//
//  DetailsViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 26/12/2021.
//

import Foundation
import Firebase
import UIKit


class DetailsViewController:UIViewController{
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    @IBOutlet weak var newQuillImage: UIImageView!
    
    @IBOutlet weak var descrip: UILabel!
    
    @IBOutlet weak var contact: UILabel!
    
    @IBOutlet weak var signuator: UILabel!
    
    @IBOutlet weak var painter: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage{
            descrip.text = selectedPost.description
            contact.text = selectedPost.contact
            signuator.text = selectedPost.signature
            painter.text = selectedPost.user.name
            price.text = selectedPost.price
            newQuillImage.image = selectedImage
        }
    }
}
