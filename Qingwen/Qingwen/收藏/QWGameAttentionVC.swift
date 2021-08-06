//
//  QWGameAttentionVC.swift
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWGameAttentionVC: QWListVC {

    var loginView: QWMessageLoginView?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.game = true
        self.book_url = QWGlobalValue.sharedInstance().user?.gameshelf_url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.emptyView.errorImage = UIImage(named: "empty_4_none");
        self.collectionView.emptyView.errorMsg = "你还没有收藏任何作品噢(>△<)";

        self.loginView = QWMessageLoginView.createWithNib()
        self.view.addSubview(self.loginView!)
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()

        self.loginView?.autoPinEdge(.top, to: .top, of: self.view)
        self.loginView?.autoPinEdge(.left, to: .left, of: self.view)
        self.loginView?.autoPinEdge(.right, to: .right, of: self.view)
        self.loginView?.autoPinEdge(.bottom, to: .bottom, of: self.view)

        self.observeNotification(LOGIN_STATE_CHANGED) { [weak self] (tempSelf, notification) -> Void in
            guard let _ = notification else {
                return
            }

            if let weakSelf = self {
                weakSelf.logic.listVO = nil
                weakSelf.collectionView.reloadData()
                weakSelf.book_url = QWGlobalValue.sharedInstance().user?.gameshelf_url
                weakSelf.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
                weakSelf.getData()
            }
        }
    }

    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()

        self.observe(QWReachability.sharedInstance(), property: "currentNetStatus") { [weak self] (tempSelf, object, old, newVal) -> Void in
            if let weakSelf = self {
                if QWReachability.sharedInstance().isConnectedToNet && weakSelf.logic.listVO == nil {
                    weakSelf.book_url = QWGlobalValue.sharedInstance().user?.gameshelf_url
                    weakSelf.getData()
                }
            }
        }
    }
}
