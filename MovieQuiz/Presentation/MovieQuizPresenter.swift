
import UIKit

final class MovieQuizPresenter {
    
    //общее количество вопросов для квиза
    let questionsAmount: Int = 10
    
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    
    
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
    
    //    func convert(model: QuizQuestion) -> QuizStepViewModel {
    //            QuizStepViewModel(
    //                image: UIImage(data: model.image) ?? UIImage(),
    //                question: model.text,
    //                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
    //            )
    //        }
}
