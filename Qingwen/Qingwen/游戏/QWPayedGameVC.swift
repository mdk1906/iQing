//
//  QWPayedGameVC.swift
//  Qingwen
//
//  Created by Aimy on 5/16/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


extension QWPayedGameVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWGame"
        vo.storyboardID = "payed"
        QWRouter.sharedInstance().register(vo, withKey: "payed")
    }
}

class QWPayedGameVC: QWListVC {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.game = true
        self.type = 1
        self.book_url = "\(QWOperationParam.currentDomain())/statistic/book/gold_book_rank/"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = nil

        self.getData()
    }
}

extension QWPayedGameVC
{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 110
    }

//    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
//        if let vos = self.listVO?.results {
//            return vos.count
//        }
//
//        return 0
//    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let vos = self.listVO?.results {
            return vos.count
        }
        
        return 0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! QWBaseTVCell

        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }

        updateWithTVCell(cell, indexPath: indexPath)

        if listVO?.results.count == (indexPath as NSIndexPath).section + 1 && listVO?.results.count < listVO?.count?.intValue {
            getMoreData()
        }

        return cell
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).section] as? BookVO {
            let cell = cell as! QWListTVCell
            cell.updateWithBookVO(vo)
            cell.updateWithIndexPath(indexPath)
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let vo = self.logic.listVO?.results[(indexPath as NSIndexPath).section] as? BookVO {
            var params = [String: String]()
            params["book_url"] = vo.url
            params["id"] = vo.nid?.stringValue
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
        }
    }
}
