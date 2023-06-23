
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
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
            viewController.showLoadingIndicator()
        }
    
    func yesButtonClicked() {
        
        didAnswer(isYes: true)
        let answer = true
    }
    
    func noButtonClicked() {
        
            didAnswer(isYes: false)
            let answer = false
    }
    
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
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
        didAnswer(isYes: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
//        //показываем рамку зависящего от ответа пользователя цвета
//        imageView.layer.borderWidth = 8
//        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
        
        // устанавливаем цвет рамки на clear
        viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
        
        // идём в состояние "Результат квиза"
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
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    
    func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
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
    
    
    
    
   
}
