
import Foundation


struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}


struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    
    //указываем какое поле в json структуре соответствует нашей в swift
    private enum CodingKeys: String, CodingKey {
    case title = "fullTitle"
    case rating = "imDbRating"
    case imageURL = "image"
    }
}
