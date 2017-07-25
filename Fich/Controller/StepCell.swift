//
//  StepCell.swift
//  Fich
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class StepCell: UITableViewCell {
    
    @IBOutlet weak var stepLabel: UILabel!
    
    var step: Step!{
        didSet{
            stepLabel.text! = step.instruction!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
