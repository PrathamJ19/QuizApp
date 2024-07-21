//
//  UserAnswerViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class UserAnswerViewController: UIViewController {
    
    var quizId: String?
    var quiz: Quiz?
    var currentQuestionIndex = 0
    var selectedAnswers: [String?] = []
    
    @IBOutlet weak var quizTitle: UILabel!
    @IBOutlet weak var questionsText: UILabel!
    @IBOutlet var radioBtns: [UIButton]!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQuizData()
        setupRadioButtonAlignment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Exit", style: .done, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc func backButtonPressed() {
        showBackAlert()
    }

    func showBackAlert() {
        let alert = UIAlertController(title: "Warning", message: "All quiz progress will be lost. Do you want to proceed?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupRadioButtonAlignment() {
            for btn in radioBtns {
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0) // Adjust left padding as needed
                config.imagePadding = 10
                btn.configuration = config
                btn.configurationUpdateHandler = { button in
                    var updatedConfig = button.configuration
                    updatedConfig?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
                    button.configuration = updatedConfig
                }
                btn.contentHorizontalAlignment = .leading
                
            }
        }

    // Fetch quiz data from Firestore
    func fetchQuizData() {
        guard let quizId = quizId else { return }
        
        db.collection("quizzes").document(quizId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching quiz: \(error)")
                return
            }
            guard let data = document?.data() else { return }
            self.quiz = self.parseQuizData(data: data)
            self.initializeSelectedAnswers() // Initialize after fetching
            self.setupUI()
        }
    }

    // Parse the quiz data
    func parseQuizData(data: [String: Any]) -> Quiz? {
        let id = data["id"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let questionsData = data["questions"] as? [[String: Any]] ?? []
        var questions: [Question] = []

        for questionData in questionsData {
            let questionId = questionData["id"] as? String ?? ""
            let questionText = questionData["questionText"] as? String ?? ""
            let options = questionData["options"] as? [String] ?? []
            let correctAnswer = questionData["correctAnswer"] as? String ?? ""
            
            let question = Question(id: questionId, questionstext: questionText, options: options, correctAnswer: correctAnswer)
            questions.append(question)
        }

        return Quiz(id: id, title: title, batch: "", questions: questions)
    }

    // Setup UI elements
    func setupUI() {
        guard let quiz = quiz else { return }
        quizTitle.text = quiz.title
        displayCurrentQuestion()
        updateProgressBar()
    }

    // Initialize selected answers
    func initializeSelectedAnswers() {
        guard let quiz = quiz else { return }
        selectedAnswers = Array(repeating: nil, count: quiz.questions.count)
    }

    func displayCurrentQuestion() {
        guard let quiz = quiz, currentQuestionIndex < quiz.questions.count else { return }
        let question = quiz.questions[currentQuestionIndex]
        questionsText.text = question.questionstext

        // Set titles for each answer button
        for (index, btn) in radioBtns.enumerated() {
            btn.setTitle(question.options[index], for: .normal)
            btn.setImage(UIImage(named: "btn_OFF"), for: .normal) // Reset to OFF state
        }

        // Load previously selected answer
        if currentQuestionIndex < selectedAnswers.count,
           let selectedAnswer = selectedAnswers[currentQuestionIndex] {
            for btn in radioBtns {
                if btn.currentTitle == selectedAnswer {
                    btn.setImage(UIImage(named: "btn_ON"), for: .normal)
                }
            }
        }

        // Hide previous button if it's the first question
        prevBtn.isHidden = currentQuestionIndex == 0

        // Hide next button and show submit button if it's the last question
        if currentQuestionIndex == (quiz.questions.count) - 1 {
            nextBtn.isHidden = true
            submitBtn.isHidden = false
        } else {
            nextBtn.isHidden = false
            submitBtn.isHidden = true
        }
    }

    // Update progress bar
    func updateProgressBar() {
        let progress = Float(currentQuestionIndex + 1) / Float(quiz?.questions.count ?? 1)
        progressBar.progress = progress
    }

    // Calculate score
    func calculateScore() -> Int {
        guard let questions = quiz?.questions else { return 0 }
        
        var score = 0
        for (index, question) in questions.enumerated() {
            if selectedAnswers[index] == question.correctAnswer {
                score += 1
            }
        }
        return score
    }

    @IBAction func radioBtnsClicked(_ sender: UIButton) {
        for btn in radioBtns {
            btn.setImage(UIImage(named: btn.tag == sender.tag ? "btn_ON" : "btn_OFF"), for: .normal)
        }
        
        selectedAnswers[currentQuestionIndex] = sender.currentTitle
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        if currentQuestionIndex < (quiz?.questions.count ?? 1) - 1 {
            prevBtn.isHidden = false // Show previous button
            currentQuestionIndex += 1
            displayCurrentQuestion()
            updateProgressBar()
        }
    }

    @IBAction func prevButtonPressed(_ sender: Any) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            displayCurrentQuestion()
            updateProgressBar()
        }
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Submission", message: "Are you sure you want to submit the quiz?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Submit", style: .destructive, handler: { _ in
                let score = self.calculateScore()
                self.performSegue(withIdentifier: "goToResults", sender: score)
            }))
            
            present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            if let resultsVC = segue.destination as? ResultsViewController,
               let score = sender as? Int {
                resultsVC.score = score
                resultsVC.totalQuestions = quiz?.questions.count ?? 0
            }
        }
    }
}
