import UIKit

protocol NewCreatedTrackerTypeDelegate: AnyObject {
    func addNewTrackerCategory(_ category: TrackerCategory)
}

class NewCreatedTrackerTypeViewController: UIViewController {
    
    weak var delegate: NewCreatedTrackerTypeDelegate?
    private let categories: [TrackerCategory]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Cоздание трекера"
        label.font = .ysDisplayMedium(size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    init(categories: [TrackerCategory]) {
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                

        addSubviews()
        setConstraint()
        irregularEvent.tintColor = .white
        habitButton.tintColor = .white
        self.navigationItem.title = "Добавить трекер"
        view.backgroundColor = .white
    }

    func updateDelegate() {
        
    }
    
    @objc func didTapHabitButton () {
        let newCreatedTrackerVC = NewCreatedTrackerViewController()
        newCreatedTrackerVC.newCreatedTrackerType = .habitTracker
        newCreatedTrackerVC.delegate = self
        present(newCreatedTrackerVC, animated: true)
    }
    
    @objc func didTapIrregularEventButton() {
        let newCreatedTrackerVC = NewCreatedTrackerViewController()
        newCreatedTrackerVC.newCreatedTrackerType = .irregularEvent
        newCreatedTrackerVC.delegate = self
        present(newCreatedTrackerVC, animated: true)
    }
    
    func addSubviews() {
        view.addSubview(habitButton)
        view.addSubview(irregularEvent)
        view.addSubview(titleLabel)
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
            irregularEvent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
        ])
    }
}

extension NewCreatedTrackerTypeViewController: AddNewTrackerCategoryDelegate {
    func addNewTrackerCategory(_ category: TrackerCategory) {
        delegate?.addNewTrackerCategory(category)
        dismiss(animated: true)
    }
}
