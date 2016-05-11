//
//  ViewController.swift
//  Cahoot
//
//  Created by Techtics Ninja on 5/11/16.
//  Copyright © 2016 Cahoot. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController {
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up Appearance
        self.setUpAppearance()
        
    }
    
    func setUpAppearance(){
        // create padding views
        let emailFieldPaddingView = UIView(frame: CGRectMake(0, 0, 10, self.EmailField.frame.height))
        let passwordFieldPaddingView =  UIView(frame: CGRectMake(0, 0, 10, self.EmailField.frame.height))
        // assign the padding views as left views
        self.EmailField.leftView = emailFieldPaddingView
        self.PasswordField.leftView = passwordFieldPaddingView
        // setup the leftViewMode of the textfields
        self.PasswordField.leftViewMode = UITextFieldViewMode.Always
        self.EmailField.leftViewMode = UITextFieldViewMode.Always
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

