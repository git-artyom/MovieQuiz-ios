//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Артем Чебатуров on 18.05.2023.
//
import UIKit
import Foundation

struct AlertModel {
    // строка с заголовком алерта
    let title: String
    // строка с текстом о количестве набранных очков
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    //замыкание без параметров
    let completion: (() -> Void) //UIAlertAction
}

/*
 Структура AlertModel должна содержать:
 текст заголовка алерта title
 текст сообщения алерта message
 текст для кнопки алерта buttonText
 замыкание без параметров для действия по кнопке алерта completion
 */
