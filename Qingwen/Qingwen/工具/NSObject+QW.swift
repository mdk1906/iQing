//
//  QW.swift
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

let not_login_error = NSError(domain: "not login", code: 403, userInfo: nil)

let operationManagerString = "operationManager"

typealias QWActionBlock = (_ btn: UIButton) ->()

extension NSObject {
    var operationManager: QWOperationManager {
        get {
            if let manager = objc_getAssociatedObject(operationManagerString) as? QWOperationManager {
                return manager
            }
            let manager = QWNetworkManager.sharedInstance().generateoperationManager(withOwner: self)
            objc_setAssociatedObject(operationManagerString, value: manager, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return manager
        }
    }

    func endTextEditing() {
        if let delegate = UIApplication.shared.delegate, let window = delegate.window {
            window?.endEditing(true)
        }
    }
}

extension Dictionary where Value: AnyObject {

    func objectForCaseInsensitiveKey(_ aKey: String?) -> AnyObject? {
        guard let aKey = aKey else {
            return nil
        }

        for (key, value) in self {
            if (key as! NSString).compare(aKey, options: .caseInsensitive) == .orderedSame {
                return value
            }
        }

        return nil

    }
}

//perform block
extension NSObject {
    static func performInMainThreadBlock(_ aBlock: @escaping () -> Void) {
        performInMainThreadBlock(aBlock, afterSecond: 0)
    }

    static func performInMainThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval) {
        performInThreadBlock(aBlock, afterSecond: afterSecond, main: true)
    }

    static func performInThreadBlock(_ aBlock: @escaping () -> Void) {
        performInThreadBlock(aBlock, afterSecond: 0)
    }

    static func performInThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval) {
        performInThreadBlock(aBlock, afterSecond: afterSecond, main: false)
    }

    static fileprivate func performInThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval, main:Bool) {
        let queue = main ? DispatchQueue.main : DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let popTime = DispatchTime.now() + Double(Int64(afterSecond * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        queue.asyncAfter(deadline: popTime) { () -> Void in
            aBlock()
        }
    }

    func performInMainThreadBlock(_ aBlock: @escaping () -> Void) {
        performInMainThreadBlock(aBlock, afterSecond: 0)
    }

    func performInMainThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval) {
        performInThreadBlock(aBlock, afterSecond: afterSecond, main: true)
    }

    func performInThreadBlock(_ aBlock: @escaping () -> Void) {
        performInThreadBlock(aBlock, afterSecond: 0)
    }

    func performInThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval) {
        performInThreadBlock(aBlock, afterSecond: afterSecond, main: false)
    }

    fileprivate func performInThreadBlock(_ aBlock: @escaping () -> Void, afterSecond: TimeInterval, main:Bool) {
        NSObject.performInThreadBlock(aBlock, afterSecond: afterSecond, main: main)
    }
}

extension UIImage {
    func imageWithCornerRadius(_ radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?) -> UIImage {
        //// General Declarations
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        //// Picture Drawing
        let picturePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), cornerRadius: radius)

        context!.saveGState()
        picturePath.addClip()
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        context!.restoreGState()
        if let borderColor = borderColor {
            borderColor.setStroke()
        }

        if borderWidth > 0 {
            picturePath.lineWidth = borderWidth
        }

        picturePath.stroke()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!;
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }

    @IBInspectable var masksToBounds: Bool {
        get {
            return self.layer.masksToBounds
        }
        set {
            self.layer.masksToBounds = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let borderColor = self.layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            else {
                return nil
            }
        }
        set {
            if let borderColor = newValue {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
}

extension String {
    var length: Int {
        return self.characters.count
    }
    
    func pargraphAttribute() -> NSAttributedString {
        let attributedString  = NSMutableAttributedString(string: self)
        let paraghStyle = NSMutableParagraphStyle()
        paraghStyle.lineHeightMultiple = 1
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paraghStyle, range: NSMakeRange(0, self.length))
        return attributedString
    }
    
    func omitString(to: Int) -> String {
        guard self.length > to, self.length > 5 else {
            return self
        }
        let range = self.index(self.startIndex, offsetBy: to - 3) ..< self.endIndex
        return self.replacingCharacters(in: range, with: "...")
    }
}

public extension Int {
    public static func random(lower: Int = 0, _ upper: Int = Int.max) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    public static func random(range: Range<Int>) -> Int {
        return random(lower: range.lowerBound, range.upperBound)
    }
}

extension RangeReplaceableCollection where Iterator.Element : Equatable {

    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

func randomInRange(_ range: Range<Int>) -> Int {
    let count = UInt32(range.upperBound - range.lowerBound)
    return  Int(arc4random_uniform(count)) + range.lowerBound
}


