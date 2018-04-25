//
//  SignUpViewController.swift
//  Texpert
//
//  Created by Alon Katz on 4/18/18.
//  Copyright © 2018 Harmonic Inc. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signUpColors: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUnverifiedUser()
        
        let origImage = UIImage(named: "backIcon");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = lightBlue
        // Do any additional setup after loading the view.
        
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.layer.cornerRadius = 30
        signUpButton.layer.masksToBounds = true
       
        signUpColors.translatesAutoresizingMaskIntoConstraints = false
        signUpColors.layer.cornerRadius = 30
        signUpColors.layer.masksToBounds = true
        
        //HidesKeyboard when screen is pressed
        self.hideKeyboard()
        
        //Adds the swipe back gesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(backSwipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        if (emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != ""){
            if(passwordTextField.text == confirmPasswordTextField.text){
                
                handleRegister()
            } else {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Passwords do not match.", message: "Please make sure that your passwords are matching.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    func handleRegister() {
        SVProgressHUD.show()
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            SVProgressHUD.dismiss()
            return
        }
        
        let reference = Database.database().reference()
        let modifiedEmail = email.replacingOccurrences(of: ".", with: ";")
        
        reference.child("unverifiedUsers").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(modifiedEmail){
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    
                    if let errors = error{
                        if(errors.localizedDescription == "The email address is already in use by another account."){
                            let alert = UIAlertController(title: "Email is already in use", message: "Please use a different email address", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                                self.navigationController?.popViewController(animated: true)
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
//                        if let error1 = error{
//                            print(error1.debugDescription)
//                        }
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    guard let uid = user?.uid else {
                     //   SVProgressHUD.dismiss()
                        return
                    }
                    SVProgressHUD.dismiss()
                    let values = ["email": email]
                    
                    self.sendVerificationEmail()
                    
                    print("Registration Success")
                   
                    self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                   
                  
                    let alert = UIAlertController(title: "Registration Successful", message: "Please verify the email we have sent to \(email)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                })
            } else {
                //
                //Will have to find a way to contact specific administator
                //
                let alert = UIAlertController(title: "Account cannot be created", message: "Please contact your administrator to authorize your email.", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
       // SVProgressHUD.dismiss()
        
        
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
//            self.performSegue(withIdentifier: "registeredSegue", sender: self)

            
        })
       
    }
    
    func sendVerificationEmail() {
        if let user = Auth.auth().currentUser{
            
            user.sendEmailVerification(completion: { (error) in
                if error != nil {
                    print(error!)
                    return
                } 
            })
        }
    }
    
    
    func fetchUnverifiedUser(){
          print("fetched1")
        Database.database().reference().child("unverifiedUsers").observe(.childAdded, with: { (snapshot) in
            print("fetched")
            print(snapshot)

            
            
        }, withCancel: nil)
    }

}
