//
//  Quickly
//

import UIKit

open class QLabel: QView {
    
    public enum ContentAlignment: Int {
        case center
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        func point(size: CGSize, textSize: CGSize) -> CGPoint {
            let x: CGFloat = size.width - textSize.width
            let y: CGFloat = size.height - textSize.height
            switch self {
            case .center: return CGPoint(x: max(x / 2, 0), y: max(y / 2, 0))
            case .top: return CGPoint(x: max(x / 2, 0), y: 0)
            case .bottom: return CGPoint(x: max(x / 2, 0), y: max(y, 0))
            case .left: return CGPoint(x: 0, y: max(y / 2, 0))
            case .right: return CGPoint(x: max(x, 0), y: max(y / 2, 0))
            case .topLeft: return CGPoint(x: 0, y: 0)
            case .topRight: return CGPoint(x: max(x, 0), y: 0)
            case .bottomLeft: return CGPoint(x: 0, y: max(y, 0))
            case .bottomRight: return CGPoint(x: max(x, 0), y: max(y, 0))
            }
        }
    }

    public var contentAlignment: ContentAlignment = .left {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var padding: CGFloat {
        set {
            self.textContainer.lineFragmentPadding = newValue
            self.setNeedsDisplay()
        }
        get {
            return self.textContainer.lineFragmentPadding
        }
    }

    public var numberOfLines: Int {
        set(value) {
            self.textContainer.maximumNumberOfLines = value
            self.setNeedsDisplay()
        }
        get {
            return self.textContainer.maximumNumberOfLines
        }
    }

    public var lineBreakMode: NSLineBreakMode {
        set {
            self.textContainer.lineBreakMode = newValue
            self.setNeedsDisplay()
        }
        get {
            return self.textContainer.lineBreakMode
        }
    }
    
    public var text: IQText? {
        didSet { self.updateTextStorage() }
    }

    internal let textContainer: NSTextContainer = NSTextContainer()
    internal let layoutManager: NSLayoutManager = NSLayoutManager()
    internal let textStorage: NSTextStorage = NSTextStorage()

    public func characterIndex(point: CGPoint) -> String.Index? {
        let viewRect: CGRect = self.bounds
        let textSize: CGSize = self.layoutManager.usedRect(for: self.textContainer).integral.size
        let textOffset: CGPoint = self.contentAlignment.point(size: viewRect.size, textSize: textSize)
        let textRect: CGRect = CGRect(x: textOffset.x, y: textOffset.y, width: textSize.width, height: textSize.height)
        if textRect.contains(point) == true {
            let location: CGPoint = CGPoint(
                x: point.x - textOffset.x,
                y: point.y - textOffset.y
            )
            let index = self.layoutManager.characterIndex(
                for: location,
                in: self.textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )
            let string = self.textStorage.string
            return string.index(string.startIndex, offsetBy: index)
        }
        return nil
    }

    internal func updateTextStorage() {
        if let text: IQText = self.text {
            self.textStorage.setAttributedString(text.attributed)
        } else {
            self.textStorage.deleteAllCharacters()
        }
    }
    
    open override func setup() {
        super.setup()

        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false

        self.textContainer.lineBreakMode = .byTruncatingTail
        self.textContainer.lineFragmentPadding = 0
        self.textContainer.maximumNumberOfLines = 0

        self.layoutManager.addTextContainer(self.textContainer)

        self.textStorage.addLayoutManager(self.layoutManager)
    }

    open override var intrinsicContentSize: CGSize {
        get {
            return self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        self.textContainer.size = self.bounds.size
    }
    
    open override func draw(_ rect: CGRect) {
        let viewRect: CGRect = self.bounds
        let textSize: CGSize = self.layoutManager.usedRect(for: self.textContainer).integral.size
        let textOffset: CGPoint = self.contentAlignment.point(size: viewRect.size, textSize: textSize)
        let textRange: NSRange = self.layoutManager.glyphRange(for: self.textContainer)

        self.layoutManager.drawBackground(forGlyphRange: textRange, at: textOffset)
        self.layoutManager.drawGlyphs(forGlyphRange: textRange, at: textOffset)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textContainer: NSTextContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = self.textContainer.lineBreakMode
        textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding

        let layoutManager: NSLayoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage: NSTextStorage = NSTextStorage(attributedString: self.textStorage)
        textStorage.addLayoutManager(layoutManager)

        let frame: CGRect = layoutManager.usedRect(for: textContainer)

        return frame.integral.size
    }
    
    open override func sizeToFit() {
        super.sizeToFit()
        
        self.frame.size = self.sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }

}