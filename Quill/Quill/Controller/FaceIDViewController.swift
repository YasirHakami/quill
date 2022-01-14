//
//  FaceIDViewController.swift
//  Quill
//
//  Created by Yasir Hakami on 14/01/2022.
//

import Foundation
import LocalAuthentication
import UIKit

class FaceIDViewConntroller:UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faceid()
    }
    
 
    func faceid(){
        let localAuthentiocationContext = LAContext()
        var authorizationError : NSError?
        let reason = "Authentication requried to Login"
        
        if localAuthentiocationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError){
            localAuthentiocationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
                success, evaluteError in
                if success {
                    print("ok we did it !!")
                    DispatchQueue.main.async {
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileController") as? UITabBarController {
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }else{
                    guard let error = evaluteError else {
                        return
                    }
                    print(error)
                }
            }
            
        }else{
            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }
}
