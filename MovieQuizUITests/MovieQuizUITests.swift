//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Артем Чебатуров on 20.06.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        
        sleep(5) // устанавливаем задержку выполнения
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation // Вычисляемое свойство pngRepresentation возвращает нам скриншот в виде данных (тип Data)
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        
        sleep(1)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData) // проверяем, что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() throws {
        
        sleep(5)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(1)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
        
    }
    
    func testGameFinish() {
        
        sleep(15)
        
        for _ in 1...10 { // 10 раз "нажимаем" на кнопку чтобы дойти до состояния показа алерта
            app.buttons["No"].tap()
            sleep(4)
        }

        let alert = app.alerts["Game results"] // айдентифаер алерта задается при его создании в AlertPresenter
        
        XCTAssertTrue(alert.exists) // проверяем, что алерт появился
        XCTAssertTrue(alert.label == "Этот раунд окончен!") // проверяем текст алерта
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз") // ищет первую кнопку на алерте, и метод нам подходит, так как кнопка всего одна.
    }

    // метод проверки отключения алерта по нажатию кнопки
    func testAlertDismiss() {
        
        sleep(15)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
