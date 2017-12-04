//
//  RegisterViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var containingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    var userInfo: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containingView.layer.borderColor = UIColor.lightGray.cgColor
        containingView.layer.borderWidth = 0.5
        let background = UIImage(named: "background")!
        self.navigationController!.navigationBar.setBackgroundImage(background, for: .default)

        self.navigationController!.navigationBar.tintColor = .black
        
        userImageView.layer.cornerRadius = 5
        userImageView.clipsToBounds = true
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        registerButton.layer.cornerRadius = 5
        usernameField.tag = 0
        emailField.tag = 1
        passwordField.tag = 2
        confirmPasswordField.tag = 3
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        usernameField.returnKeyType = .next
        emailField.returnKeyType = .next
        passwordField.returnKeyType = .next
        confirmPasswordField.returnKeyType = .next
        if userInfo != nil {
            setupFacebook()
        }
    }

    func setupFacebook() {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        containingHeightConstraint.constant = 120
        passwordField.isHidden = true
        confirmPasswordField.isHidden = true
        
        usernameField.text = userInfo!["name"] as? String
        emailField.text = userInfo!["email"] as? String
        let picture = userInfo!["picture"] as! [String: Any]
        let data = picture["data"] as! [String: Any]
        let pictureURL = URL(string: data["url"] as! String)!
        let pictureSession = URLSession(configuration: .default)
        pictureSession.dataTask(with: pictureURL) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            } else if let data = data {
                let image = UIImage(data: data)!
                DispatchQueue.main.async {
                    self.userImageView.image = image
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                }
            }
            
        }.resume()
    }
    
    @IBAction func onRegister(_ sender: Any) {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        guard let userImage = userImageView.image else {
            let alert = UIAlertController(title: "Error", message: "Select a user image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return
        }
        
        guard let username = usernameField.text, !username.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Input username.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return
        }
        
        guard let email = emailField.text, !email.isEmpty, email.isValidEmail() else {
            let alert = UIAlertController(title: "Error", message: "Input valid email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return
        }
        
        if userInfo == nil {
            guard let password = passwordField.text, !password.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Input password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                return
            }
            
            if password.count < 6 {
                let alert = UIAlertController(title: "Error", message: "Password must be atleast 6 characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                return
            }
            guard let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Passwords must match.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                return
            }
            
            if password != confirmPassword {
                let alert = UIAlertController(title: "Error", message: "Passwords must match.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                return
            }
            let userData = ["username": username, "email": email, "password": password]
            EventUpClient.sharedInstance.registerUser(userData: userData, userImage: userImage, success: { (user) in
                DispatchQueue.main.async {
                    
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "registerSegue", sender: nil)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    print(error.localizedDescription)
                }
            }
            
        } else {
            let userData = ["username": username, "email": email]
            EventUpClient.sharedInstance.registerFacebookUser(uid: Auth.auth().currentUser!.uid,userData: userData, userImage: userImage, success: { () in
                DispatchQueue.main.async {
                    
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "registerSegue", sender: nil)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
    
    @IBAction func onPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        
        userImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            onRegister(registerButton)
        }
        // Do not add a line break
        return false
    }
}
