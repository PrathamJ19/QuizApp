//
//  ResultsViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-14.
//

import UIKit

class ResultsViewController: UIViewController {
    var score: Int = 0
    var totalQuestions: Int = 0

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var totalQuestionsLabel: UILabel!
    @IBOutlet weak var congratulatoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayResults()
        addCustomCloseButton()
    }
    
    func displayResults() {
        scoreLabel.text = "Score: \(score) out of \(totalQuestions)"
        totalQuestionsLabel.text = "Total Questions: \(totalQuestions)"
        
        let percentage = Double(score) / Double(totalQuestions) * 100
        
        switch percentage {
        case 0..<50:
            scoreLabel.textColor = UIColor.red
            congratulatoryLabel.text = "Warning! You scored less than 50%."
        case 50..<70:
            scoreLabel.textColor = UIColor.orange
            congratulatoryLabel.text = "Good effort! You scored above 50%."
        case 70..<80:
            scoreLabel.textColor = UIColor.systemYellow
            congratulatoryLabel.text = "Great job! You scored above 70%."
        case 80...100:
            scoreLabel.textColor = UIColor.green
            congratulatoryLabel.text = "Excellent Score!"
        default:
            scoreLabel.textColor = UIColor.black
            congratulatoryLabel.text = ""
        }
    }
    
    func addCustomCloseButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        let closeButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.rightBarButtonItem = closeButton
    }

    @objc func closeButtonTapped() {
        if let homeVC = navigationController?.viewControllers.first(where: { $0 is HomeViewController }) {
            navigationController?.popToViewController(homeVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
