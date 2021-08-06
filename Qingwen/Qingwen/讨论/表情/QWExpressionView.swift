//
//  QWExpressionView.swift
//  Qingwen
//
//  Created by Aimy on 12/31/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWExpressionViewDelegate: NSObjectProtocol {

    func expressionView(_ view: QWExpressionView, didSelectedExpression expression: String)

}

class QWExpressionView: UIView {

    weak var delegate: QWExpressionViewDelegate?

    @IBOutlet var layout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xcccccc)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0x848484)
        collectionView.backgroundColor = UIColor(hex: 0xf5f5f5)
        collectionView.register(UINib(nibName: "QWExpressionCVCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        pageControl.numberOfPages = QWExpressionManager.sharedManager.expressions.count / 18 + 1
    }
}

extension QWExpressionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = self.collectionView.indexPathsForVisibleItems.last {
            self.pageControl.currentPage = (indexPath as NSIndexPath).section
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = QWSize.screenWidth()
        width /= 6;
        return CGSize(width: width, height: 60)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return QWExpressionManager.sharedManager.expressions.count / 18 + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWExpressionCVCell

        let index = (indexPath as NSIndexPath).item % 3 * 6 + (indexPath as NSIndexPath).item / 3 + (indexPath as NSIndexPath).section * 18
        if QWExpressionManager.sharedManager.expressions.count > index {
            cell.imageView.image = UIImage(named: QWExpressionManager.sharedManager.expressions[index])
        }
        else {
            cell.imageView.image = nil
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).item % 3 * 6 + (indexPath as NSIndexPath).item / 3 + (indexPath as NSIndexPath).section * 18
        if QWExpressionManager.sharedManager.expressions.count > index {
            let string = QWExpressionManager.sharedManager.expressions[index]
            self.delegate?.expressionView(self, didSelectedExpression: string)
        }
    }
}
