import UIKit

class AddTrackerViewController: UIViewController {
    
    private lazy var habitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self ,
            action: #selector(didTapHabitButton))
        button.setTitle("Привычка",
                        for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var irregularEvent: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self ,
            action: #selector(didTapIrregularEventButton))
        button.setTitle("Нерегулярное событие",
                        for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cоздание трекера"
        view.backgroundColor = .white
        addSubviews()
        setConstraint()
        irregularEvent.tintColor = .white
        habitButton.tintColor = .white
        habitButton.titleLabel?.font = .ysDisplayMedium(size: 16)
    }
    
    @objc func didTapHabitButton () {
        let navController = UINavigationController(rootViewController: HabitViewController())
        present(navController, animated: true)
    }
    
    @objc func didTapIrregularEventButton() {
        let navController = UINavigationController(rootViewController: IrregularEvent())
        present(navController, animated: true)
    }
    
    func addSubviews() {
        view.addSubview(habitButton)
        view.addSubview(irregularEvent)
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 330),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            irregularEvent.heightAnchor.constraint(equalToConstant: 60),
            irregularEvent.topAnchor.constraint(equalTo: view.topAnchor, constant: 406),
            irregularEvent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEvent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
