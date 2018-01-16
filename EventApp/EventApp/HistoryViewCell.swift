//
//  HistoryViewCell.swift
//  EventApp
//
//  Created by Mihir Patil on 12/11/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import UIKit

class HistoryViewCell: UITableViewCell {
    
    @IBOutlet var lblEventId: UILabel!
    
    @IBOutlet var lblEventName: UILabel!

    @IBOutlet var lblEventDate: UILabel!
    
    @IBOutlet var lblOrderId: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
