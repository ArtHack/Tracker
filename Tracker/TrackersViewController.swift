import UIKit

class TrackersViewController: UIViewController {
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Tрекеры"
        label.textColor = .black
        label.font = .ysDisplayBold(size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "plus") ?? UIImage(),
            target: self,
            action: #selector(self.didTapAddTrackerButton))
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dateField: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.text = "Поиск"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setConstraint()
    }
    
    @objc func didTapAddTrackerButton() {
        let navController = UINavigationController(rootViewController: AddTrackerViewController())
        present(navController, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(trackerLabel)
        view.addSubview(addTrackerButton)
        view.addSubview(dateField)
        view.addSubview(searchTextField)
    }
    
    private func setConstraint () {
        NSLayoutConstraint.activate([
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            
            dateField.heightAnchor.constraint(equalToConstant: 34),
            dateField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 287.5),
            dateField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateField.bottomAnchor.constraint(equalTo: searchTextField.topAnchor, constant: -6),
            
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7)
        ])
    }
}

//MARK: - Extensioins

extension UIFont {
    static func ysDisplayBold(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Bold", size: size) ?? systemFont(ofSize: 34)
    }
    
    static func ysDisplayMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Medium", size: size) ?? systemFont(ofSize: 16)
    }
}
