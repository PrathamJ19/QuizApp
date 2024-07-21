//
//  HomeViewController.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeName: UILabel!
    @IBOutlet weak var availableQuiz: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var quizzes: [Quiz] = []
    var filteredData: [Quiz] = []
    var course: String = ""
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        addCustomLogoutButton()
        fetchUserData()
    }
    
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.course = data?["course"] as? String ?? ""
                let name =  data?["name"] as? String ?? ""
                self.fetchQuizzes(for: self.course)
                self.welcomeName.text = "Welcome, \(name)."
            } else {
                print("User document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchQuizzes(for course: String) {
        db.collection("quizzes").whereField("batch", isEqualTo: course).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.quizzes = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? "No Title"
                    return Quiz(id: id, title: title, batch: course, questions: [])
                } ?? []
                self.filteredData = self.quizzes
                self.tableView.reloadData()
            }
        }
    }
    
    // Custom Button
        func addCustomLogoutButton() {
            self.navigationItem.setHidesBackButton(true, animated: true)
            let closeButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
        }

        @objc func logoutButtonTapped() {
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
                self.navigateToLogin()
            }))
            
            present(alert, animated: true, completion: nil)
        }

        func navigateToLogin() {
            if let loginVC = navigationController?.viewControllers.first(where: { $0 is LoginViewController }) {
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
        tableView.reloadData()
    }

        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            filteredData = quizzes
            tableView.reloadData()
        }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.availableQuiz.text = "Available Quiz for \(course) : \(self.quizzes.count)"
        return filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath)
        let quiz = filteredData[indexPath.row]
        cell.textLabel?.text = quiz.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuiz = filteredData[indexPath.row]
        performSegue(withIdentifier: "goToQuiz", sender: selectedQuiz.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToQuiz" {
            if let userAnswerVC = segue.destination as? UserAnswerViewController,
               let quizId = sender as? String {
                userAnswerVC.quizId = quizId
            }
        }
    }
}
