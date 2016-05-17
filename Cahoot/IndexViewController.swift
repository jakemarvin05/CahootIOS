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
    
    @IBOutlet weak var cahootLogoImageView: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView?
    
    @IBAction func loginButtonTouchUpInside(sender: UIButton) {
        // console logger
        print("Login Clicked")
        // extract required field data
        let email = self.emailField.text
        let password =  self.passwordField.text
        //
        if(!email!.isEmpty && !password!.isEmpty){
            // console logger
            print("Fields are validated")
            
            if(self.isValidEmail(email!)){
                // restyle the text field's border color to black
                self.passwordField.layer.borderWidth = 1
                self.passwordField.layer.borderColor = UIColor.blackColor().CGColor
                self.emailField.layer.borderWidth = 1
                self.emailField.layer.borderColor = UIColor.blackColor().CGColor
                
                // Authenticate by email
                self.authenticateEmail(email!, password: password!)
                
            }
            else{
                // restyle the email field's border color to red
                self.emailField.layer.borderWidth = 1
                self.emailField.layer.borderColor = UIColor.redColor().CGColor
                
            }
        }
        else{
            // Handle the passwordField
            if(password!.isEmpty){
                // restyle the password field's border color to red
                self.passwordField.layer.borderWidth = 1
                self.passwordField.layer.borderColor = UIColor.redColor().CGColor
            }
            else{
                // restyle the password field's border color to red
                self.passwordField.layer.borderWidth = 1
                self.passwordField.layer.borderColor = UIColor.blackColor().CGColor
            }
            
            // Handle the emailField
            if(!email!.isEmpty && self.isValidEmail(email!)){
                // restyle the email field's border color to black
                self.emailField.layer.borderWidth = 1
                self.emailField.layer.borderColor = UIColor.blackColor().CGColor
            }
            else{
                // restyle the email field's border color to black
                self.emailField.layer.borderWidth = 1
                self.emailField.layer.borderColor = UIColor.redColor().CGColor
            }
            
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // Executes checking of authentication before loading the view
        
        // Hide the navigation bar
        self.navigationController?.navigationBarHidden = true
        // Style the navigation bar 
        // Change the back button color
        self.navigationController?.navigationBar.tintColor = PRIMARYCOLOR
        // Change the navigation title color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARYCOLOR]
        
        print("view will appear...")
        
        // hide the subviews
        self.hideSubviews()
        
        // show activity indicator
        dispatch_async(dispatch_get_main_queue()){
            self.addActivityIndicator()
        }
        
        // Set up FB Button
        self.loginWithFBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginWithFBButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil){
            
            // User is already logged in, do work such as go to next view controller.
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            
            let defaults = NSUserDefaults.standardUserDefaults()
            // only execute fb authentication when user was fbauthenticated
            if let key2Value: Bool = defaults.boolForKey(UserDefaultsKeys.key2) {
                if(key2Value) {
                    // Authenticate FBToken
                    self.authenticateFBToken(fbtoken: token)
                }
                else{
                    // hide activity indicator
                    dispatch_async(dispatch_get_main_queue()){
                        self.hideActivityIndicator()
                    }
                
                }
            }
            else{
                // hide activity indicator
                dispatch_async(dispatch_get_main_queue()){
                    self.hideActivityIndicator()
                }
            }
        }
        else{
            // check if authenticated via email
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let key1Value: Bool = defaults.boolForKey(UserDefaultsKeys.key1) {
                if(key1Value) {
                    // console logger
                    print("User is already authenticated via email")
                    
                    // Show activity indicator
                    dispatch_async(dispatch_get_main_queue()){
                        self.addActivityIndicator()
                    }
                    
                    // delay by 1 sec before executing to preserve aesthetic
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        // do commonLoginFunctions
                        self.commonLoginFunctions()
                    }
                    
                    
                }
                else{
                    // hide activity indicator
                    dispatch_async(dispatch_get_main_queue()){
                        self.hideActivityIndicator()
                    }
                }
            }
            
            // hide activity indicator
            dispatch_async(dispatch_get_main_queue()){
                self.hideActivityIndicator()
            }
        }
    }
    
    
    func hideSubviews(){
        // set all elements appearance's visibility to hidden
        self.cahootLogoImageView.layer.opacity = 0
        self.emailField.layer.opacity = 0
        self.passwordField.layer.opacity = 0
        self.forgotPasswordButton.layer.opacity = 0
        self.loginButton.layer.opacity = 0
        self.loginWithFBButton.layer.opacity = 0
        self.signUpButton.layer.opacity = 0
    }
    
    
    func showSubviews(){
        // set all elements appearance's visibility to visible
        self.cahootLogoImageView.layer.opacity = 1
        self.emailField.layer.opacity = 1
        self.passwordField.layer.opacity = 1
        self.forgotPasswordButton.layer.opacity = 1
        self.loginButton.layer.opacity = 1
        self.loginWithFBButton.layer.opacity = 1
        self.signUpButton.layer.opacity = 1
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    func authenticateFBToken( fbtoken token: String){
        // Extract user Data
        self.returnUserData();
        
        print(token)
        
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
                        // set UserDefault Values
                        let defaults = NSUserDefaults.standardUserDefaults()
                        // for fb authentication
                        defaults.setBool(true, forKey: UserDefaultsKeys.key2)
                        // for email authentication
                        defaults.setBool(false, forKey: UserDefaultsKeys.key1)
                        defaults.synchronize()
                        
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
    
    
    func authenticateEmail(email: String, password: String){
        // Show the activity indicator
        self.addActivityIndicator()
        
        // print("Authenticating token with string value of: " + token)
        let url = APIDOMAIN + "/auth/login"
        
        // send request to the API
        Alamofire.request(.POST, url , parameters: ["email": email, "password": password])
            .responseJSON { request, response, result in
                switch result {
                    // success
                case .Success(let JSONData):
                    // console logger
                    print("Success with JSON: \(JSONData)")
                    
                    // SwiftyJSON
                    let json = JSON(JSONData)
                    
                    if(json["success"]){
                        // set UserDefault Values
                        let defaults = NSUserDefaults.standardUserDefaults()
                        // for email authentication
                        defaults.setBool(true, forKey: UserDefaultsKeys.key1)
                        // for fb authentication
                        defaults.setBool(false, forKey: UserDefaultsKeys.key2)
                        defaults.synchronize()
                        
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
        
        // show activity indicator
        dispatch_async(dispatch_get_main_queue()){
            self.addActivityIndicator()
        }
        
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
        
        // set UserDefault Values for fb authentication
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: UserDefaultsKeys.key2)
        defaults.synchronize()
    }
    
    
    func commonLoginFunctions(){
        // This is the function executed when the user is successfully authenticated
        
        // console logger
        print("executing common login functions...")
        
        // show all subviews
        self.showSubviews()
        
        // perform the view transition
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("show_tabbar_view", sender: self)
        }
        
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
            // show all subviews
            self.showSubviews()
            
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
    
    override func viewWillDisappear(animated: Bool) {
        // show back the navigation bar
        self.navigationController?.navigationBarHidden = false
    }
    
    
}

