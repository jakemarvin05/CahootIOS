//
//  ViewController.swift
//  Cahoot
//
//  Created by Techtics Ninja on 5/11/16.
//  Copyright © 2016 Cahoot. All rights reserved.
//

import UIKit

import Alamofire

import SwiftyJSON

class IndexViewController: UIViewController {
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var LoginWithFBButton: UIButton!
    
    @IBOutlet weak var SignUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up Appearance
        self.setUpAppearance()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        Alamofire.request(.GET, "https://httpbin.org/get", parameters: ["key": "value"])
            .responseJSON { request, response, result in
                switch result {
                // success
                case .Success(let JSONData):
                    
                  //  print("Success with JSON: \(JSONData)")
                    let json = JSON(JSONData)
                    print(json["args"]["key"])
                   
                    // fail
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    func setUpAppearance(){
        /// Make Padding for the textFields
        // create padding views
        let emailFieldPaddingView = UIView(frame: CGRectMake(0, 0, 10, self.EmailField.frame.height))
        let passwordFieldPaddingView =  UIView(frame: CGRectMake(0, 0, 10, self.EmailField.frame.height))
        // assign the padding views as left views
        self.EmailField.leftView = emailFieldPaddingView
        self.PasswordField.leftView = passwordFieldPaddingView
        // setup the leftViewMode of the textfields
        self.PasswordField.leftViewMode = UITextFieldViewMode.Always
        self.EmailField.leftViewMode = UITextFieldViewMode.Always
        
        /// Fix the buttons appearance
        // put border to the LoginButton
        self.LoginButton.layer.borderWidth = 1
        self.LoginButton.layer.borderColor = UIColor.blackColor().CGColor
        
        // put border to the SignUpButton
        self.SignUpButton.layer.borderWidth = 1
        self.SignUpButton.layer.borderColor = UIColor.blackColor().CGColor
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

