//
//  GoogleMapThumbAvaView.swift
//  Fich
//
//  Created by admin on 8/8/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import SnapKit

class GoogleMapThumbAvaView: UIView {
    private let padding: Int = 5
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(){
        self.addSubview(titleLabel)
        self.addSubview(avatar)
        self.backgroundColor = UIColor(rgb: 0x10828C)
        
        self.frame.size = CGSize(width: 150, height: 100)
        self.layer.cornerRadius = 10
        
        self.titleLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(padding)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(35.0)
        }
        self.avatar.snp.makeConstraints { (view) in
            view.top.equalTo(titleLabel.snp.bottom).offset(padding)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(40.0)
        }
    }
    
    var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    var avatar: UIImageView = {
        let ava: UIImageView = UIImageView()
        ava.contentMode = .scaleAspectFit
        ava.frame.size = CGSize(width: 40, height: 40)
        ava.layer.cornerRadius = 20.0
        ava.clipsToBounds = true
        ava.layer.shadowOffset = CGSize(width: -1, height: 1)
        ava.layer.shadowOpacity = 0.2
        return ava
    }()
}
