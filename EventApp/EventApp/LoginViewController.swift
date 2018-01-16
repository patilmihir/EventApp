//
//  LoginViewController.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/4/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var email:String = ""
    var password:String = ""


    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        email = txtEmail.text!
        password = txtPassword.text!
        
        //Validation for empty fields
        if(email.isEmpty || password.isEmpty) {
            invokeAlert(message: "All fields are mandatory")
            return
        }
        
        //Validation for email
        
        if(!isValidEmail(email: email)) {
            invokeAlert(message: "Please enter valid email")
            return
        }

        //Validate login
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if(user != nil) {
                let defaults = UserDefaults.standard
                defaults.set("true", forKey: "isUserLoggedIn")
              //  defaults.set(user?.uid, forKey: "userID")
                defaults.synchronize()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.invokeAlert(message: "Username password dosen't match");
            }
        }
        
        
    }
    
    // Validate Email
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Alert
    func invokeAlert(message:String) {
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
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
