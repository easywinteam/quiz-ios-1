import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private let questionAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      questionFactory = QuestionFactory(delegate: self)
      showNextQuestionsOrResults()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.show(quiz: viewModel)
        }
        
    }
    
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        currentQuestionIndex += 1
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = false
        currentQuestionIndex += 1
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // MARK: - Functions
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
//    private func show(quiz result: QuizResultsViewModel) {
//        let alert = UIAlertController(title: result.title,
//                                      message: result.text,
//                                      preferredStyle: .alert)
//
//        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { [weak self] _ in
//            guard let self = self else { return }
//            self.currentQuestionIndex = 0
//            self.correctAnswers = 0
//            self.questionFactory?.requestNextQuestion()
//        })
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect{
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        }else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){[weak self] in
            guard let self = self else{ return }
            self.showNextQuestionsOrResults()
        }
    }
    
    private func showNextQuestionsOrResults(){
        imageView.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questionAmount {
            //let text = "Ваш результат: \(correctAnswers)/\(questionAmount)"
            statisticService = StatisticServiceImplementation()
            statisticService?.store(correct: correctAnswers, total: questionAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionAmount)\nКоличество сыгранных квизов \(statisticService!.gamesCount)\nРекорд: \(statisticService!.bestGame.correct)/\(statisticService!.bestGame.total) (\(statisticService!.bestGame.date.dateTimeString))\nСредняя точность: \(statisticService!.totalAccuracy)%"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен", text: text, buttonText: "Сыграть еще раз")
            func completion(){
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            let alertModel = AlertModel(title: "Этот раунд окончен", message: text, buttonText: "Сыграть еще раз", completion: completion())
            let alertPresenter = AlertPresenter(vc: self, model: alertModel)
            alertPresenter.show()
        }else{
            questionFactory?.requestNextQuestion()
        }
    }
}



