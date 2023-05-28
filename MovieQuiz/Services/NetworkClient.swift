
import Foundation

// сервис, для работы с сетью.
/// Отвечает за загрузку данных по URL
struct NetworkClient {

    private enum NetworkError: Error {
        case codeError
    }
    
    //метод, который будет загружать что-то по заранее заданному URL.
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        // заполняем константу данными через метод URLSession
        // в замыкании возвращаем ошибку, если есть, код ошибки, если есть, и данные
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Обрабатываем код ответа и проверяем, что ответ сервера положительный
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Обрабатываем успешный ответ и возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        
        //выполняем сессию
        task.resume()
    }
}
