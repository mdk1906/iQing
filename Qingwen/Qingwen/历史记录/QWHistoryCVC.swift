//
//  QWHistoryCVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWHistoryCVC: QWBaseListVC {

    var bookCDs: PageVO?

    override var listVO: PageVO? {
        return self.bookCDs
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);

        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getData()
    }

    override func getData() {
        performInThreadBlock {[weak self] () -> Void in
            if let weakSelf = self {
                let books = BookCD.mr_find(byAttribute: "read", withValue: NSNumber(value: true as Bool), andOrderBy: "lastReadTime", ascending: false, in: QWFileManager.qwContext()) as! [BookCD]
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

extension QWHistoryCVC {

    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let book = self.listVO?.results[(indexPath as NSIndexPath).item] as? BookCD {
            let cell = cell as! QWListCVCell
            cell.updateWithBookCD(book)
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let index = self.type == 0 ? (indexPath as NSIndexPath).item : (indexPath as NSIndexPath).row
        if let vo = self.listVO?.results[index] as? BookCD {
            var params = [String: String]()
            params["book_url"] = vo.url
            params["id"] = vo.nid?.stringValue
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
        }
    }
}




