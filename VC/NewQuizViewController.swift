//
//  NewQuizViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import FirebaseFirestore

class NewQuizViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var quizNameText: UITextField!
    @IBOutlet weak var batchSelectionSegment: UISegmentedControl!
    @IBOutlet weak var updateTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var newQuiz: Quiz?
    var quizzes: [Quiz] = []
    var filteredData: [Quiz] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable.dataSource = self
        updateTable.delegate = self
        searchBar.delegate = self
        addCustomLogoutButton()
        fetchQuizzes()
    }
    
    // Fetch existing quizzes from Firestore
    func fetchQuizzes() {
        db.collection("quizzes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching quizzes: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.quizzes = documents.compactMap { document in
                var quizData = document.data()
                quizData["id"] = document.documentID
                return self.parseQuizData(data: quizData)
            }
            self.filteredData = self.quizzes
            self.updateTable.reloadData()
        }
    }
    
    // Parse quiz data
    func parseQuizData(data: [String: Any]) -> Quiz? {
        let id = data["id"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let batch = data["batch"] as? String ?? ""
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

        return Quiz(id: id, title: title, batch: batch, questions: questions)
    }
    
    @IBAction func createQuizBtnClicked(_ sender: Any) {
        guard let title = quizNameText.text, !title.isEmpty else {
            alert()
            return
        }
        
        let batch = batchSelectionSegment.titleForSegment(at: batchSelectionSegment.selectedSegmentIndex) ?? ""
        let quizId = UUID().uuidString
        
        newQuiz = Quiz(id: quizId, title: title, batch: batch, questions: [])
        
        //Initial Empty Array
        db.collection("quizzes").document(quizId).setData([
            "id": quizId,
            "title": title,
            "batch": batch,
            "questions": []
        ]) { error in
            if let error = error {
                print("Error saving quiz: \(error)")
                return
            }
            self.fetchQuizzes() // Fetch updated quiz list
            self.performSegue(withIdentifier: "goToQuizMaker", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToQuizMaker" {
            if let quizMakerVC = segue.destination as? QuizMakerViewController {
                quizMakerVC.quiz = newQuiz
            }
        } else if segue.identifier == "goToQuizUpdate" {
            if let quizUpdateVC = segue.destination as? QuizUpdateViewController,
               let selectedIndex = sender as? IndexPath {
                quizUpdateVC.quiz = quizzes[selectedIndex.row]
            }
        }
    }
    
    func alert() {
        let alert = UIAlertController(title: "Error", message: "Please add a title!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //Custom Buttons
    func addCustomLogoutButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func performLogout() {
        if let loginVC = navigationController?.viewControllers.first(where: { $0 is StaffLoginViewController }) {
            navigationController?.popToViewController(loginVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredData = quizzes
            } else {
                filteredData = quizzes.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            }
            updateTable.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            filteredData = quizzes
            updateTable.reloadData()
        }
}

extension NewQuizViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizUpdateCell", for: indexPath)
        let quiz = filteredData[indexPath.row]
        cell.textLabel?.text = quiz.title
        return cell
    }
}

extension NewQuizViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToQuizUpdate", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let quizToDelete = filteredData[indexPath.row]
            
            // Delete the quiz from Firestore
            db.collection("quizzes").document(quizToDelete.id).delete { error in
                if let error = error {
                    print("Error deleting quiz: \(error)")
                } else {
                    self.filteredData.remove(at: indexPath.row)
                    self.quizzes.removeAll { $0.id == quizToDelete.id }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
