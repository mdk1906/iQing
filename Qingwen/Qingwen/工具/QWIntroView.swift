//
//  QWIntroView.swift
//  Qingwen
//
//  Created by Aimy on 11/18/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWIntroView: UIView {

    class func introKey() -> String {
        return ""
    }

    class func showOnView(_ view: UIView?) {
        guard let view = view else {
            return
        }

        if let _ = QWUserDefaults.getValueForKey(self.introKey()) {
            return
        }

        for subView in view.subviews {
            if subView is QWIntroView {
                return
            }
        }

        let introView = self.createWithNib()!
        view.addSubview(introView)
        introView.autoCenterInSuperview()
        introView.autoMatch(.height, to: .height, of: view)
        introView.autoMatch(.width, to: .width, of: view)
    }

    @IBAction func onTap(_ sender: AnyObject) {
        let s = type(of: self).introKey()
        QWUserDefaults.setValue(1, forKey: s)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (_) -> Void in
                self.removeFromSuperview()
        }) 
    }
}

