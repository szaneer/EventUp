//
//  LoginViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import FBSDKLoginKit
import GeoFire
import MapKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var eventUpLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        FBSDKLoginManager().logOut()
        // Do any additional setup after loading the view.
        
        let background = UIImage(named: "background")!
        self.navigationController!.navigationBar.setBackgroundImage(background, for: .default)
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: self.loginButton.frame.origin.x, y: self.loginButton.frame.origin.y + 16 + self.loginButton.frame.height, width: self.loginButton.frame.width, height: loginButton.frame.height)
        
        emailField.returnKeyType = .next
        passwordField.returnKeyType = .done
        emailField.delegate = self
        passwordField.delegate = self
        emailField.tag = 0
        passwordField.tag = 1
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.delegate = self
        registerButton.layer.cornerRadius = 5
        registerButton.center.x = view.center.x
        view.addSubview(loginButton)
        
        containingView.layer.borderColor = UIColor.lightGray.cgColor
        containingView.layer.borderWidth = 0.5
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        guard let email = emailField.text, !email.isEmpty, email.isValidEmail() else {
            let alert = UIAlertController(title: "Error", message: "Enter valid email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Enter password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return
        }
        
        let userData = ["email": email, "password": password]
        EventUpClient.sharedInstance.loginUser(userData: userData, success: { (user) in
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: "Issue with signing in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print(error.localizedDescription)
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "facebookSegue":
            let destination = segue.destination as! RegisterViewController
            destination.userInfo = sender as? [String: Any]
        default:
            return
        }
    }
 

}

extension LoginViewController {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if (result.isCancelled) {
            return
        }
        
        print(result.description)
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    
        EventUpClient.sharedInstance.loginOrRegisterWithFacebook(credential: credential, success: { (user, userInfo, exists) -> () in
            if exists {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "facebookSegue", sender: userInfo)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            onLogin(loginButton)
        }
        // Do not add a line break
        return false
    }
}
