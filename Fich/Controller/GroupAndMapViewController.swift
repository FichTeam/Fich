//
//  GroupAndMapViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class GroupAndMapViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBackgrounds: [UIView]!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBacground: UIView!
    
    var mapViewController: UIViewController!
    var groupViewController: UIViewController!
    
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "GroupAndMap", bundle: nil)
        mapViewController = storyboard.instantiateViewController(withIdentifier: "mapViewController")
        groupViewController = storyboard.instantiateViewController(withIdentifier: "groupViewController")
        
        viewControllers = [mapViewController, groupViewController]
        
        buttonBackgrounds[selectedIndex].backgroundColor = UIColor.darkGray
        didPressTab(buttons[selectedIndex])
        menuBacground.isHidden = true
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        buttonBackgrounds[previousIndex].backgroundColor = UIColor.lightGray
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        buttonBackgrounds[selectedIndex].backgroundColor = UIColor.darkGray
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    @IBAction func didPressAction(_ sender: UIButton) {
        print("didPressAction")
        menuBacground.isHidden = false
    }
    
    @IBAction func didLostPress(_ sender: UIButton) {
        print("didLostPress")
    }
    
    @IBAction func didBikeBrokenPress(_ sender: UIButton) {
        print("didBikeBrokenPress")
    }
    
    @IBAction func didMessagePress(_ sender: UIButton) {
        print("didMessagePress")
    }
    
    @IBAction func didDismissPress(_ sender: UIButton) {
        print("didDismissPress")
        menuBacground.isHidden = true
    }
}

