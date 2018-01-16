//
//  HistoryTableViewController.swift
//  EventApp
//
//  Created by Mihir Patil on 12/11/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HistoryTableViewController: UITableViewController {

    var ref: DatabaseReference!
    
    var eventref: DatabaseReference!
    
    var events = [Event]()
    
    var orders = [Order]()
    
    var eventID = [String]()
    
    var event : Event?
    
    var order : Order?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        events = [Event]()
        orders = [Order]()
        eventID = [String]()
        event = nil
        ref = Database.database().reference(withPath:"orders")
        eventref = Database.database().reference(withPath:"events")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
               
                let obj:NSDictionary = rest.value as! NSDictionary
                let userID:String = (obj["userID"] as? String)!
                var id:String?
                var _: String
                var quantity: Int32
                if(userID == Auth.auth().currentUser?.uid as? String!) {
                    id = (obj["event"] as? String)!
                    if obj["quantity"]! is String {
                        quantity = (obj["quantity"]! as! NSString).intValue
                    } else {
                        quantity = obj["quantity"]! as! Int32
                    }
                    self.eventID.append(id!)
                    let url = obj["url"]
                    let order = Order(eventId: Int(id!)!, orderId: rest.key, quantity: quantity, url: url as! String)
                    self.orders.append(order)
                    self.eventref.child(id!).observeSingleEvent(of: .value, with: { snap in
                        let result = snap.value as! NSDictionary
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                        let date = dateFormatter.date(from: result["datetime"]! as! String)
                        var ticketCount: Int32 = 0
                        
                        if result["ticketCount"]! is String {
                            ticketCount = (result["ticketCount"]! as! NSString).intValue
                        } else {
                            ticketCount = result["ticketCount"]! as! Int32
                        }
                        
                        let event = Event(id: Int(id!)!, name: result["name"]! as! String ,description: result["description"]! as! String,location: result["location"]! as! String,
                                          path: result["imagePath"]! as! String,ticketCount: ticketCount, ticketPrice: result["ticketPrice"]! as! Int32, datetime: date!)
                        self.events.append(event)
                        self.tableView.reloadData()
                    })
                }
                
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


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryViewCell
        cell.selectionStyle = .none
        let list = events[indexPath.row]
        cell.lblEventName.text = list.name
        cell.lblEventId.text = String(list.id)
        cell.lblEventId.isHidden = true
        cell.lblOrderId.isHidden = true
        cell.lblOrderId.text = orders[indexPath.row].orderId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let nameOfMonth = dateFormatter.string(from: (list.datetime))
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: (list.datetime))
        cell.lblEventDate.text =  nameOfMonth + " " + day
        cell.lblEventDate.textColor = UIColor.darkGray
        return cell
    }
    
     override public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
     {
        let deleteItem = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! HistoryViewCell
            self.event = self.events.filter({ $0.id == Int(cell.lblEventId.text!)! }).first
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
           
            let currentDate =  dateFormatter.date(from:  dateFormatter.string(from: Date()))
            let validCancellationDate = Calendar.current.date(byAdding: .day, value: -2, to: (self.event?.datetime)!)!
            if(currentDate! > validCancellationDate ) {
                self.invokeAlert(message: "You cannot cancel this booking")
            } else {
                let deleteOrder = self.orders.filter({ $0.orderId == cell.lblOrderId.text }).first
                self.ref.child((deleteOrder?.orderId)!).removeValue()
                
                let eventID = cell.lblEventId.text
                let updateEvent = self.events.filter({ $0.id == Int(cell.lblEventId.text!)! }).first
                self.eventref.child(eventID!).updateChildValues(["ticketCount": String((updateEvent?.ticketCount)!+(deleteOrder?.quantity)!)])
                
                self.viewDidAppear(true)
                self.tableView.reloadData()
            }

        }
        
        let viewItem = UITableViewRowAction(style: .normal, title: "Event") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! HistoryViewCell
            self.event = self.events.filter({ $0.id == Int(cell.lblEventId.text!)! }).first
            self.performSegue(withIdentifier: "viewEventDetails", sender: self)
        }
        
        let ticketItem = UITableViewRowAction(style: .normal, title: "Ticket") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! HistoryViewCell
            self.order = self.orders.filter({ $0.orderId == cell.lblOrderId.text }).first
            self.performSegue(withIdentifier: "ticketSegue", sender: self)
        }
        deleteItem.backgroundColor = UIColor(red: 251/255, green: 140/255, blue: 0/255, alpha: 1.0)
        ticketItem.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1.0)
        viewItem.backgroundColor = UIColor(red: 255/255, green: 167/255, blue: 38/255, alpha: 1.0)
        return [deleteItem, viewItem, ticketItem]
        
     }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? EventViewController {
            view.event =  event
        }
        if let view = segue.destination as? BarcodeViewController {
            view.order =  order
        }
        
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
