

import Foundation


protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

//Сервис для загрузки фильмов используя NetworkClient и преобразования их в модель данных MostPopularMovies.
struct MoviesLoader: MoviesLoading {
    
    //MARK: - NetworClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    
    // переменная принимает значение url из запроса к imdb api
    private var mostPopularMoviesUrl: URL {
        
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_drjkuoj4") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    // метод загрузки фильмов и заполнения модели данными
    // @escaping - это способ сообщить тем, кто использует нашу функцию, что параметр замыкания где-то хранится и может пережить область действия функции.
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        // fetch – метод, который будет загружать что-то по заранее заданному URL
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result { // в замыкании перебираем варианты развития событий
            case .success(let data): // если успешно: заполняем модель данными
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch { //ловим ошибку из хэндлера, если она есть
                    handler(.failure(error))
                } //если в замыкании пришла ошибка то обрабатываем ее
            case .failure(let error):
                handler(.failure(error))
                }
            }
        }
}
