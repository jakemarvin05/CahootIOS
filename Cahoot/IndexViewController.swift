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
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginWithFBButton: FBSDKLoginButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewWillAppear(animated: Bool) {
        // Executes checking of authentication before loading the view
        
        // show activity indicator
        self.addActivityIndicator()
        
        // Set up FB Button
        self.loginWithFBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginWithFBButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil){
            // User is already logged in, do work such as go to next view controller.
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            
            // Authenticate FBToken
            self.authenticateFBToken(fbtoken: token)
        }
        else{
            // hide activity indicator
            self.hideActivityIndicator()
        }
    }
    
    func authenticateFBToken( fbtoken token: String){
        // Extract user Data
        self.returnUserData();
        
        // print("Authenticating token with string value of: " + token)
        let url = APIDOMAIN + "/auth/facebook/ajax"
        
        // send request to the API
        Alamofire.request(.POST, url , parameters: ["access_token": token])
            .responseJSON { request, response, result in
                switch result {
                    // success
                case .Success(let JSONData):
                    // console logger
                    // print("Success with JSON: \(JSONData)")
                    
                    // SwiftyJSON
                    let json = JSON(JSONData)
                    
                    if(json["success"]){
                        // do commonLoginFunctions when success
                        self.commonLoginFunctions()
                    }
                    
                    // fail
                case .Failure(let data, let error):
                    // console logger
                    print("Request failed with error: \(error)")
                    
                    // extract the localizedDescription
                    let errorMessage: String = (error as NSError).localizedDescription
                    
                    // Alert the user about the error
                    self.createAlert("Alert", message: "\(errorMessage)\n Please try again later.", handler: { (UIAlertAction) -> () in
                        // console logger
                        print("Okay was clicked")
                        
                        // hide activity indicator
                        self.hideActivityIndicator()
                    })
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
        // console logger
        print("User Logged In")
        
        if ((error) != nil){
            // Process error
            let errorMessage =  error.localizedDescription
            
            // Alert the user about the error
            self.createAlert("Alert", message: errorMessage as String, handler: { (UIAlertAction) -> () in
                // console logger
                print("Okay was clicked")
                
                // hide activity indicator
                self.hideActivityIndicator()
            })
        }
        else if result.isCancelled {
            // Handle cancellations
            self.createAlert("Alert", message: "Oops, you have cancelled the process. Please Log in with facebook to restart", handler: { (UIAlertAction) -> () in
                // console logger
                print("Okay was clicked")
                
                // hide activity indicator
                self.hideActivityIndicator()
            })
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email"){
                // Do work
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                // Authenticate FBToken
                self.authenticateFBToken(fbtoken: token)
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // console logger
        print("User Logged Out")
    }
    
    func commonLoginFunctions(){
        // This is the function executed when the user is successfully authenticated
        print("executing common login functions...")
        
        // perform the view transition
        performSegueWithIdentifier("show_tabbar_view", sender: self)
        
    }
    
    
    func returnUserData(){
        // set the parameters needed
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields":"email,name,gender"])
        
        // extract the graphRequest data
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil){
                // Process error
                print("Error: \(error)")
            }
            else{
                // show information about the user
                
                // extract the name
                let userName : NSString = result.valueForKey("name") as! NSString
                
                // print the name
                print("Facebook User Name is: \(userName)")
                
                // extract the email
                let userEmail : NSString = result.valueForKey("email") as! NSString
                
                // print the email
                print("Facebook User Email is: \(userEmail)")
            }
        })
    }
    
    
    func setUpAppearance(){
        /// Make Padding for the textFields
        // create padding views
        let emailFieldPaddingView = UIView(frame: CGRectMake(0, 0, 10, self.emailField.frame.height))
        
        let passwordFieldPaddingView =  UIView(frame: CGRectMake(0, 0, 10, self.emailField.frame.height))
        
        // assign the padding views as left views
        self.emailField.leftView = emailFieldPaddingView
        self.passwordField.leftView = passwordFieldPaddingView
        
        // setup the leftViewMode of the textfields
        self.passwordField.leftViewMode = UITextFieldViewMode.Always
        self.emailField.leftViewMode = UITextFieldViewMode.Always
        
        /// Fix the buttons appearance
        // put border to the LoginButton
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = UIColor.blackColor().CGColor
        
        // put border to the SignUpButton
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor.blackColor().CGColor
        
        
    }
    
    func createAlert(title: String, message: String, handler: (UIAlertAction) -> () ){
        // initialize the alert object
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        
        // add action when okay button was clicked
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: handler))
        
        // show the alert view
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /// Showing Activity Indicator
    func addActivityIndicator() {
        // define activityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
        
        // style activityIndicator
        self.activityIndicator?.activityIndicatorViewStyle = .Gray
        self.activityIndicator?.backgroundColor = view.backgroundColor
        self.activityIndicator?.startAnimating()
        
        // show activityIndicator
        view.addSubview(self.activityIndicator!)
    }
    
    /// Hiding Activity Indicator
    func hideActivityIndicator() {
        if self.activityIndicator != nil {
            // remove activityIndicator if set
            self.activityIndicator?.removeFromSuperview()
            
            // destroy activityIndicator object
            self.activityIndicator = nil
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

