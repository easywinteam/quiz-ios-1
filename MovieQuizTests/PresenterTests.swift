import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol{
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {

    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func clearColor() {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase{
    func testPresenterConvertModel() throws{
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "QuestionText", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "QuestionText")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
