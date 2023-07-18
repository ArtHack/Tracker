import UIKit
import SnapKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func addNewSchedule( _ newSchedule: [Weekdays])
}

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ScheduleViewControllerDelegate?
    private var switchedDays: [Weekdays] = []
    
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Расписание"
        label.font = .ysDisplayMedium(size: 16)
        label.textColor = .ypBlackDay
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = .ysDisplayMedium(size: 16)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTaped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        
    }
     
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        view.addSubview(readyButton)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(73)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.trailing.equalTo(view.snp.trailing).offset(-16)
            $0.height.equalTo(524)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top).offset(20)
        }
        
        readyButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom).offset(-50)
            $0.width.equalTo(335)
            $0.height.equalTo(60)
        
        }
    }
    
    private func readyButtonIsEnable() {
        if switchedDays.count > 0 {
            readyButton.isEnabled = true
            readyButton.backgroundColor = .ypBlackDay
        } else {
            readyButton.isEnabled = false
        }
    }
    
    @objc func daySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            switchedDays.append(Weekdays.allCases[sender.tag])
        } else {
            if let index = switchedDays.firstIndex(of: Weekdays.allCases[sender.tag]) {
                switchedDays.remove(at: index)
            }
        }
        readyButtonIsEnable()
    }
    
    @objc func readyButtonTaped() {
        dismiss(animated: true) {
            self.delegate?.addNewSchedule(self.switchedDays)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return Weekdays.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.text = Weekdays.allCases[indexPath.row].rawValue
        cell.backgroundColor = .ypBackgroundNight
        
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.tag = indexPath.row
        cell.accessoryView = daySwitch
        
        daySwitch.addTarget(self, action: #selector(daySwitchChanged), for: .valueChanged)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}

