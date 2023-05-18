import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    /*
     
     Спасибо за ревью!
     
     ________00000000000000______00000000000000________
     ______000000000000000000__0000000000000000000_____
     ____000000000000000000000000000000________00000___
     ___0000000000000000000000000000000__________0000__
     __0000000000000000000000000000000000__________000_
     __00000000000000000000000000000000000000_____0000_
     _00000000000000000000000000000000000000000___00000
     _000000000000000000000000000000000000000000_000000
     _000000000000000000000000000000000000000000000000_
     _000000000000000000000000000000000000000000000000_
     __00000000000000000000000000000000000000000000000_
     ___000000000000000000000000000000000000000000000__
     _____00000000000000000000000000000000000000000____
     _______0000000000000000000000000000000000000______
     __________0000000000000000000000000000000_________
     _____________00000000000000000000000000___________
     _______________00000000000000000000______________
     __________________000000000000000________________
     ____________________0000000000___________________
     ______________________000000_____________________
     _______________________0000______________________
     ________________________00_______________________
     -------------------------------------------------
     */
    
  
    @IBOutlet private var QuestionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var noButtonClicked: UIButton!
    @IBOutlet weak var yesButtonClicked: UIButton!
    
    
    
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    
    //фабрика вопросов к которой обращается контроллер
    private var questionFactory: QuestionFactory = QuestionFactory()
    
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    
    
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
            image: UIImage(named: model.image) ?? UIImage(),
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
        imageView.layer.borderColor = UIColor.clear.cgColor // setting imageView's border to clear
        
        if currentQuestionIndex == questionsAmount - 1 { // идём в состояние "Результат квиза"
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, Вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
                    let viewModel = QuizResultsViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
                    showResults(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
            }
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func showResults(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
                    title: result.title,
                    message: result.text,
                    preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in //через слабую ссылку избавляемся от ретейн цикла
            guard let self = self else { return } // анврапим слабую ссылку
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }

                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        
        imageView.layer.masksToBounds = true //рисуем рамку
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        //проверяем, что фабрика вернула не nil и показываем первый вопрос
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            
            show(quiz: viewModel)
        }
        super.viewDidLoad()
    }
}


/*
 
 // берём текущий вопрос из массива вопросов по индексу текущего вопроса
 // и вызываем метод show() для первого вопроса
 let currentQuestion = questions[currentQuestionIndex]
 let firstQuestion = convert(model: currentQuestion)
 show(quiz: firstQuestion)
 
 // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
 private func convert(model: QuizQuestion) -> QuizStepViewModel {
     let questionToView = QuizStepViewModel(
         image: UIImage(named: model.image) ?? UIImage(),
         question: model.text,
         questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
     return questionToView
 }
 */
