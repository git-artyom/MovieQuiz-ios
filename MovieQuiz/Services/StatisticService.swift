
import Foundation


protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    // метод для сохранения текущего результата игры.
    func store(correct count: Int, total amount: Int)
}

//модель для message в алерте
struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
}

//расширение реализующее протокол Comparable для структуры GameRecord
extension GameRecord {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    static func <= (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct <= rhs.correct
    }
    static func >= (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    static func > (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct >= rhs.correct
    }
}


final class StatisticServiceImplementation: StatisticService {
    
    //ключи для сохранения в UserDefaults в сеттере
    private enum Keys: String {
        case correct,
             total,
             bestGame,
             gamesCount
    }
    
    //константа для работы с UserDefaults
    private let userDefaults = UserDefaults.standard
    
    
    //общее количество вопросов
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    //количество верных ответов
    var correctAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    //общая точность
    var totalAccuracy: Double {
        Double(correctAnswers) / Double(total) * 100
    }
    
    
    //общее количество игр
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return .init()
            }
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            //сохраняем data в UserDefaults
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // лучшая попытка
    var bestGame: GameRecord {
        
        get { //берем данные из UserDefaults по ключу из энума Keys
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
            return .init(correct: 0, total: 0, date: Date()) // если не получилось спарсить то начальные значения установлены по 0
            }
            return record
        }
        
        set { // преобразуем в Data новое значение структуры данных GameRecord
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            //сохраняем data в UserDefaults
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    
    //метод сохранения лучшего результата, вызывается в методе показа результата
    func store(correct count: Int, total amount: Int) {
        self.total += amount
            self.correctAnswers += count
            self.gamesCount += 1
            let currentGame = GameRecord(correct: count, total: amount, date: Date())
                if bestGame < currentGame {
                    bestGame = currentGame
            }
        }
    
    }

