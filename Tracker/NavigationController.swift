import UIKit

class NavigationController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        generateTabBar()
    }
    
    private func generateTabBar() {
        viewControllers = [
        generateVC(viewController: TrackersViewController(), title: "Tрекеры", image: UIImage(named: "record.circle.fill")),
        generateVC(viewController: StatisticViewController(), title: "Статистика", image: UIImage(named: "hare.fill"))
        ]
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
}
