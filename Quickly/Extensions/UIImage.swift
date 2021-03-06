//
//  Quickly
//

#if os(iOS)

    public extension UIImage {

        public func tintImage(_ color: UIColor) -> UIImage? {
            return modify { (context: CGContext, rect: CGRect) in
                if let cgImage: CGImage = self.cgImage {
                    context.setBlendMode(.normal)
                    context.setFillColor(color.cgColor)
                    context.fill(rect)
                    context.setBlendMode(.destinationIn)
                    context.draw(cgImage, in: rect)
                }
            }
        }


        public func modify(_ draw: (CGContext, CGRect) -> ()) -> UIImage? {
            var image: UIImage? = nil
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            if let context: CGContext = UIGraphicsGetCurrentContext() {
                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                draw(context, CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            return image
        }

    }

#endif
