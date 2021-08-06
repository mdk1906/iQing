//
//  QWReadingPlaceholderVC.swift
//  Qingwen
//
//  Created by Aimy on 11/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWReadingPlaceholderVC: QWBaseVC {

    @IBOutlet var backgroundView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.updateStyle()
    }

    func updateStyle() {
        switch QWReadingConfig.sharedInstance().readingBG {
        case .default:
            self.backgroundView.image = UIImage(named: "reading_bg_1")
            self.backgroundView.backgroundColor = nil
            break
        case .black:
            self.backgroundView.image = nil
            self.backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "reading_bg_2")!)
            break
        case .green:
            self.backgroundView.image = nil
            self.backgroundView.backgroundColor = UIColor(hex: 0xceefce)
            break
        case .pink:
            self.backgroundView.image = nil
            self.backgroundView.backgroundColor = UIColor(hex: 0xfcdfe7)
            break
        }
    }
}
