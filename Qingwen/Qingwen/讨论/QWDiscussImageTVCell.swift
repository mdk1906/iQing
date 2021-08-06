//
//  QWDiscussImageTVCell.swift
//  Qingwen
//
//  Created by Aimy on 2/24/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWDiscussImageTVCellDelegate: NSObjectProtocol {
    func onPressedBackgroundViewInImageCell(_ imageCell: QWDiscussImageTVCell)
}

class QWDiscussImageTVCell: QWBaseTVCell {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!

    weak var delegate: QWDiscussImageTVCellDelegate?

    var itemVO: DiscussItemVO?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "QWDiscussImageCVCell", bundle: nil), forCellWithReuseIdentifier: "image")

        let ges = UITapGestureRecognizer(target: self, action: #selector(QWDiscussImageTVCell.onTapGes(_:)))
        self.collectionView.addGestureRecognizer(ges)
    }

    func updateWithDiscussItemVO(_ vo: DiscussItemVO) {
        itemVO = vo
        if let illustration = itemVO?.illustration {
            if illustration.count == 1 {
                self.layout.scrollDirection = .horizontal
            }
            else if illustration.count > 1 {
                self.layout.scrollDirection = .vertical
            }
            else {
                self.layout.scrollDirection = .vertical
            }
        }
        collectionView.reloadData()
    }

    static func height1(forCellData data: AnyObject) -> CGFloat {
        if let itemVO = data as? DiscussItemVO, let illustration = itemVO.illustration {
            if illustration.count > 0 {
                let times = CGFloat((illustration.count - 1) / 3 + 1)
                let height = floor((QWSize.screenWidth(false) - 20 - 15) / 3)
                return CGFloat(height * times + 2 * (times - 1)) + 10
            }
            else {
                return 1
            }
        }

        return 1
    }

    @IBAction func onTapGes(_ ges: UITapGestureRecognizer) {
        let point = ges.location(in: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: point) {
            if let items = itemVO?.illustration {
                var params = [String: AnyObject]()
                params["pictures"] = items as AnyObject?
                params["index"] = (indexPath as NSIndexPath).item as AnyObject?
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "picture", andParams: params))
            }
        }
        else {
            self.delegate?.onPressedBackgroundViewInImageCell(self)
        }
    }
}

extension QWDiscussImageTVCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let illustration = itemVO?.illustration {
            if illustration.count > 0 {
                let width = floor((QWSize.screenWidth(false) - 30 - 4) / 3)
                return CGSize(width: width, height: width)
            }
            else {
                return CGSize.zero
            }
        }

        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = itemVO?.illustration {
            return items.count
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! QWDiscussImageCVCell
        if let illustration = itemVO?.illustration {
            cell.updateWithImageUrl(illustration[(indexPath as NSIndexPath).row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let items = itemVO?.illustration {
            var params = [String: AnyObject]()
            params["pictures"] = items as AnyObject?
            params["index"] = (indexPath as NSIndexPath).item as AnyObject?
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "picture", andParams: params))
        }
    }
}
