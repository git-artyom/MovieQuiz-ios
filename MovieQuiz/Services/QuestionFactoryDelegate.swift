//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Артем Чебатуров on 18.05.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
