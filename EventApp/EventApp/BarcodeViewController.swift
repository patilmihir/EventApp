//
//  BarcodeViewController.swift
//  EventApp
//
//  Created by Mihir Patil on 12/15/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import FirebaseStorage

class BarcodeViewController: UIViewController {

    @IBOutlet var imgQRCode: UIImageView!
    
    var order:Order?
    
    var qrcodeImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayView() {
        let url = URL(string:  (order?.url)!)!
        
        let session = URLSession(configuration: .default)
        
        let downloadPic = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        self.imgQRCode.image = image
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPic.resume()
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
