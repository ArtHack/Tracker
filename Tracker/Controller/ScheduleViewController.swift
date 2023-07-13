import UIKit
import SnapKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func addNewSchedule( _ newSchedule: [Weekdays])
}

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let daysOfTheWeek = Weekdays.allCases.map { $0.rawValue }
    private var habitActiveDays: [Weekdays] = []
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
    
    private func radyButtonIsEnable() {
        if habitActiveDays.count > 0 {
            readyButton.isEnabled = true
            readyButton.backgroundColor = .ypBlackDay
        } else {
            readyButton.isEnabled = false
            readyButton.backgroundColor = .ypGray
        }
    }
    
    @objc func daySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            habitActiveDays.append(Weekdays.allCases[sender.tag])
        } else {
            if let index = habitActiveDays.firstIndex(of: Weekdays.allCases[sender.tag]) {
                habitActiveDays.remove(at: index)
            }
        }
        radyButtonIsEnable()
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
        return daysOfTheWeek.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = daysOfTheWeek[indexPath.row]
        cell.backgroundColor = .ypBackgroundNight
        
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
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

