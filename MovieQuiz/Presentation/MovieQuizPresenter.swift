
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    //    func didReceiveNextQuestion(question: QuizQuestion?) {
    //        guard let question = question else { return }
    //
    //        currentQuestion = question
    //        let viewModel = convert(model: question)
    //        DispatchQueue.main.async { [weak self] in
    //            self?.viewController?.show(quiz: viewModel)
    //        }
    //    }
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isYes: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}






/*
 let questionsAmount: Int = 10
 var currentQuestionIndex = 0
 var correctAnswers = 0
 
 private var currentQuestion: QuizQuestion?
 private var alertPresenter: AlertPresenterProtoсol?
 private var questionFactory: QuestionFactoryProtocol?
 private weak var viewController: MovieQuizViewController?
 private let statisticService: StatisticService!
 
 init(viewController: MovieQuizViewController) {
 self.viewController = viewController
 statisticService = StatisticServiceImplementation()
 questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
 questionFactory?.loadData()
 self.showLoadingIndicator()
 }
 
 func yesButtonClicked() {
 
 didAnswer(isCorrect: true)
 let answer = true
 }
 
 func noButtonClicked() {
 
 didAnswer(isCorrect: false)
 let answer = false
 }
 
 private func didAnswer(isCorrect: Bool) {
 guard let currentQuestion = currentQuestion else {
 return
 }
 
 let givenAnswer = isCorrect
 self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
 }
 
 func didReceiveNextQuestion(question: QuizQuestion?) {
 guard let question = question else {
 return
 }
 currentQuestion = question
 let viewModel = convert(model: question)
 DispatchQueue.main.async { [weak self] in
 self?.viewController?.show(quiz: viewModel)
 }
 }
 
 
 func isLastQuestion() -> Bool {
 currentQuestionIndex == questionsAmount - 1
 }
 
 func resetQuestionIndex() {
 currentQuestionIndex = 0
 }
 
 func switchToNextQuestion() {
 currentQuestionIndex += 1
 }
 
 
 
 
 // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
 func convert(model: QuizQuestion) -> QuizStepViewModel {
 let questionToView = QuizStepViewModel(
 image: UIImage(data: model.image) ?? UIImage(),
 question: model.text,
 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
 return questionToView
 }
 
 func showAnswerResult(isCorrect: Bool) {
 
 viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
 
 
 viewController?.yesButtonClicked.isEnabled = false //отключаем обе кнопки чтобы не засчитывалось несколько ответов за раз
 viewController?.noButtonClicked.isEnabled = false
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //через слабую ссылку избавляемся от ретейн цикла
 guard let self = self else { return } // анврапим слабую ссылку
 self.showNextQuestionOrResults()
 viewController?.yesButtonClicked.isEnabled = true // включаем кнопки
 viewController?.noButtonClicked.isEnabled = true
 }
 }
 
 
 // приватный метод, который содержит логику перехода в один из сценариев
 func showNextQuestionOrResults() {
 
 viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
 
 if self.isLastQuestion() {
 
 guard let statisticService = statisticService else {
 print("Не удалось загрузить статистику!")
 return
 }
 
 statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
 let bestGame = statisticService.bestGame
 let viewModel = AlertModel(title: "Этот раунд окончен!",
 message: """
 Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
 Количество сыгранных квизов: \(statisticService.gamesCount)
 Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGame.date.dateTimeString))
 Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
 """,
 buttonText: "Сыграть еще раз",
 completion: { [weak self] in
 guard let self = self else { return }
 
 viewController?.yesButtonClicked.isEnabled = true // включаем кнопки
 viewController?.noButtonClicked.isEnabled = true
 viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
 self.resetQuestionIndex() //сбрасываем счетчики
 self.correctAnswers = 0
 questionFactory?.requestNextQuestion() //запрашиваем новый вопрос
 })
 alertPresenter?.showResult(in: viewModel)
 
 //или показываем следующий вопрос
 } else {
 
 self.switchToNextQuestion()
 questionFactory?.requestNextQuestion()
 
 }
 }
 
 func makeResultsMessage() -> String {
 statisticService.store(correct: correctAnswers, total: questionsAmount)
 
 let bestGame = statisticService.bestGame
 
 let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
 let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
 let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
 + " (\(bestGame.date.dateTimeString))"
 let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
 
 let resultMessage = [
 currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
 ].joined(separator: "\n")
 
 return resultMessage
 }
 
 
 func didLoadDataFromServer() {
 self.hideLoadingIndicator()
 questionFactory?.requestNextQuestion()
 }
 
 func didFailToLoadData(with error: Error) {
 let message = error.localizedDescription
 self.showNetworkError(message: message)
 }
 
 func didRecieveNextQuestion(question: QuizQuestion?) {
 guard let question = question else {
 return
 }
 
 currentQuestion = question
 let viewModel = convert(model: question)
 DispatchQueue.main.async { [weak self] in
 self?.viewController?.show(quiz: viewModel)
 }
 }
 
 func restartGame() {
 currentQuestionIndex = 0
 correctAnswers = 0
 questionFactory?.requestNextQuestion()
 }
 
 
 //метод вызова алерта с отображением типа ошибки
 func showNetworkError(message: String) {
 
 //скрываем индикатор загрузки
 hideLoadingIndicator()
 
 //передаем данные в модель для отображения в алерте
 let model = AlertModel(title: "Ошибка",
 message: message,
 buttonText: "Попробовать еще раз",
 completion: { [weak self] in
 guard let self = self else { return }
 
 self.resetQuestionIndex()
 self.correctAnswers = 0
 self.restartGame()
 })
 
 alertPresenter?.showResult(in: model)
 }
 
 
 //метод показа индикатора загрузки
 func showLoadingIndicator() {
 viewController?.activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
 viewController?.activityIndicator.startAnimating() // включаем анимацию
 }
 
 //метод скрытия индикатора загрузки
 func hideLoadingIndicator() {
 viewController?.activityIndicator.isHidden = true // скрываем индикатор
 viewController?.activityIndicator.stopAnimating() // отключаем анимацию
 }
 
 
 */

