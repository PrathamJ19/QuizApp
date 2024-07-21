//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var usrEmailText: UITextField!
    
    @IBOutlet weak var usrPassText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = "Login"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        guard let email = usrEmailText.text, !email.isEmpty else {showAlert(for: .error(message: "Please enter a valid email!"))
            return}
        
           guard let password = usrPassText.text, !password.isEmpty else {showAlert(for: .error(message: "Please enter a valid password!"))
               return}
        
        Auth.auth().signIn(withEmail: email, password: password){ firebaseResult, error in
            if let e = error {
                print(e)
                self.usrEmailText.text = ""
                self.usrPassText.text = ""
                self.showAlert(for: .error(message: "Invalid email or Password"))
            } else {
                self.usrEmailText.text = ""
                self.usrPassText.text = ""
                self.performSegue(withIdentifier: "goToHome", sender: self)
                self.showAlert(for: .loginSuccess)
            }
        }
    }
    
    func showAlert(for type: AlertType) {
        var alert: UIAlertController
        
        switch type {
        case .loginSuccess:
            alert = UIAlertController(title: "Login Successful", message: "Your account has been logged in.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
        case .error(let message):
            alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }

    enum AlertType {
        case loginSuccess
        case error(message: String)
    }
}
