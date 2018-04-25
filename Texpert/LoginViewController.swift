//
//  ViewController.swift
//  Texpert
//
//  Created by Alon Katz on 4/11/18.
//  Copyright © 2018 Harmonic Inc. All rights reserved.
//

import UIKit
import Firebase

var lightBlue = UIColor(r: 78, g: 175, b: 216)

class LoginViewController: UIViewController {

    @IBOutlet weak var companyLogo: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signInColors: UIImageView!
    
    //var lightBlue = UIColor(r: 78, g: 175, b: 216)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        if Auth.auth().currentUser != nil {
           
//            print(user.email)
//            print(user.isEmailVerified)
            do {
               try Auth.auth().signOut()
                print("signed out")
            } catch let logoutError {
                print(logoutError)
            }
        }
    
        //Setting up logo properties
        companyLogo.image = companyLogo.image!.withRenderingMode(.alwaysTemplate)
        companyLogo.tintColor = lightBlue
        
        //Setting up button properties
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.layer.cornerRadius = 25.5
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = lightBlue.cgColor
        
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.layer.cornerRadius = 25.5
        signInButton.layer.masksToBounds = true
        
        //Set up sign in colors
        
        signInColors.translatesAutoresizingMaskIntoConstraints = false
        signInColors.layer.cornerRadius = 25.5
        signInColors.layer.masksToBounds = true
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
          navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "signUp", sender: self)
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "signIn", sender: self)
        
        
    }
    
}

extension UIColor {

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

