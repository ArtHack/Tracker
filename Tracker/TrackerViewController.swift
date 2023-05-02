import UIKit

class TrackerViewController: UIViewController {
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Tрекеры"
        label.textColor = .black
        label.font = .ysDisplayBold(size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubviews()
        activate()
    }
    
    private func addSubviews() {
        view.addSubview(trackerLabel)
    }
    
    private func activate () {
        NSLayoutConstraint.activate([
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
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
