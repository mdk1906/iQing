//
//  QWGameHistoryVC.swift
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWGameHistoryVC: QWBaseListVC {

    var bookCDs: PageVO?

    override var listVO: PageVO? {
        return self.bookCDs
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.game = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            let constant = self.view.safeAreaInsets.top;
            self.collectionView.contentInset = UIEdgeInsetsMake(constant, 0, 0, 0)
        }else{
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }

        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getData()
    }

    override func getData() {
        performInThreadBlock {[weak self] () -> Void in
            if let weakSelf = self {
                let books = BookCD.mr_findAllSorted(by: "lastReadTime", ascending: false, with: NSPredicate(format: "game == true && read == true"), in: QWFileManager.qwContext()) as! [BookCD]
                let page = PageVO()
                page.results = books
                page.count = NSNumber(value: books.count as Int)
                weakSelf.bookCDs = page

                QWHistoryCVC.performInMainThreadBlock({ [weak weakSelf] () -> Void in
                    if let weakSelf = weakSelf {
                        weakSelf.collectionView.emptyView.showError = true
                        weakSelf.collectionView.reloadData()
                    }
                })
            }
        }
    }

    override func update() {
        getData()
    }

    func clear() {
        var alertView = UIAlertView()
        alertView = alertView.bk_init(withTitle: "提示", message: "是否清空历史纪录") as! UIAlertView
        alertView.bk_addButton(withTitle: "取消") { () -> Void in

        }

        alertView.bk_addButton(withTitle: "清空") { [weak self] () -> Void in
            if let weakSelf = self {
                weakSelf.bookCDs?.results.forEach({ (element) -> () in
                    if let bookCD = element as? BookCD {
                        bookCD.read = false
                        bookCD.lastReadTime = nil
                    }
                })
                QWFileManager.qwContext().mr_saveToPersistentStore(completion: nil)
                weakSelf.getData()
            }
        }
        alertView.show()
    }
}

extension QWGameHistoryVC {

    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let book = self.listVO?.results[(indexPath as NSIndexPath).item] as? BookCD {
            let cell = cell as! QWListCVCell
            cell.updateWithGameCD(book)
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let index = self.type == 0 ? (indexPath as NSIndexPath).item : (indexPath as NSIndexPath).row
        if let vo = self.listVO?.results[index] as? BookCD {
            var params = [String: AnyObject]()
            params["book_url"] = vo.url as AnyObject?
            params["id"] = vo.nid?.stringValue as AnyObject?
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
        }
    }
}

