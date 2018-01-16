//
//  HomeViewController.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/4/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class HomeViewController: UITableViewController {
    
    var ref: DatabaseReference!
    
    var events = [Event]()
    
    var event : Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        events = [Event]()
        let defaults = UserDefaults.standard
        let isUserLoggedIn = defaults.bool(forKey: "isUserLoggedIn")
        if(!isUserLoggedIn) {
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
        ref = Database.database().reference(withPath:"events")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                
                let obj:NSDictionary = rest.value as! NSDictionary
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                let date = dateFormatter.date(from: obj["datetime"]! as! String)

                var ticketCount: Int32 = 0
                
                if obj["ticketCount"]! is String {
                    ticketCount = (obj["ticketCount"]! as! NSString).intValue
                } else {
                    ticketCount = obj["ticketCount"]! as! Int32
                }
                
                
                let event = Event(id: Int(rest.key)!, name: obj["name"]! as! String ,description: obj["description"]! as! String,location: obj["location"]! as! String,
                                  path: obj["imagePath"]! as! String,ticketCount: ticketCount, ticketPrice: obj["ticketPrice"]! as! Int32, datetime: date!)
                
                
                self.events.append(event)
                //Download pic
                let url = URL(string: obj["imagePath"]! as! String)!
                
                let session = URLSession(configuration: .default)
                
                let downloadPic = session.dataTask(with: url) { (data, response, error) in
                    if let e = error {
                        print("Error downloading picture: \(e)")
                    } else {
                        if (response as? HTTPURLResponse) != nil {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                let imageName = obj["name"]! as! String + ".png"
                                let imgData = UIImagePNGRepresentation(image!)
                                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                let imageURL = docDir.appendingPathComponent(imageName)
                                try! imgData?.write(to: imageURL)
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code for some reason")
                        }
                    }
                }
                downloadPic.resume()

                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EventViewCell
        cell.selectionStyle = .none
        self.event = events.filter({ $0.id == Int(cell.lblEventId.text!)! }).first
        
        self.performSegue(withIdentifier: "eventDetailView", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventViewCell
        cell.selectionStyle = .none
        let list = events[indexPath.row]
        cell.lblEventName.text = list.name
        let id:String = String(list.id)
        cell.lblEventId.text = id
        cell.lblEventId.isHidden = true
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let nameOfMonth = dateFormatter.string(from: (list.datetime))
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: (list.datetime))
        
        cell.lblEventDate.text =  nameOfMonth + " " + day
        cell.lblEventDate.textColor = UIColor.darkGray
        cell.imgEvent.image = nil
        
        //Get image
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let imageName = (list.name) + ".png"
        let filePath = url.appendingPathComponent(imageName).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            cell.imgEvent.image = UIImage(contentsOfFile: filePath)
        } else {
            print("FILE NOT AVAILABLE")
        }
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailView = segue.destination as? EventViewController {
            eventDetailView.event = event
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
