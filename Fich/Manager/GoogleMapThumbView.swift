//
//  GoogleMapThumbView.swift
//  Fich
//
//  Created by admin on 7/30/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import SnapKit

class GoogleMapThumbView: UIView {
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
        self.addSubview(snippetLabel)
        self.backgroundColor = UIColor(rgb: 0x10828C)
        
        self.frame.size = CGSize(width: 150, height: 100)
        self.layer.cornerRadius = 10
        
        self.titleLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(padding)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(35.0)
        }
        self.snippetLabel.snp.makeConstraints { (view) in
            view.top.equalTo(titleLabel.snp.bottom).offset(padding)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(35.0)
        }
    }
    func fillData(name: String) {
        titleLabel.text = name
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
    
    var snippetLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .white
        //label.text = "Tap/untap to add/remove stop!"
        return label
    }()
    
//    var button: UIButton = {
//        let button : UIButton = UIButton()
//        button.backgroundColor = UIColor(rgb: 0x10828C)
//        button.setTitle("Tap again to add this to your stops!", for: .normal)
//        button.addTarget(self, action:#selector(GoogleMapThumbView.handleRegister(sender:)), for: .touchUpInside)
//
//        return button
//    }()
//
//    func handleRegister(sender: UIButton){
//        print("Tap again to add this to your stops!")
//    }
}
