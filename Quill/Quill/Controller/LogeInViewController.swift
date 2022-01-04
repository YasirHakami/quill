//
//  ViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import UIKit
import Firebase
class LogeInViewController: UIViewController {

    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var welcomMassege: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
   
    @IBOutlet weak var passwordHideOrShow: UIButton!
    @IBOutlet weak var logInButten: UIButton!
    
    @IBOutlet weak var registerButten: UIButton!
    
    @IBOutlet weak var changeLangugeButten: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordTextField.rightView = passwordHideOrShow
        passwordTextField.rightViewMode = .whileEditing
        emailLabel.text = "email".localized
        passwordLabel.text = "password".localized
        logInButten.setTitle("logIn".localized, for: .normal)
        registerButten.setTitle("register".localized, for: .normal)
        changeLangugeButten.setTitle("changeLun".localized, for: .normal)
        signInLabel.text = "signIn".localized
        welcomMassege.text = "welcome".localized
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        
    }
    @IBAction func changeLanguge(_ sender: Any) {
        let currentLang = Locale.current.languageCode
        let newLang = currentLang == "en" ? "ar" : "en"
        UserDefaults.standard.setValue([newLang], forKey: "AppleLanguages")
        exit(0)
        
    }
    @IBAction func changePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        if passwordTextField.isSecureTextEntry {
            if let image = UIImage(systemName: "eye.fill") {
                sender.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(systemName: "eye.slash.fill") {
                sender.setImage(image, for: .normal)
            }
        }
    }
    

   
    
    
    
    @IBAction func hundelSignIn(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let _ = authResult {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileController") as? UITabBarController {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}


