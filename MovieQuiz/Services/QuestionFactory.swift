//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Артем Чебатуров on 17.05.2023.
//

import Foundation

class QuestionFactory {
    
    // массив вопросов
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
   
    //объявляем функцию requestNextQuestion, которая ничего не принимает и возвращает опциональную модель QuizQuestion
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0..<questions.count).randomElement() else {  //выбираем случайный индекс вопроса от 0 до общего кол-ва вопросов
                                                                        // функция randomElement() возвращает опционал поэтопу анврапим результат
            return nil
        }
        return questions[safe: index]   //safe — это функция, которую мы добавили в расширении массива. эта функция позволяет безопасно достать элемент из массива. «Безопасно» — то есть если индекс выйдет за пределы размера массива, вместо крэша нам вернётся просто nil.
    }
    

    
    
}
