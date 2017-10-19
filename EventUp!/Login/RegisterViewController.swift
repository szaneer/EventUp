//
//  RegisterViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRegister(_ sender: Any) {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        guard let userImage = userImageView.image else {
            return
        }
        
        guard let username = usernameField.text, !username.isEmpty else {
            return
        }
        
        guard let email = emailField.text, !email.isEmpty else {
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            return
        }
        
        if password.count < 6 {
            return
        }
        
        guard let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            return
        }
        
        if password != confirmPassword {
            return
        }
        
        let userData = ["username": username, "email": email, "password": password]
        EventUpClient.sharedInstance.registerUser(userData: userData, userImage: userImage, success: { (user) in
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "registerSegue", sender: nil)
        }) { (error) in
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
