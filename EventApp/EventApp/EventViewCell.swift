//
//  EventViewCell.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/4/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit

class EventViewCell: UITableViewCell {

    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!    
   
    @IBOutlet var lblEventId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
