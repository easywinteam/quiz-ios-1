import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    var totalAccuracy: Double{
        return userDefaults.double(forKey: Keys.total.rawValue)
    }
    var gamesCount: Int{
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    var bestGame: GameRecord{
        get{
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set{
            guard let data = try? JSONEncoder().encode(newValue) else{
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newResult = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < newResult{
            bestGame = newResult
        }
    }
    
    
}
