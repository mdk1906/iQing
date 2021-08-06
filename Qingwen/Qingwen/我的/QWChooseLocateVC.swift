//
//  QWChooseLocateVC.swift
//  Qingwen
//
//  Created by Aimy on 3/7/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWChooseLocateVC: QWBaseVC {

    @IBOutlet var locate10Btn: UIButton!
    @IBOutlet var locate11Btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "个性设置"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "locate_bg")!)
        // Do any additional setup after loading the view.
        if let channel = QWUserDefaults.sharedInstance()["channel"] as? NSNumber {
            if channel.uintValue == QWChannelType.type11.rawValue {
                self.locate10Btn.layer.borderWidth = 0
                self.locate11Btn.layer.borderWidth = 1
            }
            else {
                self.locate10Btn.layer.borderWidth = 1
                self.locate11Btn.layer.borderWidth = 0
            }
        }
        else {
            self.locate10Btn.layer.borderWidth = 0
            self.locate11Btn.layer.borderWidth = 0
        }
    }

    override var prefersStatusBarHidden : Bool {
        if let _ = self.navigationController {
            return false
        }

        return true
    }

    @IBAction func onPressedBoyBtn(_ sender: UIButton) {
        QWUserDefaults.sharedInstance()["showChannel2.0.0"] = 1
        QWUserDefaults.sharedInstance()["channel"] = QWChannelType(rawValue: UInt(sender.tag))!.rawValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: LOCATE_CHANGED), object: nil)
        guard let _ = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }
}
