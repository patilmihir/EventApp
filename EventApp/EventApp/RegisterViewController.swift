//
//  RegisterViewController.swift
//  EventBrite
//
//  Created by Mihir Patil on 11/26/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    var email:String = ""
    var password:String = ""
    var confirmPassword:String = ""
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!

    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        
        email = txtEmail.text!
        password = txtPassword.text!
        confirmPassword = txtConfirmPassword.text!
        
        //Validation for empty fields
        if(email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            invokeAlert(message: "All fields are mandatory",success:false)
            return
        }
        
        //Validation for email
        
        if(!isValidEmail(email: email)) {
            invokeAlert(message: "Please enter valid email",success:false)
            return
        }
        
        
        //Validation for password
        
        if(!isValidPassword(password:password)) {
            invokeAlert(message: "Please enter valid password(Atleast: 1 uppercase, 1 lowercase, 1 digit)",success:false)
            return
        }
        
        if(password != confirmPassword) {
            invokeAlert(message: "Password does not match ",success:false)
            return
        }
        
        //Store data
        saveUser();
   
        
    }
    
    @IBAction func btnSignInClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Save User
    
    func saveUser() { 
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in            
            self.invokeAlert(message: "Registration successfull",success:true)
            
            let  ref = Database.database().reference(fromURL: "https://eventapp-630cd.firebaseio.com/").child("users").child((user?.uid)!)
            ref.updateChildValues([ "email" : self.email])
            
            
        }
    }
    
    // Validate Email
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    func isValidPassword(password:String) -> Bool {

        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    // Alert
    func invokeAlert(message:String,success:Bool) {
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            if(success == true) {
            self.dismiss(animated: true, completion: nil)
            }
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
