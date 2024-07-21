//
//  Quiz.swift
//  QuizApp
//
//  Created by Pratham Jadhav on 2024-07-13.
//

import Foundation

struct User {
    let id: String
    let email: String
    let batch: String
}

struct Quiz {
    var id: String
    var title: String
    var batch: String
    var questions: [Question]
}

struct Question {
    var id: String
    var questionstext: String
    var options: [String]
    var correctAnswer: String
}
