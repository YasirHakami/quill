//
//  RegisterViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import Foundation
import Firebase
import UIKit

class RegisterViewController:UIViewController{
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.borderColor = UIColor.systemRed.cgColor
            userImageView.layer.borderWidth = 1.0
            userImageView.layer.cornerRadius = userImageView.bounds.height / 2
            userImageView.layer.masksToBounds = true
            userImageView.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            userImageView.addGestureRecognizer(tabGesture)
        }
        
    }
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        registerLabel.text = "register".localized
        registerButton.setTitle("register".localized, for: .normal)
        nameLabel.text = "name".localized
        emailLabel.text = "email".localized
        passwordLabel.text = "password".localized
        confirmPassword.text = "ConfirmPassword".localized
        bioLabel.text = "bio".localized
    }
    
    
    @IBAction func handlingRegister(_ sender: Any) {
        if let image = userImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.50),
           let name = nameTextField.text,
           let email = emailTextField.text,
           let bio = bioTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmTextField.text,
           password == confirmPassword {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Registration Auth Error",error.localizedDescription)
                }
                if let authResult = authResult {
                    let storageRef = Storage.storage().reference(withPath: "users/\(authResult.user.uid)")
                    let uploadMeta = StorageMetadata.init()
                    uploadMeta.contentType = "image/png"
                    storageRef.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                        if let error = error {
                            print("Registration Storage Error",error.localizedDescription)
                        }
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                print("Registration Storage Download Url Error",error.localizedDescription)
                            }
                            if let url = url {
                                print("URL",url.absoluteString)
                                let db = Firestore.firestore()
                                let userData: [String:String] = [
                                    "id":authResult.user.uid,
                                    "name":name,
                                    "email":email,
                                    "bio":bio,
                                    "imageUrl":url.absoluteString
                                    
                                ]
                                db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                    if let error = error {
                                        print("Registration Database error",error.localizedDescription)
                                    }else {
                                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileController") as? UITabBarController {
                                            vc.modalPresentationStyle = .fullScreen
                                            self.present(vc, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}





extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func selectImage() {
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "choose Profile Picture", message: "where do you want to pick your image from?", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { Action in
            self.getImage(from: .camera)
        }
        let galaryAction = UIAlertAction(title: "photo Album", style: .default) { Action in
            self.getImage(from: .photoLibrary)
        }
        let dismissAction = UIAlertAction(title: "Cancle", style: .destructive) { Action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(galaryAction)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    func getImage( from sourceType: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return}
        userImageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
