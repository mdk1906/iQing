//
//  QWMyGoodsTVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWMyGoodsCVC: QWBaseListVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        self.collectionView.backgroundColor = UIColor(hex: 0xf4f4f4)
        self.collectionView.emptyView.errorImage = UIImage(named: "empty_5_none")
        self.collectionView.emptyView.errorMsg = "暂无道具囧~-~"
        self.getData()
    }
    
    lazy var logic: QWShopLogic = {
        return QWShopLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.propsList
    }
    
    override func update() {
        self.getData()
    }
    
    override func getData() {
        self.logic.isLoading = true
        self.logic.propsList = nil
        self.logic.getMyPropsListWithCompleteBlock { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.collectionView.reloadData()
                weakSelf.collectionView.emptyView.showError = true
            }
        }
    }
}

extension QWMyGoodsCVC {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((QWSize.screenWidth() - 20))
        return CGSize(width: width, height: 123)
    }
    
    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let props = self.listVO?.results[indexPath.item] as? PropsVO {
            let cell = cell as! QWMyGoodsCVCell
            cell.update(props: props)
        }
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let props = self.listVO?.results[indexPath.item] as? PropsVO,let goods = props.commodity, let url = goods.my_hold_url{
            let vc = QWMyDetailGoodsTVC.createFromStoryboard(withStoryboardID: "singleprops", storyboardName: "QWShop")!
            vc.url = url
            vc.type = 1
            vc.title = goods.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
