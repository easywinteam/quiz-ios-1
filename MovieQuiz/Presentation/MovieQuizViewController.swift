import UIKit

final class MovieQuizViewController: UIViewController {
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
    
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    // MARK: - Functions
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        presenter.didAnswer(isCorrect: true)
        if isCorrectAnswer{
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        }else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func clearColor(){
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func showLoadingIndicator(){
        activityIndicator.isHidden = false //говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() //включаем анимацию
    }
    func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    func showNetworkError(message: String){
        hideLoadingIndicator()//скрываем индикатор загрузки
        //создайте и покажите алерт
        let alertModel = AlertModel(title: "Ошибка", message: "Не удалось загрузить данные", buttonText: "Попробовать еще раз"){[weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.show(vc: self, model: alertModel)
    }
}



