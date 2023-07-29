import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        generateTabBar()
    }

    private func generateTabBar() {
        viewControllers = [
        generateVC(
            viewController: TrackersViewController(),
            title: "Tрекеры",
            image: UIImage(systemName: "record.circle.fill")),
        generateVC(
            viewController: StatisticViewController(),
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"))
        ]
    }

    private func generateVC(
        viewController: UIViewController, title: String,  image: UIImage?
    ) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return UINavigationController(rootViewController: viewController)
    }
}

