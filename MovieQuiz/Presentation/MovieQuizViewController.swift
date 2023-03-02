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
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
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
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true //скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() , question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
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
            statisticService = StatisticServiceImplementation()
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionAmount)
            let text = """
Ваш результат: \(correctAnswers)/\(questionAmount)
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f",statisticService.totalAccuracy))%
"""

            let alertModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз"){[weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            let alertPresenter = AlertPresenter()
            alertPresenter.show(vc: self, model: alertModel)
        }else{
            questionFactory?.requestNextQuestion()
        }
    }
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false //говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() //включаем анимацию
    }
    private func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String){
        hideLoadingIndicator()//скрываем индикатор загрузки
        //создайте и покажите алерт
        let alertModel = AlertModel(title: "Ошибка", message: "Не удалось загрузить данные", buttonText: "Попробовать еще раз"){[weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.show(vc: self, model: alertModel)
    }
}



