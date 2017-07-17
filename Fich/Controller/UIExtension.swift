//
//  UIExtension.swift
//  Fich
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

extension UIViewController {
    // Hiển thị thông báo đơn giản
    func alert(title: String, message: String) {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Hiện thông báo xong làm gì đó
    func alert(title: String, message: String, handler: @escaping (UIAlertAction) -> Void ) {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Thêm nút Done để ẩn đi bàn phím
    func addDoneButton(to control: UITextField){
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: control,
                            action: #selector(UITextField.resignFirstResponder))
        ]
        
        toolbar.sizeToFit()
        control.inputAccessoryView = toolbar
    }
    
    func addDoneButton(_ textview: UITextView){
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: textview,
                            action: #selector(UITextField.resignFirstResponder))
        ]
        
        toolbar.sizeToFit()
        textview.inputAccessoryView = toolbar
    }
    
    func addDoneButton(tos controls: [UITextField]){
        
        for control in controls {
            let toolbar = UIToolbar()
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: control,
                                action: #selector(UITextField.resignFirstResponder))
            ]
            
            toolbar.sizeToFit()
            control.inputAccessoryView = toolbar
        }
    }
}

extension UITextField {
    func isEmpty() -> Bool {
        return self.text?.characters.count == 0
    }
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        if isEditing{
            border.borderColor = UIColor.blue.cgColor
        }else{
            border.borderColor = UIColor.lightGray.cgColor
        }
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UITextView {
    func isEmpty() -> Bool {
        return self.text?.characters.count == 0
    }
}

