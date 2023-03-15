import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewController){
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    func isLastQuestion() -> Bool{
        currentQuestionIndex == questionAmount
    }
    func restartGame() {
        questionFactory?.requestNextQuestion()
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel{
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() , question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = isYes
        switchToNextQuestion()
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func showNextQuestionsOrResults(){
        viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
        if self.isLastQuestion() {
            let text = makeResultMessage()
            let alertModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз"){[weak self] in
                guard let self = self else { return }
                self.restartGame()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            let alertPresenter = AlertPresenter()
            guard let vc = viewController else { return }
            alertPresenter.show(vc: vc, model: alertModel)
        }else{
            questionFactory?.requestNextQuestion()
        }
    }
    func didAnswer(isCorrect: Bool){
        if isCorrect{
            correctAnswers += 1
        }
    }
    
    func makeResultMessage() -> String{
        statisticService.store(correct: correctAnswers, total: questionAmount)
        let text = """
Ваш результат: \(correctAnswers)/\(self.questionAmount)
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f",statisticService.totalAccuracy))%
"""
        return text
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.activityIndicator.isHidden = true //скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}

