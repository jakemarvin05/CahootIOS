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

class IndexViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var LoginWithFBButton: FBSDKLoginButton!
    
    @IBOutlet weak var SignUpButton: UIButton!

    override func viewWillAppear(animated: Bool) {
    // Executes checking of authentication before loading the view
        
        // Set up FB Button
        self.LoginWithFBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.LoginWithFBButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            // Authenticate FBToken
            self.authenticateFBToken(fbtoken: token)
            self.commonLoginFunctions()
        }
        
        
        // Sample Implementation of Alamofire and SwiftyJSON
        Alamofire.request(.GET, "https://httpbin.org/get", parameters: ["key": "value"])
            .responseJSON { request, response, result in
                //                switch result {
                //                // success
                //                case .Success(let JSONData):
                //                    // loggers
                //                   print("Success with JSON: \(JSONData)")
                //
                //                   // SwiftyJSON
                //                   let json = JSON(JSONData)
                //                   print(json["args"]["key"])
                //
                //                    // fail
                //                case .Failure(let data, let error):
                //                    print("Request failed with error: \(error)")
                //                    if let data = data {
                //                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                //                    }
                //                }
        }
    }

    func authenticateFBToken( fbtoken token: String){
       // print("Authenticating token with string value of: " + token)
        let url = APIDOMAIN + "/auth/facebook/ajax"
        Alamofire.request(.POST, url , parameters: ["access_token": token])
            .responseJSON { request, response, result in
                                switch result {
                                // success
                                case .Success(let JSONData):
                                    // loggers
                                  // print("Success with JSON: \(JSONData)")
                
                                   // SwiftyJSON
                                   let json = JSON(JSONData)
                                 
                                   if(json["success"]){
                                        // do commonLoginFunctions when success
                                        self.commonLoginFunctions()
                                    }
                
                                    // fail
                                case .Failure(let data, let error):
                                    print("Request failed with error: \(error)")
                                    if let data = data {
                                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                                    }
                                }
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up Appearance
        self.setUpAppearance()
        
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "show_tabbar_view") {
            // pass data to next view
            //let nextViewController: TabBarViewController = segue.destinationViewController as! TabBarViewController
            
            

        }
    }
    
    /// Handles response from Facebook
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                // Authenticate FBToken
                self.authenticateFBToken(fbtoken: token)
             
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func commonLoginFunctions(){
        // This is the function executed when the user is successfully authenticated
        print("executing common login functions...")
        // perform the view transition
        performSegueWithIdentifier("show_tabbar_view", sender: self)
        
    }
    
 
// # Uncomment this function if data from facebook is needed
//    func returnUserData()
//    {
//        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
//        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
//            
//            if ((error) != nil)
//            {
//                // Process error
//                print("Error: \(error)")
//            }
//            else
//            {
//                print("fetched user: \(result)")
//                let userName : NSString = result.valueForKey("name") as! NSString
//                print("User Name is: \(userName)")
//                let userEmail : NSString = result.valueForKey("email") as! NSString
//                print("User Email is: \(userEmail)")
//            }
//        })
//    }
    

    
    
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

