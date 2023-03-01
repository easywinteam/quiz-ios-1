import Foundation

protocol QuestionFactoryDelegate: AnyObject{
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() //Сообщение об успешной загрузе
    func didFailToLoadData(with error: Error) //сообщение об ошибке загрузки 
}
