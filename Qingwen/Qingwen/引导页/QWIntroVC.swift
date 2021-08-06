//
//  QWIntroVC.swift
//  Qingwen
//
//  Created by Aimy on 11/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWIntroVC: QWBaseVC {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    var images = [UIImage(named: "intro_1"), UIImage(named: "intro_2"), UIImage(named: "intro_3"), UIImage(named: "intro_4")]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(hex: 0xf6cbd5)
        self.collectionView.backgroundColor = UIColor(hex: 0xf6cbd5)

        // Do any additional setup after loading the view.
        if SWIFT_ISIPHONE3_5 {
            self.layout.itemSize = CGSize(width: 320, height: 480)
        }
        else if SWIFT_ISIPHONE4_0 {
            self.layout.itemSize = CGSize(width: 320, height: 568)
        }
        else if SWIFT_ISIPHONE4_7 {
            self.layout.itemSize = CGSize(width: 375, height: 667)
        }
        else if SWIFT_ISIPHONE5_5 {
            self.layout.itemSize = CGSize(width: 414, height: 736)
        }
        else if SWIFT_ISIPHONE9_7 {
            self.layout.itemSize = CGSize(width: 768, height: 1024)
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }

    @IBAction func onPressedExitBtn(_ sender: AnyObject, event: UIEvent) {
        if let touch = event.allTouches?.first {
            let point = touch.location(in: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: point) , (indexPath as NSIndexPath).item + 1 == self.images.count {
                QWUserDefaults.sharedInstance()["showIntro1.10.0"] = 1
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension QWIntroVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWIntroCVCell
        cell.imageView.image = self.images[(indexPath as NSIndexPath).item]
        return cell
    }
}
