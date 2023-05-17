//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Артем Чебатуров on 17.05.2023.
//

import Foundation
import UIKit

// вью модель для состояния "Вопрос показан"
private struct QuizStepViewModel {
  // картинка с афишей фильма с типом UIImage
  let image: UIImage
  // вопрос о рейтинге квиза
  let question: String
  // строка с порядковым номером этого вопроса (ex. "1/10")
  let questionNumber: String
}