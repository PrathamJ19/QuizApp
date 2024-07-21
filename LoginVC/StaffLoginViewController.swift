//
//  StaffViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit

class StaffLoginViewController: UIViewController {
    
    
    @IBOutlet weak var staffIDtext: UITextField!
    @IBOutlet weak var staffPassText: UITextField!
    var isGoingBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe back button action
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @IBAction func loginBtnClicked(_ sender: Any) {
        guard let id = staffIDtext.text, !id.isEmpty else { showAlert(for: .error(message: "Please enter valid ID."))
            return }
        guard let pass = staffPassText.text, !pass.isEmpty else { showAlert(for: .error(message: "Please enter valid password."))
            return }
        
        if id == "pratham" && pass == "1234" {
            self.performSegue(withIdentifier: "goToQuizManager", sender: self)
            self.staffIDtext.text=""
            self.staffPassText.text=""
            self.showAlert(for: .loginSuccess)
        } else {
            self.showAlert(for: .error(message: "Invalid ID or Password"))
        }
    }
    
    func showAlert(for type: AlertType) {
        var alert: UIAlertController
        
        switch type {
        case .loginSuccess:
            alert = UIAlertController(title: "Login Successful", message: "Your account has been logged in.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
        case .discardChanges:
            alert = UIAlertController(title: "", message: "Are you sure you want to leave Staff Login?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Leave Login", style: .destructive, handler: { action in
                self.isGoingBack = true
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        case .error(let message):
            alert = UIAlertController(title: "Caution", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }

    enum AlertType {
        case loginSuccess
        case discardChanges
        case error(message: String)
    }
    
    @objc func backButtonPressed() {
        if staffPassText.text?.isEmpty == false || staffIDtext.text?.isEmpty == false  {
            showAlert(for: .discardChanges)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
