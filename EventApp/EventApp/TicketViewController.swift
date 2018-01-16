//
//  TicketViewController.swift
//  EventApp
//
//  Created by Mihir Patil on 12/10/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var lblEventName: UILabel!
    
    @IBOutlet var lblTicketPrice: UILabel!
    
    @IBOutlet var txtQuantity: UITextField!
    
    var event : Event!
    
    var ticket = [String]()
    
    var selectedCount:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        createPicker()
        createToolbar()
        displayView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayView() {
        txtQuantity.text = "Select"
        lblEventName.text = event.name
        lblTicketPrice.text = String(event.ticketPrice)
    }
    
    func createPicker() {
        let quantityPicker = UIPickerView()
        quantityPicker.delegate = self
        txtQuantity.inputView = quantityPicker;
    }
    
    @IBAction func btnCheckoutClicked(_ sender: Any) {
        let flag:Bool = validate()
        if(flag) {
         self.performSegue(withIdentifier: "paymentDetailView", sender: self)
        }
    }
    
    func validate() -> Bool {
        if(txtQuantity.text == "" || txtQuantity.text == "Select") {
            invokeAlert(message: "Please select quantity")
            return false
        } else if(!ticket.contains(txtQuantity.text!)) {
            invokeAlert(message: "Please select valid quantity")
            return false
        } else {
            return true
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let paymentDetailView = segue.destination as? CheckoutViewController {
            paymentDetailView.event = event
            paymentDetailView.quantity = Int(txtQuantity.text!)
        }
    }
    
    func createToolbar() {

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        toolBar.tintColor = UIColor.blue
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TicketViewController.dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtQuantity.inputAccessoryView = toolBar
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (event.ticketCount>5)
        {return 6}
        else
        {return Int(event.ticketCount)}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        ticket.append("Select")
        if (event.ticketCount>5)
        
        {
            var i = 5
            while i > 0
            {
                ticket.append(String(i))
                i -= 1
            }
        }
        else
        {
            var count = event.ticketCount
            while count > 0
            {
                ticket.append(String(count))
                count -= 1
            }
        }
        
        return ticket[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCount = ticket[row]
        txtQuantity.text = selectedCount
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
