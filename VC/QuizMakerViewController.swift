//
//  QuizMakerViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import FirebaseFirestore

class QuizMakerViewController: UIViewController {
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var option1TextField: UITextField!
    @IBOutlet weak var option2TextField: UITextField!
    @IBOutlet weak var option3TextField: UITextField!
    @IBOutlet weak var option4TextField: UITextField!
    @IBOutlet weak var correctAnswerTextField: UITextField!
    
    var quiz: Quiz?
    let db = Firestore.firestore()
    var comingFromVC: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        if let quiz = quiz {
            print("Quiz received: \(quiz)")
        } else {
            print("Quiz is nil")
        }
    }
    
    @IBAction func addQuestionBtnClicked(_ sender: Any) {
        guard let questionText = questionTextField.text, !questionText.isEmpty,
              let option1 = option1TextField.text, !option1.isEmpty,
              let option2 = option2TextField.text, !option2.isEmpty,
              let option3 = option3TextField.text, !option3.isEmpty,
              let option4 = option4TextField.text, !option4.isEmpty,
              let correctAnswer = correctAnswerTextField.text, !correctAnswer.isEmpty else {
            // Handle empty fields
            showAlert(for: .error(message: "Please fill all the fields before adding the question."))
            return
        }
        
        let questionId = UUID().uuidString
        let question = Question(id: questionId, questionstext: questionText, options: [option1, option2, option3, option4], correctAnswer: correctAnswer)
        
        quiz?.questions.append(question)
        
        if let questions = quiz?.questions {
            print("Questions Array: \(questions)")
        } else {
            print("Questions array is nil.")
        }
        
        updateQuizInFirestore()
        showAlert(for: .quesAddedSuccess)
        clearFields()
    }
    
    func clearFields() {
        questionTextField.text = ""
        option1TextField.text = ""
        option2TextField.text = ""
        option3TextField.text = ""
        option4TextField.text = ""
        correctAnswerTextField.text = ""
    }
    
    func showAlert(for type: AlertType) {
        var alert: UIAlertController
        
        switch type {
        case .quesAddedSuccess:
            alert = UIAlertController(title: "Info", message: "Question added successfully!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
        case .error(let message):
            alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }

    enum AlertType {
        case quesAddedSuccess
        case error(message: String)
    }
    
    func updateQuizInFirestore() {
        guard let quiz = quiz else { return }
        
        let quizData: [String: Any] = [
            "title": quiz.title,
            "batch": quiz.batch,
            "questions": quiz.questions.map { [
                "id": $0.id,
                "questionText": $0.questionstext,
                "options": $0.options,
                "correctAnswer": $0.correctAnswer
            ]}
        ]
        
        print("Quiz Data: \(quizData)")
        
        db.collection("quizzes").document(quiz.id).setData(quizData) { error in
            if let error = error {
                print("Error updating quiz: \(error)")
            } else {
                print("Quiz successfully updated!")
            }
        }
    }
    
    //Button Condition
    func setupNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: true)
            if comingFromVC == "QuizUpdateViewController" {
                addCustomBackButton()
            } else {
                addCustomDoneButton()
            }
        }
    
    //Custom Buttons
    func addCustomBackButton() {
        let doneButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func backButtonTapped() {
        let alert = UIAlertController(title: "Form", message: "Are you sure you want to go back to update?", preferredStyle: .actionSheet)
               
            alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Go Back", style: .destructive, handler: { _ in
                   self.navigationController?.popViewController(animated: true)
               }))
               
               present(alert, animated: true, completion: nil)
    }
    
    func addCustomDoneButton() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneButtonTapped() {
        let alert = UIAlertController(title: "Form", message: "Are you sure you want to leave Quiz Maker?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done Editing", style: .destructive, handler: { _ in
            self.performSegue(withIdentifier: "goBackToNewQuiz", sender: self)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToNewQuiz" {
            if segue.destination is NewQuizViewController {
            }
        }
    }
}
