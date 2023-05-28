import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    /*
     
     Спасибо за ревью!

     */
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true //разрешаем рисовать рамку
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        //инициализируем статистику
        statisticService = StatisticServiceImplementation()
        
        //инициализируем алерт
        alertPresenter = AlertPresenter(viewController: self)
        
        // MARK: - QuestionFactoryDelegate
        
        //инициализируем делегат фабрики вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        func didReceiveNextQuestion(question: QuizQuestion?) {}
        
        // показываем индикатор загрузки
        showLoadingIndicator()
        
        //начинаем загрузку данных
        questionFactory?.loadData()
    }
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var QuestionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var noButtonClicked: UIButton!
    @IBOutlet weak var yesButtonClicked: UIButton!
    
    //тут у нас иньекция зависимостей, инициализируем во viewDidLoad()
    private var alertPresenter: AlertPresenterProtoсol?
    
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    
    //фабрика вопросов к которой обращается контроллер
    private var questionFactory: QuestionFactoryProtocol?
    
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    //статистика
    private var statisticService: StatisticService?
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    //no button private func
    @IBAction private func noButtonClicked(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
            let answer = false
            showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }

    
    //yes button private func
    @IBAction private func yesButtonClicked(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
            let answer = true
            showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
    // приватный метод, который и меняет цвет рамки, и вызывает метод перехода
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        
        //Проверяем, правильно ли ответил пользователь
        if isCorrect {
                correctAnswers += 1
            }
        //показываем рамку зависящего от ответа пользователя цвета
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButtonClicked.isEnabled = false //отключаем обе кнопки чтобы не засчитывалось несколько ответов за раз
        noButtonClicked.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //через слабую ссылку избавляемся от ретейн цикла
            guard let self = self else { return } // анврапим слабую ссылку
            self.showNextQuestionOrResults()
            self.yesButtonClicked.isEnabled = true // включаем кнопки
            self.noButtonClicked.isEnabled = true
        }
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionToView = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionToView
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        
        // устанавливаем цвет рамки на clear
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        // идём в состояние "Результат квиза"
        if currentQuestionIndex == questionsAmount - 1 {
            
            guard let statisticService = statisticService else {
                print("Не удалось загрузить статистику!")
                return
            }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame
            let viewModel = AlertModel(title: "Этот раунд окончен!",
                                   message: """
                                Ваш результат: \(correctAnswers)/\(questionsAmount)
                                Количество сыгранных квизов: \(statisticService.gamesCount)
                                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGame.date.dateTimeString))
                                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                """,
                                   buttonText: "Сыграть еще раз",
                                   completion: { [weak self] in
                guard let self = self else { return }
                
                self.yesButtonClicked.isEnabled = true // включаем кнопки
                self.noButtonClicked.isEnabled = true
                self.imageView.layer.borderColor = UIColor.clear.cgColor
                self.currentQuestionIndex = 0  //сбрасываем счетчики
                self.correctAnswers = 0
                questionFactory?.requestNextQuestion() //запрашиваем новый вопрос
            })
            alertPresenter?.showResult(in: viewModel)
            
            //или показываем следующий вопрос
        } else {
            currentQuestionIndex += 1
            questionFactory?.self.requestNextQuestion()
        }
    }
    
    
    
    //метод показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    //метод скрытия индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор
        activityIndicator.stopAnimating() // отключаем анимацию
    }
    
    
    //метод вызова алерта с отображением типа ошибки
    private func showNetworkError(message: String) {
        
        //скрываем индикатор загрузки
        hideLoadingIndicator()
        
        //передаем данные в модель для отображения в алерте
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showResult(in: model)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    
    
}

