//
//  SignInViewController.swift
//  Texpert
//
//  Created by Alon Katz on 4/18/18.
//  Copyright © 2018 Harmonic Inc. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var companyLogo: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signInColors: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var keyboardUp: Bool!
    
    var lightBlue = UIColor(r: 78, g: 175, b: 216)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardUp = false;
        
        companyLogo.image = companyLogo.image!.withRenderingMode(.alwaysTemplate)
        companyLogo.tintColor = lightBlue
        
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.layer.cornerRadius = 30
        signInButton.layer.masksToBounds = true
        
        //Set up sign in colors
        
        signInColors.translatesAutoresizingMaskIntoConstraints = false
        signInColors.layer.cornerRadius = 30
        signInColors.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        let origImage = UIImage(named: "backIcon");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = lightBlue
        
        self.hideKeyboard()
        
        //Adds the swipe back gesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(backSwipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
  
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if(emailTextField.text != "" && passwordTextField.text != ""){
            
            handleLogin()
            
        }
    }
    
    func isUserVerified(user: User){
        
        //When entering this stage, the user is logged in but not yet verified
        
        let reference = Database.database().reference()
        if let modifiedEmail = user.email?.replacingOccurrences(of: ".", with: ";"){
            
            reference.child(UNVERIFIEDUSERS).observeSingleEvent(of: .value) { (snapshot) in
                
                print("The snapshot is \(snapshot)")
                
                
                if(user.isEmailVerified){
                    //Account is in Database and is verified
                    reference.child(UNVERIFIEDUSERS).child(modifiedEmail).removeValue()
                    
                    SVProgressHUD.dismiss()
                    
                    if user.uid == "0UeKUDPTfcdoLoEhXkFLCippjBi1"{
                        //This is the admin login
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        print("admin Login")
                        self.handleSegues(segue: "adminLogin")
                    } else {
                        //This is the normal user login
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                       
                    }
                    
                } else {
                    //Account has been created but not been verified
                    SVProgressHUD.dismiss()
                    print("Would you like us to resend an authenication email")
                    let alert = UIAlertController(title: "Email has not been verified", message: "Would you like us to send you another verification email?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
                        user.sendEmailVerification(completion: { (error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                        })
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func handleSegues(segue: String){
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text            else {
            print("Form is not Valid")
            print(3)
            
            return
        }
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                //Alert pops up when the password and email do not match
                if (error?.localizedDescription == "The password is invalid or the user does not have a password."){
                    let alert = UIAlertController(title: "Account not found", message: "Your email and/or password maybe incorrect.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            
            print("Login Success")
            if let user = Auth.auth().currentUser{
                self.isUserVerified(user: user)
            }
            
        })
    }
}



extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func backSwipeAction(swipe:UISwipeGestureRecognizer)
    {
        navigationController?.popViewController(animated: true)
    }
}


