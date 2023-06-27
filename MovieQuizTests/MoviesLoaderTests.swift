

import XCTest
@testable import MovieQuiz // импортируем приложение для тестирования

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation") // так как функция загрузки фильмов — асинхронная, нужно ожидание
        
        loader.loadMovies { result in
            
            // Then
            switch result {
            case .success(let movies):
                // сравниваем данные с тем, что мы предполагали
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
                
            case .failure(_):
                // мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Unexpected failure") // эта функция проваливает тест
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            
        // Then
            switch result {
            case .success(_):
                XCTFail("Unexpected failure")
                
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    
}
