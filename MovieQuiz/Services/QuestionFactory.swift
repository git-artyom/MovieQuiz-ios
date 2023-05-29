//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Артем Чебатуров on 17.05.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    /*
    // массив моковых вопросов
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
   */
    
    private weak var delegate: QuestionFactoryDelegate? 
    
    private let moviesLoader: MoviesLoading // протокол с методом загрузки данных
    
    private var movies: [MostPopularMovie] = [] // фильмы загруженные с сервера
    
    
    //объявляем функцию requestNextQuestion, которая ничего не принимает и возвращает опциональную модель QuizQuestion
    func requestNextQuestion() {
        
        // запускаем код в другом потоке
        DispatchQueue.global().async { [weak self] in
            
            // выбираем произвольный элемент из массива, чтобы показать его
            guard let self = self else { return }
            let index = (0..<movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            //safe — это функция, которую мы добавили в расширении массива. эта функция позволяет безопасно достать элемент из массива. «Безопасно» — то есть если индекс выйдет за пределы размера массива, вместо крэша нам вернётся просто nil
            
            var imageData = Data() // по умолчанию у нас будут просто пустые данные
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL) // заполняем данными
            } catch {
                print("Failed to load image")
            }
            
            // создаем случайное число в заданном диапазоне чтобы вывести его в поле text
            let randomNumber = Int.random(in: 3...9)
            
            // шаблон для вопроса больше/меньше
            let moreOrLess = ["больше", "меньше"].randomElement()

            // Создаём вопрос, определяем его корректность и создаём модель вопроса
            let rating = Float(movie.rating) ?? 0 // превращаем строку в число
            let text = "Рейтинг этого фильма \(moreOrLess!) чем \(randomNumber)?"
            
            var correctAnswer: Bool {
                if rating > Float(randomNumber) && moreOrLess! == "больше" {
                    return rating > Float(randomNumber)
                    
                } else if rating < Float(randomNumber) && moreOrLess! == "больше" {
                        return rating < Float(randomNumber)
                    
                } else if rating > Float(randomNumber) && moreOrLess! == "меньше" {
                    return rating < Float(randomNumber)
                    
                } else {
                    return rating > Float(randomNumber)
                }
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            //возвращаем наш вопрос через делегат в главный поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
        
        
        
        /* старый метод
         guard let index = (0..<questions.count).randomElement() else {
         delegate?.didReceiveNextQuestion(question: nil)
         return
         }
         
         let question = questions[safe: index]
         delegate?.didReceiveNextQuestion(question: question)
         //safe — это функция, которую мы добавили в расширении массива. эта функция позволяет безопасно достать элемент из массива. «Безопасно» — то есть если индекс выйдет за пределы размера массива, вместо крэша нам вернётся просто nil
         
         
         let rating = Float(movie.rating) ?? 0 // превращаем строку в число
         let text = "Рейтинг этого фильма больше чем \(randomNumber)?"
         let correctAnswer = rating > Float(randomNumber)
         */
    }
    
    
    
    
    // метод для инициализации загрузки данных с сервера
    func loadData() {
        
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                    
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}


