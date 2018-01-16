//
//  AccountViewController.swift
//  EventApp
//
//  Created by Mihir Patil on 12/16/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AccountViewController: UIViewController {

    @IBOutlet var txtCurrentPassword: UITextField!

    @IBOutlet var txtNewPassword: UITextField!
    
    @IBOutlet var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSignout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "isUserLoggedIn")
            defaults.synchronize()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "accountSignout", sender: self)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        if(txtCurrentPassword.text == "" || txtNewPassword.text == "" || txtConfirmPassword.text == "") {
            //invoke alert
            print("Mandatory")
        } else if(txtNewPassword.text != txtConfirmPassword.text) {
            //invoke alert
            print("Mismatch")
        } else {
            
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: txtCurrentPassword.text!)
            user?.reauthenticate(with: credential) { error in
                if error != nil {
                    // An error happened.
                } else {
                    Auth.auth().currentUser?.updatePassword(to: self.txtNewPassword.text!) { (error) in
                        if(error != nil) {
                            //An error occured
                        } else {
                            self.btnSignout(self)
                        }
                    }
                }
            }
        }
    }
    
    
    func alert(message:String) {
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            //run your function here
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
