//
//  LobbyCell.swift
//  Fich
//
//  Created by admin on 7/22/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LobbyCell: UITableViewCell {
    
    static let id = "LobbyCell"
    static let idXib = "LobbyCellXib"
    
    @IBOutlet weak var leadername: UILabel!
    @IBOutlet weak var avatarLeader: UIImageView!
    @IBOutlet weak var avatarMember1: UIImageView!
    @IBOutlet weak var avatarMember2: UIImageView!
    @IBOutlet weak var avatarMember3: UIImageView!
    @IBOutlet weak var departure: UILabel!
    @IBOutlet weak var destination: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
