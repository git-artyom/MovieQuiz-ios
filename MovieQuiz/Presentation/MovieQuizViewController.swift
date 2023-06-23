import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    /*
     
     Спасибо за ревью!
     
     
     */
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
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
    
    
    private let presenter = MovieQuizPresenter()
    
    //тут у нас иньекция зависимостей, инициализируем во viewDidLoad()
    private var alertPresenter: AlertPresenterProtoсol?
    
    //    // переменная с индексом текущего вопроса, начальное значение 0
    //    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    //    //общее количество вопросов для квиза
    //    private let questionsAmount: Int = 10
    
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
        hideLoadingIndicator()
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let answer = false
//        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let answer = true
//
//
//        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
        // приватный метод, который и меняет цвет рамки, и вызывает метод перехода
        // принимает на вход булевое значение и ничего не возвращает
        func showAnswerResult(isCorrect: Bool) {
        
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
    
    //    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    //    private func convert(model: QuizQuestion) -> QuizStepViewModel {
    //        let questionToView = QuizStepViewModel(
    //            image: UIImage(data: model.image) ?? UIImage(),
    //            question: model.text,
    //            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    //        return questionToView
    //    }
    
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
        if presenter.isLastQuestion() {
            
            guard let statisticService = statisticService else {
                print("Не удалось загрузить статистику!")
                return
            }
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let bestGame = statisticService.bestGame
            let viewModel = AlertModel(title: "Этот раунд окончен!",
                                       message: """
                                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
                self.presenter.resetQuestionIndex() //сбрасываем счетчики
                self.correctAnswers = 0
                questionFactory?.requestNextQuestion() //запрашиваем новый вопрос
            })
            alertPresenter?.showResult(in: viewModel)
            
            //или показываем следующий вопрос
        } else {
            showLoadingIndicator()
            
            presenter.switchToNextQuestion()
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
                               buttonText: "Попробовать еще раз",
                               completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            questionFactory?.loadData()
        })
        
        alertPresenter?.showResult(in: model)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    
    
    
    
    /*
     func showFirework() {
     CATransaction.begin()
     
     let emitter = CAEmitterLayer()
     emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.maxY)
     emitter.emitterSize = CGSize(width: 100, height: 100)
     emitter.emitterShape = .circle
     emitter.emitterMode = .outline
     
     let cell = CAEmitterCell()
     cell.contents = UIImage(named: "spark.png")?.cgImage
     cell.birthRate = 50
     cell.lifetime = 1.5
     cell.velocity = 200
     cell.velocityRange = 50
     cell.emissionLongitude = -.pi / 2
     cell.emissionRange = .pi / 4
     cell.scale = 0.1
     cell.scaleRange = 0.05
     cell.alphaSpeed = -0.1
     cell.color = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1).cgColor
     
     emitter.emitterCells = [cell]
     view.layer.addSublayer(emitter)
     
     let animation = CABasicAnimation(keyPath: "emitterCells.cell.scale")
     animation.fromValue = 0.1
     animation.toValue = 1
     animation.duration = 5.0
     animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
     
     let moveAnimation = CABasicAnimation(keyPath: "emitterPosition.y")
     moveAnimation.fromValue = view.bounds.maxY
     moveAnimation.toValue = view.bounds.midY
     moveAnimation.duration = 5.0
     moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
     
     emitter.add(moveAnimation, forKey: "move")
     
     CATransaction.setCompletionBlock({emitter.removeFromSuperlayer()})
     
     CATransaction.commit()
     }
     
     метод показа фейерверка, который я допилю в свободное время
     
     Здесь мы устанавливаем emitterMode в outline, чтобы частицы стреляли вверх, а emitterShape в circle, чтобы частицы распределялись равномерно вокруг центральной точки. Затем мы устанавливаем emitterSize в размер, который мы хотим, чтобы занимал наш эффект фейерверка на экране.
     
     Затем мы создаем CAEmitterCell, который будет использоваться для создания частиц. Мы устанавливаем изображение, которое будет использоваться для отображения частиц, а также различные свойства, такие как скорость, время жизни, цвет и т.д.
     
     Затем мы добавляем CAEmitterCell в CAEmitterLayer и добавляем CAEmitterLayer на экран. Мы также создаем анимацию, которая увеличивает размер частиц и анимацию, которая перемещает CAEmitterLayer вверх на экране.
     
     */
    
    
    
    
}

