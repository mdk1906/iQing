//
//  QWGameEndVC.swift
//  Qingwen
//
//  Created by Aimy on 5/19/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWGameEndVC: QWBaseVC {

    lazy var logic: QWGameDetailLogic = {
        return QWGameDetailLogic(operationManager: self.operationManager)
    }()

    var book_url: String!
    var bookId: String!

    @IBOutlet var layout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionBtn: UIButton!
    @IBOutlet var discussCountLabel: UILabel!
    @IBOutlet var heightConstraints: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        var width: CGFloat = 0
        if SWIFT_ISIPHONE9_7 {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                width = QWSize.screenWidth() / 9;
            }
            else {
                width = QWSize.screenWidth() / 7;
            }
        }
        else if (SWIFT_ISIPHONE4_7 || SWIFT_ISIPHONE5_5) {
            width = QWSize.screenWidth() / 5;
        }
        else {
            width = QWSize.screenWidth() / 4;
        }

        let height = width / 0.75 + 28;
        self.heightConstraints.constant = height + 20;
        self.layout.itemSize = CGSize(width: width, height: height)
        
        self.getData()
    }

    override func getData() {
        self.showLoading()
        if let book_url = self.book_url {
            self.logic.getDetailWithBookUrl(book_url) { (aResponseObject, anError) in
                self.hideLoading()
                self.getAttention()
                self.getDiscussCount()
                self.getLike()
            }
        }
        else if let bookId = self.bookId {
            self.logic.getDetailWithBookId(bookId) { (aResponseObject, anError) in
                self.hideLoading()
                self.getAttention()
                self.getDiscussCount()
                self.getLike()
            }
        }

    }

    func getAttention() {
        self.logic.getAttentionWithComplete { (aResponseObject, anError) in
            if let attention = self.logic.attention {
                self.collectionBtn.isSelected = attention.boolValue;
            }
        }
    }

    func getDiscussCount() {
        self.logic.getDiscussLastCount { (aResponseObject, anError) in
            if let discussLastCount = self.logic.discussLastCount , discussLastCount.intValue  < 99{
                self.discussCountLabel.text = discussLastCount.stringValue
                self.discussCountLabel.isHidden = discussLastCount.intValue <= 0
            }else {
                self.discussCountLabel.text = "99+"
            }
        }
    }

    func getLike() {
        self.logic.getLikeWithComplete { (aResponseObject, anError) in
            self.collectionView.reloadData()
        }
    }

    @IBAction func onPressedCollectionBtn(_ sender: AnyObject) {
        self.showLoading()
        self.logic.doAttention { (aResponseObject, anError) in
            self.hideLoading()

        }
    }

    @IBAction func onPressedChargeBtn(_ sender: AnyObject) {
        if let book = self.logic.bookVO {
            let tbc = self.tabBarController as! QWTBC
            tbc.doCharge(withBook: book, heavy: true)
        }
    }

    @IBAction func onPressedDiscussBtn(_ sender: AnyObject) {
        if let book = self.logic.bookVO {
            var params = [String: String]()
            params["url"] = book.bf_url
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "discuss", andParams: params))
        }
    }

    @IBAction func onPressedShareBtn(_ sender: AnyObject) {
        if let book = self.logic.bookVO {
            var params = [String: String]()
            params["title"] = book.title
            params["image"] = book.cover
            params["intro"] = book.intro
            params["url"] = book.url
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "share", andParams: params))
        }
    }
}

extension QWGameEndVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let listVO = self.logic.likeList {
            return listVO.results.count;
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWGameDetailRelatedCVCell
        if let book = self.logic.likeList?.results[(indexPath as NSIndexPath).row] as? BookVO {
            cell.update(with: book)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let book = self.logic.likeList?.results?[(indexPath as NSIndexPath).item] as? BookVO {
            var params = [String: String]()
            params["id"] = book.nid?.stringValue
            params["book_url"] = book.url
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
        }
    }
}

