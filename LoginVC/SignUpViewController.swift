//
//  SignUpViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var usrNameText: UITextField!
    @IBOutlet weak var usrEmailText: UITextField!
    @IBOutlet weak var usrPassText: UITextField!
    @IBOutlet weak var usrPassConfirmText: UITextField!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    let courses = ["BA", "ITS", "UI/UX"]
    var selectedCourse: String?
    var isGoingBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coursePicker.delegate = self
        coursePicker.dataSource = self
        selectedCourse = courses[0]
        
        self.navigationItem.hidesBackButton = true //Hide Default Navigation Button
        let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCourse = courses[row]
    }
    
    func showAlert(for type: AlertType) {
        var alert: UIAlertController
        
        switch type {
        case .discardChanges:
            alert = UIAlertController(title: "Are you sure you want to leave Sign Up?", message: "", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { action in
                self.isGoingBack = true
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
            
        case .signupSuccess:
            alert = UIAlertController(title: "Sign Up Successful", message: "Your account has been created.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
        case .error(let message):
            alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }

    enum AlertType {
        case discardChanges
        case signupSuccess
        case error(message: String)
    }
    
    func handleFirebaseAuthError(_ error: Error) {
        if let nsError = error as NSError? {
            let errorCode = AuthErrorCode.Code(rawValue: nsError.code)
            let errorMessage: String
            switch errorCode {
            case .emailAlreadyInUse:
                errorMessage = nsError.localizedDescription
            default:
                errorMessage = "Something went wrong. Try again."
            }
            self.showAlert(for: .error(message: errorMessage))
        } else {
            self.showAlert(for: .error(message: "Something went wrong. Try again."))
        }
    }

    @IBAction func signupBtnClicked(_ sender: Any) {
        guard let email = usrEmailText.text, !email.isEmpty else {
            showAlert(for: .error(message: "Please enter a valid mail!"))
            return
        }
        guard let name = usrNameText.text, !name.isEmpty else {
            showAlert(for: .error(message: "Please enter a valid name!"))
            return
        }
        
        guard let password = usrPassText.text, !password.isEmpty, password.count >= 6 else {
            showAlert(for: .error(message: "Please enter a valid Password! Passwords cannot be less than 6 characters."))
            return
        }
        guard let confirmPassword = usrPassConfirmText.text, !confirmPassword.isEmpty else {
            showAlert(for: .error(message: "Please enter a valid password again!"))
            return
        }
        
        if password == confirmPassword {
            Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
                if let error = error {
                    self.handleFirebaseAuthError(error)
                    return
                }
                
                guard let user = firebaseResult?.user, let course = self.selectedCourse else {
                    self.showAlert(for: .error(message: "Something went wrong. Try again."))
                    return
                }
                
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "email": email,
                    "course": course,
                    "name": name
                ]) { error in
                    if let error = error {
                        print("Error saving user data: \(error)")
                        self.showAlert(for: .error(message: "Error saving user data. Try again."))
                    } else {
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                        self.showAlert(for: .signupSuccess)
                    }
                }
            }
        } else {
            showAlert(for: .error(message: "Passwords do not match!"))
        }
    }
    
    @objc func backButtonPressed() {
        if usrNameText.text?.isEmpty == false || usrEmailText.text?.isEmpty == false || usrPassText.text?.isEmpty == false || usrPassConfirmText.text?.isEmpty == false {
            showAlert(for: .discardChanges)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
