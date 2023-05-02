import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        generateTabBar()
    }
    
    private func generateTabBar() {
        viewControllers = [
        generateVC(viewController: TrackerViewController(), title: "Tрекеры", image: UIImage(named: "record.circle.fill")),
        generateVC(viewController: StatisticViewController(), title: "Статистика", image: UIImage(named: "hare.fill"))]
        
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
}
