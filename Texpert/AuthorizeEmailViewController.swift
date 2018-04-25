//
//  authorizeEmailViewController.swift
//  Texpert
//
//  Created by Alon Katz on 4/24/18.
//  Copyright © 2018 Harmonic Inc. All rights reserved.
//

import UIKit
import Firebase

let UNVERIFIEDUSERS = "unverifiedUsers"

class AuthorizeEmailViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var confirmEmailTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var buttonColor: UIImageView!
    
    @IBOutlet weak var checkboxButton: UIButton!

    var isAnAdmin = false
    
    let box1: UIImage = UIImage(named: "uncheckedBox")!
    
    let box2: UIImage = UIImage(named: "checkedBox")!
    
    var tint1: UIImage!
    
    var tint2: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTints()
        
//        let origImage1 = UIImage(named: "uncheckedBox");
//        let tintedImage1 = origImage1?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//
        
        
        
        checkboxButton.setImage(tint1, for: .normal)
        checkboxButton.tintColor = lightBlue
        
        self.hideKeyboard()
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTints(){

        tint1 = box1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        tint2 = box2.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
    
    func clearTextfields(){
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        emailTextField.text = ""
        confirmEmailTextField.text = ""
        phoneNumberTextField.text = ""
        isAnAdmin = false
        checkboxButton.setImage(tint1, for: .normal)
    }
    
    @IBAction func authorizePressed(_ sender: UIButton) {
        if (emailTextField.text != "" && phoneNumberTextField.text != "" && confirmEmailTextField.text != "" && lastNameTextField.text != "" && firstNameTextField.text != ""){
            if(emailTextField.text == confirmEmailTextField.text){
                handleRegister(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, phoneNumber: phoneNumberTextField.text!)
                
            }
        }
    }
    
    
    
    func handleRegister(firstName: String, lastName: String, email: String, phoneNumber: String){
    
        let modEmail = email.replacingOccurrences(of: ".", with: ";")
        let modifiedEmail = modEmail.lowercased()
        
        let values = ["firstName": firstName, "lastName": lastName, "email": email, "phoneNumber": phoneNumber, "admin": isAnAdmin] as [String : Any]
        
        authorizeEmailIntoDatabaseWithModifiedEmail(modifiedEmail: modifiedEmail, values: values as [String : AnyObject])
    }
    
    fileprivate func authorizeEmailIntoDatabaseWithModifiedEmail(modifiedEmail: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child(UNVERIFIEDUSERS).child(modifiedEmail)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            self.clearTextfields()
            print("Successful authorization")
            //            self.performSegue(withIdentifier: "registeredSegue", sender: self)
            
            
        })
        
    }
    
    @IBAction func checkboxPressed(_ sender: UIButton) {
        if (isAnAdmin){
            checkboxButton.setImage(tint1, for: .normal)
            isAnAdmin = false
        } else {
            checkboxButton.setImage(tint2, for: .normal)
            isAnAdmin = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
