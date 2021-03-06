//
//  Quickly
//

open class QLengthStringValidator: IQStringValidator {

    public var minimumLength: Int = 0
    public var maximumLength: Int?
    
    public init() {
    }

    public func validate(_ string: String, complete: Bool) -> Bool {
        var valid: Bool = true
        if complete == true {
            valid = (string.count >= self.minimumLength)
        }
        if valid == true {
            if let maximumLength: Int = self.maximumLength {
                valid = (string.count <= maximumLength)
            }
        }
        return valid
    }

}
