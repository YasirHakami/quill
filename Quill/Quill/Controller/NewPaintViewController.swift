//
//  NewPaintViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import Foundation
import UIKit
import Firebase

class NewPaintViewController:UIViewController{
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let activityIndicator = UIActivityIndicatorView()
    var fromProfile = true
    @IBOutlet weak var deleteButtonForproFile: UIButton!{
        didSet{
            deleteButtonForproFile.setTitle("Delete".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var newImage: UIImageView!{
        didSet {
            newImage.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
            newImage.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var descripLabel: UILabel!{
        didSet{
            descripLabel.text = "descripe".localized
        }
    }
    @IBOutlet weak var descripTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var signatureTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!{
        didSet{
            priceLabel.text = "price".localized
        }
    }
    @IBOutlet weak var contactLabel: UILabel!{
        didSet{
            contactLabel.text = "contact".localized
        }
    }
    @IBOutlet weak var SignatureLabel: UILabel!{
        didSet{
            SignatureLabel.text = "signature".localized
        }
    }
    @IBOutlet weak var sendButten: UIButton!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage {
            descripTextField.text = selectedPost.description
            priceTextField.text = selectedPost.price
            contactTextField.text = selectedPost.contact
            signatureTextField.text = selectedPost.signature
            newImage.image = selectedImage
            sendButten.setTitle("Update".localized, for: .normal)
            let deleteBarButton = UIBarButtonItem(image: UIImage(systemName: "delete.left"), style: .plain, target: self, action: #selector(handleDelete))
            self.navigationItem.rightBarButtonItem = deleteBarButton
        }else {
            sendButten.setTitle("SendNewPaint".localized, for: .normal)
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if fromProfile {
            deleteButtonForproFile.removeFromSuperview()
        }
        descripTextField.delegate = self
        priceTextField.delegate = self
        contactTextField.delegate = self
        signatureTextField.delegate = self
       
    }
    @objc func handleDelete (_ sender: UIBarButtonItem) {
        let ref = Firestore.firestore().collection("posts")
        if let selectedPost = selectedPost {
            ref.document(selectedPost.id).delete { error in
                if let error = error {
                    print("Error in db delete",error)
                }else {
                    // Create a reference to the file to delete
                    let storageRef = Storage.storage().reference(withPath: "posts/\(selectedPost.user.id)/\(selectedPost.id)")
                    // Delete the file
                    storageRef.delete { error in
                        if let error = error {
                            print("Error in storage delete",error)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let alretDelete = UIAlertController(title: "Delete".localized, message: "DeleteM".localized, preferredStyle: .alert)
        alretDelete.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: { action in
            let ref = Firestore.firestore().collection("posts")
            if let selectedPost = self.selectedPost {
                ref.document(selectedPost.id).delete { error in
                    if let error = error {
                        print("Error in db delete",error)
                    }else {
                        // Create a reference to the file to delete
                        let storageRef = Storage.storage().reference(withPath: "posts/\(selectedPost.user.id)/\(selectedPost.id)")
                        // Delete the file
                        storageRef.delete { error in
                            if let error = error {
                                print("Error in storage delete",error)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    }
                }
            }
            
            }))
        alretDelete.addAction(UIAlertAction(title: "Back".localized, style: .default, handler: { action in
            print("Back")
        }))
        present(alretDelete, animated: true, completion: nil)
    }
    
    
    @IBAction func handelNewQuill(_ sender: Any) {
            if let image = newImage.image,
               let imageData = image.jpegData(compressionQuality: 0.50),
               let price = priceTextField.text,
               let description = descripTextField.text,
               let contact = contactTextField.text,
               let signature = signatureTextField.text,
               let currentUser = Auth.auth().currentUser {
                Activity.showIndicator(parentView: self.view, childView: activityIndicator)
                var postId = ""
                if let selectedPost = selectedPost {
                    postId = selectedPost.id
                }else {
                    postId = "\(Firebase.UUID())"
                }
                let storageRef = Storage.storage().reference(withPath: "posts/\(currentUser.uid)/\(postId)")
                let updloadMeta = StorageMetadata.init()
                updloadMeta.contentType = "image/png"
                storageRef.putData(imageData, metadata: updloadMeta) { storageMeta, error in
                    if let error = error {
                        print("Upload error",error.localizedDescription)
                    }
                    storageRef.downloadURL { url, error in
                        var postData = [String:Any]()
                        if let url = url {
                            let db = Firestore.firestore()
                            let ref = db.collection("posts")
                            if let selectedPost = self.selectedPost {
                                postData = [
                                    "userId":selectedPost.user.id,
                                    "contact":contact,
                                    "price":price,
                                    "signature":signature,
                                    "description":description,
                                    "imageUrl":url.absoluteString,
                                    "createdAt":selectedPost.createdAt ?? FieldValue.serverTimestamp(),
                                    "updatedAt": FieldValue.serverTimestamp()
                                ]
                            }else {
                                postData = [
                                    "userId":currentUser.uid,
                                    "contact":contact,
                                    "signature":signature,
                                    "price":price,
                                    "description":description,
                                    "imageUrl":url.absoluteString,
                                    "createdAt":FieldValue.serverTimestamp(),
                                    "updatedAt": FieldValue.serverTimestamp()
                                ]
                            }
                            ref.document(postId).setData(postData) { error in
                                if let error = error {
                                    print("FireStore Error",error.localizedDescription)
                                }
                                Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                self.navigationController?.popViewController(animated: true)
                                self.resetElement()
                            }
                        }
                    }
                }
            }
            
        }
        
        
    }


extension NewPaintViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @objc func chooseImage() {
        self.showAlert()
    }
    private func showAlert() {
        
        let alert = UIAlertController(title: "Choose Profile Picture", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        newImage.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func resetElement(){
        descripTextField.text = ""
        priceTextField.text = ""
        contactTextField.text = ""
        signatureTextField.text = ""
        newImage.image = UIImage(systemName: "doc.text.image")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
