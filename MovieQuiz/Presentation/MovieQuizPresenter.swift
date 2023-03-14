import UIKit

final class MovieQuizPresenter{
    
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool{
        currentQuestionIndex == questionAmount
    }
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel{
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() , question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        switchToNextQuestion()
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = false
        switchToNextQuestion()
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

