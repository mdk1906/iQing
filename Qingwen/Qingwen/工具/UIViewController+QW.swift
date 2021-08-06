//
//  UIViewController+QW.swift
//  Qingwen
//
//  Created by Aimy on 10/8/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

//router
let extraDataString = "extraData"
extension UIViewController {
    /// 创建的时候的参数,如果不为nil，则标识是从router创建的,其中会传递QWRouterCallbackKey的block用来回调
    var extraData: [String: AnyObject]? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(extraDataString, value: newValue, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            else {
                objc_setAssociatedObject(extraDataString, value: nil, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(extraDataString) as? [String: AnyObject]
        }
    }
}

extension UIViewController {
    func update() {

    }

    func getData() {

    }

    func getMoreData() {

    }

    func cancelAllOperations() {
        self.operationManager.cancelAllOperations();
    }

    func repeateClickTabBarItem(_ count: Int) {

    }

    @IBAction func leftBtnClicked(_ sender: AnyObject?) {
        self.cancelAllOperations()
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func rightBtnClicked(_ sender: AnyObject?) {

    }

    func onTap(_ sender: AnyObject?) {
        endTextEditing()
    }

    func resize(_ size: CGSize) {

    }

    func didResize(_ size: CGSize) {

    }
}

//navigation animations
extension UIViewController {
    func pushAnimations() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func popAnimations() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func pushInteractions() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func popInteractions() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension UINavigationController{
    private struct NavAlphaViewKey {
        static var alphaKey = "alphaKey"
    }
    
    var QWAlphaView: UIView? {
        set {
            objc_setAssociatedObject(NavAlphaViewKey.alphaKey, value: newValue, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(NavAlphaViewKey.alphaKey) as? UIView
        }
    }
    
    func setAlphaViewBackgroundColor(color: UIColor, alpha: CGFloat) {
        
        if self.QWAlphaView == nil {
            guard self.QWAlphaView == UIView(frame: CGRect(x: 0.0, y: -20.0, width: UIScreen.main.bounds.width, height: self.navigationBar.frame.size.height)) else{
                return
            }
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.insertSubview(self.QWAlphaView!, at: 0)
        }
        self.QWAlphaView?.backgroundColor = color.withAlphaComponent(alpha)
    }
   
}








