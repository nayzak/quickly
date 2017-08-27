//
//  Quickly
//

import Foundation

public extension String {

    public static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    public static func localized(_ key: String, bundle: Bundle) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    public static func localized(_ key: String, args: [String: String]) -> String {
        let result: String = self.localized(key)
        return self.replace(result, keys: args)
    }

    public static func localized(_ key: String, bundle: Bundle, args: [String: String]) -> String {
        let result: String = self.localized(key, bundle: bundle)
        return self.replace(result, keys: args)
    }

    public static func replace(_ string: String, keys: [String: String]) -> String {
        var result: String = string
        keys.forEach { (key: String, value: String) in
            if let range: Range< String.Index > = result.range(of: key) {
                result.replaceSubrange(range, with: value)
            }
        }
        return result
    }

}

public extension String {

    public func components(pairSeparatedBy: String, valueSeparatedBy: String) -> [String: Any] {
        var components: [String: Any] = [:]
        for keyValuePair: String in self.components(separatedBy: pairSeparatedBy) {
            let pair: [String] = keyValuePair.components(separatedBy: valueSeparatedBy)
            if pair.count > 1 {
                guard
                    let key: String = pair.first!.removingPercentEncoding,
                    let value: String = pair.last!.removingPercentEncoding else {
                    continue
                }
                let existValue: Any? = components[key]
                if let existValue: Any = existValue {
                    if var existValueArray: [String] = existValue as? [String] {
                        existValueArray.append(value)
                        components[key] = existValueArray
                    } else if let existValueString: String = existValue as? String {
                        components[key] = [existValueString, value]
                    }
                } else {
                    components[key] = value
                }
            }
        }
        return components
    }
    
}

public extension String {

    public func range(from nsRange: NSRange) -> Range< String.Index >? {
        guard
            let from16: String.UTF16View.Index = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16: String.UTF16View.Index = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from: String.Index = from16.samePosition(in: self),
            let to: String.Index = to16.samePosition(in: self)
            else {
                return nil
        }
        return from ..< to
    }

    public func nsRange(from range: Range< String.Index >) -> NSRange {
        let from: String.UTF16View.Index = range.lowerBound.samePosition(in: utf16)
        let to: String.UTF16View.Index = range.upperBound.samePosition(in: utf16)
        return NSRange(
            location: utf16.distance(from: utf16.startIndex, to: from),
            length: utf16.distance(from: from, to: to)
        )
    }

}