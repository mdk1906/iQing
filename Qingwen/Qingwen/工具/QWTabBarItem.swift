//
//  QWTabBarItem.swift
//  Qingwen
//
//  Created by Aimy on 6/28/15.
//  Copyright (c) 2015 Qingwen. All rights reserved.
//

import UIKit

class QWTabBarItem: UITabBarItem {

    @IBInspectable var originalImage: UIImage? = nil {
        didSet {
            self.image = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
    }
    @IBInspectable var originalSelectedImage: UIImage? = nil {
        didSet {
            self.selectedImage = originalSelectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
    }

    override var badgeValue: String? {
        didSet {
            if badgeValue != nil {
                showIndicator(false)
            }
        }
    }
}

extension UIButton{
    func showIndicator(_ show: Bool) {
        if show {
            if let bgImage = self.currentImage{
                let newBg = bgImage.addIndicator()
                self.setImage(newBg, for: .normal)
            }
        }
    }
}

extension UITabBarItem {
    func showIndicator(_ show: Bool) {
        if let item = self as? QWTabBarItem {
            if show {
                self.image = item.originalImage?.addIndicator()
                self.selectedImage = item.originalSelectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal).addIndicator()
            }
            else {
                self.image = item.originalImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                self.selectedImage = item.originalSelectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
        }
        else {
            print("不支持")
        }
    }
}

extension UIImage {
    func addIndicator() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 30), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.textMatrix = CGAffineTransform.identity;
        context!.translateBy(x: 0, y: 30);
        context!.scaleBy(x: 1, y: -1);
        context!.draw(self.cgImage!, in: CGRect(x: (30 - self.size.width) / 2, y: (30 - self.size.height) / 2, width: self.size.width, height: self.size.height))
        context!.setFillColor((UIColor(hex: 0xf82f47)?.cgColor)!)
        let center = CGPoint(x: CGFloat(30 - 4), y: CGFloat(30 - 4))
        context!.addArc(center: center, radius: CGFloat(4), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
        context!.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return image!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
}

