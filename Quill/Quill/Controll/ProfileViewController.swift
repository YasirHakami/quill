//
//  ProfileViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import Foundation
import Firebase
import UIKit

class ProfileViewController:UIViewController{
    
    @IBOutlet weak var userProfileImage: UIImageView!{
        didSet {
            userProfileImage.layer.borderColor = UIColor.systemGray.cgColor
            userProfileImage.layer.borderWidth = 2.0
            userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 4
            userProfileImage.layer.masksToBounds = true
            userProfileImage.isUserInteractionEnabled = true
        }
        
    }
    @IBOutlet weak var backView: UIView!
    var userImage = ""
    @IBOutlet weak var uaserNameLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfileData()
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 7
        backView.layer.borderColor = UIColor.systemBrown.cgColor
        backView.layer.borderWidth = 2.0
        
    }
    
    
    func getProfileData(){
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore()
            .document("users/\(currentUserID)")
            .addSnapshotListener{ doucument, error in
                if error != nil {
                    print ("error",error!.localizedDescription)
                    return
                }
                
                self.userImage = (doucument?.data()?["imageUrl"] as? String)!
                self.uaserNameLabel.text = doucument?.data()?["name"] as? String
                self.userBioLabel.text = doucument?.data()?["bio"] as? String
                
                var image:String
                image = self.userImage
                
                if let ImagemnueURl = URL(string:image )
                {
                    
                    DispatchQueue.global().async {
                        if let ImageData = try? Data(contentsOf:ImagemnueURl) {
                            let Image = UIImage(data: ImageData)
                            DispatchQueue.main.async {
                                self.userProfileImage.image = Image
                                
                            }
                        }
                    }
                    
                }
                
            }
    }
}
