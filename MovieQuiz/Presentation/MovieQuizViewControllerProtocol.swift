import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject{
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func clearColor()
    func showNetworkError(message: String)
}
