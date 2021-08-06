//
//  QWBookNameIntroView.swift
//  Qingwen
//
//  Created by Aimy on 12/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBookNameIntroView: QWIntroView {

    override class func introKey() -> String {
        return "SHOW_BOOK_NAME_INTRO"
    }

    @IBAction override func onTap(_ sender: AnyObject) {
        let s = type(of: self).introKey()
        QWUserDefaults.setValue(1, forKey: s)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
        }, completion: { (_) -> Void in
            self.removeFromSuperview()
        })
    }
    
}
