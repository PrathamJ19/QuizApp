//
//  QuizUpdateViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-16.
//

import UIKit
import FirebaseFirestore

class QuizUpdateViewController: UIViewController {
    
    var quiz: Quiz?
    var currentQuestionIndex = 0
    
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var questionUpdate: UITextField!
    @IBOutlet weak var ansOption1: UITextField!
    @IBOutlet weak var ansOption2: UITextField!
    @IBOutlet weak var ansOption3: UITextField!
    @IBOutlet weak var ansOption4: UITextField!
    @IBOutlet weak var correctAns: UITextField!
    @IBOutlet weak var questionAdd: UIButton!
    
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomDoneButton()
        guard let quiz = quiz else {
            print("Error: Quiz object is nil")
            return
        }
        if quiz.id.isEmpty {
            print("Error: Quiz ID is empty")
            return
        }
        displayCurrentQuestion()
    }
    
    func displayCurrentQuestion() {
        guard let quiz = quiz else { return }
        
        let question = quiz.questions[currentQuestionIndex]
        questionNumLabel.text = "Question \(currentQuestionIndex + 1)"
        questionUpdate.text = question.questionstext
        ansOption1.text = question.options[0]
        ansOption2.text = question.options[1]
        ansOption3.text = question.options[2]
        ansOption4.text = question.options[3]
        correctAns.text = question.correctAnswer
        
        prevBtn.isHidden = currentQuestionIndex == 0
        nextBtn.isHidden = currentQuestionIndex == quiz.questions.count - 1
    }
    
    @IBAction func updateQuestionPressed(_ sender: Any) {
        guard var quiz = quiz else {
                print("Failed to load Quiz ID")
                return
            }
            
            // Validations
            if let updatedQuestionText = questionUpdate.text, !updatedQuestionText.isEmpty,
               let option1 = ansOption1.text, !option1.isEmpty,
               let option2 = ansOption2.text, !option2.isEmpty,
               let option3 = ansOption3.text, !option3.isEmpty,
               let option4 = ansOption4.text, !option4.isEmpty,
               let updatedCorrectAnswer = correctAns.text, !updatedCorrectAnswer.isEmpty {
                

                let updatedOptions = [option1, option2, option3, option4]

                quiz.questions[currentQuestionIndex].questionstext = updatedQuestionText
                quiz.questions[currentQuestionIndex].options = updatedOptions
                quiz.questions[currentQuestionIndex].correctAnswer = updatedCorrectAnswer
                
                print("Updated Question \(currentQuestionIndex + 1): \(updatedQuestionText)")
                print("Options: \(updatedOptions)")
                print("Correct Answer: \(updatedCorrectAnswer)")
                
                saveUpdatedQuiz(quiz: quiz)
            } else {
                let alert = UIAlertController(title: "Error", message: "Please fill all the fields before updating the question.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
    }
    
    
    func saveUpdatedQuiz(quiz: Quiz) {
        guard !quiz.id.isEmpty else {
            print("Error: Quiz ID is empty")
            return
        }
        
        let quizRef = Firestore.firestore().collection("quizzes").document(quiz.id)
        quizRef.setData([
            "id": quiz.id,
            "title": quiz.title,
            "batch": quiz.batch,
            "questions": quiz.questions.map { question in
                return [
                    "id": question.id,
                    "questionText": question.questionstext,
                    "options": question.options,
                    "correctAnswer": question.correctAnswer
                ]
            }
        ]) { error in
            if let error = error {
                print("Error updating quiz: \(error)")
            } else {
                print("Quiz updated successfully!")
            }
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let quiz = quiz else { return }
        
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
            displayCurrentQuestion()
        }
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            displayCurrentQuestion()
        }
    }
    
    func addCustomDoneButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneButtonTapped() {
        let alert = UIAlertController(title: "Form", message: "Are you sure you want to leave Quiz Updater?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done Editing", style: .destructive, handler: { _ in
            self.performSegue(withIdentifier: "goBackToNewQuiz", sender: self)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToAddNewQuestion" {
                if let quizMakerVC = segue.destination as? QuizMakerViewController {
                    quizMakerVC.quiz = quiz
                    quizMakerVC.comingFromVC = "QuizUpdateViewController"
                }
            }
        }
}
