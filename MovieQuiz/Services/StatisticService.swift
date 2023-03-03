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
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        return Double(correct) / Double(total) * 100.0
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
        incrementGamesCount()
        calculateNewAccuracy(correct: count, total: amount)
    }
    private func incrementGamesCount(){
        userDefaults.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
    }
    //Функция сохраняет количества правильных ответов и заданных вопросов в дефолтсы. Таким образом вычисляется обновленная точность правильных ответов totalAccuracy
    private func calculateNewAccuracy(correct count: Int, total amount: Int){
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        userDefaults.set(correct + count, forKey: Keys.correct.rawValue)
        userDefaults.set(total + amount, forKey: Keys.total.rawValue)
    }
}
