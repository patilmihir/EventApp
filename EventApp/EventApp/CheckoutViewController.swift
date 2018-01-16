//
//  CheckoutViewController.swift
//  EventApp
//
//  Created by Mihir Patil on 12/10/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Stripe
import FirebaseStorage


class CheckoutViewController: UIViewController {
    
    var ref : DatabaseReference!
    var event : Event!
    var quantity : Int!
    var qrcodeImage: CIImage!
    var image = UIImage()
    var orderId:String?
    var url:String?
    
    @IBOutlet var lblPrice: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPurchaseClicked(_ sender: Any) {
        generateTicket {
            print("Ticket Generated")
        }
        updateTicketCount{
            print("Event Updated")
        }
        uploadMedia {
            print("Media Uploaded")
        }
      

        self.performSegue(withIdentifier: "homeView", sender: self)
    }
    
    func generateTicket(completionBlock : @escaping (() -> Void)){
        
        // Generate ticket
        if qrcodeImage == nil {
            let source = String(event.id).appending("|").appending((Auth.auth().currentUser?.uid)!)
            let data = source.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            qrcodeImage = filter?.outputImage
            self.displayQRCodeImage()
        }
        else {
            qrcodeImage = nil
        }
    }
    
    func uploadMedia(completion: @escaping (() -> Void)) {
        let userId = Auth.auth().currentUser?.uid
        let imageName = String(event.id).appending(".png")
        let storageRef = Storage.storage().reference().child("orders").child(userId!).child(imageName)
        if let uploadData = UIImagePNGRepresentation(self.image) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                } else {
                    if  let url = metadata?.downloadURL()?.absoluteString {
                        self.url = url
                        self.createOrder{
                            print("Order Created")
                        }
                    }
                }
            }
        }
    }
    
    
    func displayQRCodeImage() {
        let scaleX = 5.71428571428571
        let scaleY = 5.71428571428571
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleY)))
        self.image = convert(transformedImage)
    }
    
    func convert(_ cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func createOrder(completionBlock : @escaping (() -> Void)){
        let  ref = Database.database().reference(fromURL: "https://eventapp-630cd.firebaseio.com/").child("orders").childByAutoId()
        let userID = Auth.auth().currentUser?.uid
        ref.updateChildValues([ "userID": userID!, "event": String(event.id), "quantity": quantity, "url":self.url!])
    }
    
    func updateTicketCount(completionBlock : @escaping (() -> Void)){
        let id = event.id
        let updatedQuantity = Int(event.ticketCount) - quantity
        ref = Database.database().reference()
        ref.child("events").child(String(id)).updateChildValues(["ticketCount": String(updatedQuantity)])
    }
    
    func displayView() {
        lblPrice.text = String(event.ticketPrice * Int32(quantity))
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
