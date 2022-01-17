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
    var userPosts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    @IBOutlet weak var userPaintsCollectionView: UICollectionView!
    
    @IBOutlet weak var logoutButten: UIButton!{
        didSet{
            logoutButten.setTitle("logout".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var profileTitleLabel: UILabel!{
        didSet{
            profileTitleLabel.text = "profileTitle".localized
        }
    }
    @IBOutlet weak var userProfileImage: UIImageView!{
        didSet {
            userProfileImage.layer.borderColor = UIColor.systemGray.cgColor
            userProfileImage.layer.borderWidth = 2.0
            userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
            userProfileImage.layer.masksToBounds = true
            userProfileImage.isUserInteractionEnabled = true
        }
        
    }
    
    var userImage = ""
    @IBOutlet weak var uaserNameLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPaintsCollectionView.dataSource = self
        userPaintsCollectionView.delegate = self
        getProfileData()
        getPosts()
       
        
    }
    
    func getPosts() {
        let ref = Firestore.firestore()
        ref.collection("posts").order(by: "createdAt",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
            }
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach { diff in
                    let post = diff.document.data()
                    switch diff.type {
                    case .added :
                        if let userId = post["userId"] as? String {
                            if let currentUser = Auth.auth().currentUser {
                                let currentUserId = currentUser.uid
                                if userId == currentUserId {
                                    ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                        if let error = error {
                                            print("ERROR user Data",error.localizedDescription)
                                            
                                        }
                                        if let userSnapshot = userSnapshot,
                                           let userData = userSnapshot.data(){
                                            let user = User(dict:userData)
                                            let post = Post(dict:post,id:diff.document.documentID,user:user)
                                            self.userPosts.insert(post, at: 0)
                                            DispatchQueue.main.async {
                                                self.userPaintsCollectionView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.userPosts.first(where: {$0.id == postId}),
                           let updateIndex = self.userPosts.firstIndex(where: {$0.id == postId}){
                            let newPost = Post(dict:post, id: postId, user: currentPost.user)
                            self.userPosts[updateIndex] = newPost
                            DispatchQueue.main.async {
                                self.userPaintsCollectionView.reloadData()
                            }
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.userPosts.firstIndex(where: {$0.id == postId}){
                            self.userPosts.remove(at: deleteIndex)
                            DispatchQueue.main.async {
                                self.userPaintsCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func HandelLogOut(_ sender: Any) {
        let alret = UIAlertController(title: "logout".localized, message: "singOutMassege".localized, preferredStyle: .alert)
        alret.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: { action in
            do {
                try Auth.auth().signOut()
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavigationController") as? UINavigationController {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } catch  {
                print("ERROR in signout",error.localizedDescription)
            }
        }))
        alret.addAction(UIAlertAction(title: "Back".localized, style: .default, handler: {action in
            print("Back")
        }))
        present(alret, animated: true, completion: nil)
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                let vc = segue.destination as! NewPaintViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
                vc.fromProfile = false
           
        }
        
}


extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellcollection", for: indexPath) as! UaserDataProfileCell
        
        
        
        return cell.collectionCellStap(with: userPosts[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UaserDataProfileCell
        selectedPostImage = cell.userPaintsimageView.image
        selectedPost = userPosts[indexPath.row]
        performSegue(withIdentifier: "toDetails", sender: self)
    }
    
}
