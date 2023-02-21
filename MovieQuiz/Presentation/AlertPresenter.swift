import UIKit

class AlertPresenter{
    let vc: UIViewController
    let model: AlertModel
    
    init(vc: UIViewController, model: AlertModel) {
        self.vc = vc
        self.model = model
    }
    
    func show() {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.model.completion
        })
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}
