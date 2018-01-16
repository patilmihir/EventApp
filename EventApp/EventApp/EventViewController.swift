//
//  EventViewController.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/5/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit

class EventViewController: UIViewController {
        
    var ref: DatabaseReference!
    
    var eventref: DatabaseReference!
    
    @IBOutlet var imgEvent: UIImageView!
    
    @IBOutlet var lblEventName: UILabel!
    
    @IBOutlet var lblLocation: UILabel!
    
    @IBOutlet var lblCost: UILabel!
    
    @IBOutlet var lblAvailable: UILabel!
    
    @IBOutlet var btnTicket: UIButton!
    
    var event : Event?
    
    var isBooked:Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        displayView()
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func displayView() {

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let currentDate =  dateFormatter.date(from:  dateFormatter.string(from: Date()))
        
        checkBooking() {
            (result: Bool) in
            if(result) {
                self.btnTicket.isEnabled = false
                self.btnTicket.setTitle("Not Available", for: .normal)
            }
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let imageEventName = (event?.name)! + ".png"
        let eventImgFilePath = url.appendingPathComponent(imageEventName).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: eventImgFilePath) {
             imgEvent.image = UIImage(contentsOfFile: eventImgFilePath)
        } else {
            print("FILE NOT AVAILABLE")
        }
        lblEventName.text = event?.name
        lblLocation.text = event?.location
        lblCost.text = String((event?.ticketPrice)!)
        lblAvailable.text = String((event?.ticketCount)!)
        if(event?.ticketCount == 0 || (event?.datetime)! < currentDate!) {
            btnTicket.isEnabled = false
            btnTicket.setTitle("Sold Out/Expired", for: .normal)
        } else if(isBooked) {
            btnTicket.isEnabled = false
            btnTicket.setTitle("Not Available", for: .normal)
        } else {
            btnTicket.isEnabled = true
            btnTicket.setTitle("Ticket", for: .normal)
        }
       
    }
    
    func checkBooking(completion: @escaping (_ result: Bool) -> Void) {
        
        ref = Database.database().reference(withPath:"orders")
        eventref = Database.database().reference(withPath:"events")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                
                let obj:NSDictionary = rest.value as! NSDictionary
                let userID:String = (obj["userID"] as? String)!
                var id:String?
                if(userID == Auth.auth().currentUser?.uid as? String!) {
                    id = (obj["event"] as? String)!
                    if(Int(id!)! == (self.event?.id)!) {
                        self.isBooked = true
                        completion(self.isBooked)
                    }
                }
                
            }
        })
    }
    
    @IBAction func btnDirection(_ sender: Any) {
        let address = "63 Saint Germain Street, Boston, MA 02115"
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            let regionDistance:CLLocationDistance = 1000
            let coordinates = location.coordinate
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:regionSpan.span)]
            let placeMark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark:placeMark)
            mapItem.name = self.event?.name
            mapItem.openInMaps(launchOptions: options)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ticketButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ticketDetailView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ticketDetailView = segue.destination as? TicketViewController {
            ticketDetailView.event = event
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
