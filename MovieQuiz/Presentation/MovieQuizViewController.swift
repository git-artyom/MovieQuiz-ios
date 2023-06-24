import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButtonClicked: UIButton!
    @IBOutlet private var noButtonClicked: UIButton!
    @IBOutlet weak var QuestionLabel: UILabel!
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
    }
    
    /*
     
     Спасибо за ревью!
     
     
     
     
     
     override func viewDidLoad() {
     super.viewDidLoad()
     
     presenter = MovieQuizPresenter(viewController: self)
     
     imageView.layer.masksToBounds = true //разрешаем рисовать рамку
     imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
     
     func didReceiveNextQuestion(question: QuizQuestion?) {}
     
     // показываем индикатор загрузки
     presenter.showLoadingIndicator()
     
     }
     
     
     @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
     
     @IBOutlet private var QuestionLabel: UILabel!
     @IBOutlet var imageView: UIImageView!
     @IBOutlet private var textLabel: UILabel!
     @IBOutlet private var counterLabel: UILabel!
     
     @IBOutlet weak var noButtonClicked: UIButton!
     @IBOutlet weak var yesButtonClicked: UIButton!
     
     private var presenter: MovieQuizPresenter!
     
     //тут у нас иньекция зависимостей, инициализируем во viewDidLoad()
     // private var alertPresenter: AlertPresenterProtoсol?
     
     
     
     @IBAction private func noButtonClicked(_ sender: UIButton) {
     presenter.noButtonClicked()
     }
     
     
     
     @IBAction private func yesButtonClicked(_ sender: UIButton) {
     presenter.yesButtonClicked()
     }
     
     func show(quiz step: QuizStepViewModel) {
     imageView.image = step.image
     textLabel.text = step.question
     counterLabel.text = step.questionNumber
     imageView.layer.cornerRadius = 20
     }
     
     func show(quiz result: QuizResultsViewModel) {
     let message = presenter.makeResultsMessage()
     
     let alert = UIAlertController(
     title: result.title,
     message: message,
     preferredStyle: .alert)
     
     let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
     guard let self = self else { return }
     
     self.presenter.restartGame()
     }
     
     alert.addAction(action)
     
     self.present(alert, animated: true, completion: nil)
     }
     
     
     
     func highlightImageBorder(isCorrectAnswer: Bool) {
     imageView.layer.masksToBounds = true
     imageView.layer.borderWidth = 8
     imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
     }
     
     
     
     */
}

