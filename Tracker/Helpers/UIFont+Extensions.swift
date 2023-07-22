import UIKit

extension UIFont {
    static func ysDisplayBold(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Bold", size: size) ?? systemFont(ofSize: 34)
    }
    
    static func ysDisplayMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Medium", size: size) ?? systemFont(ofSize: 16)
    }
}
