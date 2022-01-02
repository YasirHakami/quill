//
//  HomeViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import Foundation
import UIKit
import Firebase

class HomeViewController:UIViewController{
    var posts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    @IBOutlet weak var quillTableView: UITableView!
    
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        quillTableView.dataSource = self
        quillTableView.delegate = self
        getNewQuill()
        logoutButton.setTitle("logout".localized, for: .normal)
        
       
        
    }
    
    @IBAction func handelLogOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavigationController") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            print("ERROR in signout",error.localizedDescription)
        }
    }
    
    
    
    func getNewQuill() {
        let ref = Firestore.firestore()
        ref.collection("posts").order(by: "createdAt",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
            }
            if let snapshot = snapshot {
                print("POST CANGES:",snapshot.documentChanges.count)
                snapshot.documentChanges.forEach { diff in
                    let postData = diff.document.data()
                    switch diff.type {
                    case .added :
                        
                        if let userId = postData["userId"] as? String {
                            ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    print("ERROR user Data",error.localizedDescription)
                                    
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                    let user = User(dict:userData)
                                    let post = Post(dict:postData,id:diff.document.documentID,user:user)
                                    self.quillTableView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                        self.posts.append(post)
                                        
                                        self.quillTableView.insertRows(at: [IndexPath(row:self.posts.count - 1,section: 0)],with: .automatic)
                                    }else {
                                        self.posts.insert(post,at:0)
                                        
                                        self.quillTableView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                    }
                                    
                                    self.quillTableView.endUpdates()
                                    
                                    
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.posts.first(where: {$0.id == postId}),
                           let updateIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            let newPost = Post(dict:postData, id: postId, user: currentPost.user)
                            self.posts[updateIndex] = newPost
                            
                            self.quillTableView.beginUpdates()
                            self.quillTableView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                            self.quillTableView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                            self.quillTableView.endUpdates()
                            
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            self.posts.remove(at: deleteIndex)
                            
                            self.quillTableView.beginUpdates()
                            self.quillTableView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                            self.quillTableView.endUpdates()
                            
                        }
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toNwePaintVC" {
                let vc = segue.destination as! NewPaintViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
            }else {
                let vc = segue.destination as! DetailsViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
            }
        }
        
    }
}
extension HomeViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QullCell
        
        return cell.cellStap(with: posts[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QullCell
        selectedPostImage = cell.paintImage.image
        selectedPost = posts[indexPath.row]
        if let currentUser = Auth.auth().currentUser,
           currentUser.uid == posts[indexPath.row].user.id{
            performSegue(withIdentifier: "toNwePaintVC", sender: self)
        }else {
            performSegue(withIdentifier: "toDetailsVC", sender: self)
            
        }
    }
    
    
}
