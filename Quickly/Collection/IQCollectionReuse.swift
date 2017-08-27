//
//  Quickly
//

import UIKit

public protocol IQCollectionReuse: class {

    static func reuseIdentifier() -> String
    static func currentNib() -> UINib?
    static func currentNibName() -> String
    static func currentNibBundle() -> Bundle

    static func size(any: Any, size: CGSize) -> CGSize

    static func using(any: Any) -> Bool

}

extension IQCollectionReuse {

    public static func reuseIdentifier() -> String {
        return String(describing: self)
    }

    public static func currentNib() -> UINib? {
        let nibName: String = self.currentNibName()
        let bundle: Bundle = self.currentNibBundle()
        if bundle.url(forResource: nibName, withExtension: "nib") == nil {
            return nil
        }
        return UINib(nibName: nibName, bundle: bundle)
    }

    public static func currentNibName() -> String {
        return String(describing: self)
    }

    public static func currentNibBundle() -> Bundle {
        return Bundle.main
    }

}