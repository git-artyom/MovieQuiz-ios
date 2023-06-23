import UIKit

final class MovieQuizViewController: UIViewController {
    
    /*
     
     Спасибо за ревью!
     
     
     */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)

        imageView.layer.masksToBounds = true //разрешаем рисовать рамку
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        func didReceiveNextQuestion(question: QuizQuestion?) {}
        
        // показываем индикатор загрузки
        showLoadingIndicator()
  
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
    private var alertPresenter: AlertPresenterProtoсol?


    
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
    
   
    //метод показа индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    //метод скрытия индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор
        activityIndicator.stopAnimating() // отключаем анимацию
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
            
            self.presenter.resetQuestionIndex()
            presenter.correctAnswers = 0
            self.presenter.restartGame()
        })
        
        alertPresenter?.showResult(in: model)
    }

    
}

