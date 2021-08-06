//
//  QWShopingVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWShopingCVC: QWBaseListVC {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        self.getData()
        self.collectionView.backgroundColor = UIColor(hex: 0xf4f4f4)
    }
    
    lazy var logic: QWShopLogic = {
        return QWShopLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.goodList
    }
    
    override func getData() {
        self.logic.isLoading = true
        
        self.logic.getGoodsListWithCompleteBlock { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.collectionView.emptyView.showError = true
                weakSelf.collectionView.reloadData()
            }
        }
    }
}

extension QWShopingCVC {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((QWSize.screenWidth() - 20))
        return CGSize(width: width, height: 123)
    }
    
    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let goods = self.listVO?.results[indexPath.item] as? GoodsVO {
            let cell = cell as! QWShopingCVCell
            cell.delegate = self
            cell.update(goodsVO: goods)
        }
    }
    
    override func didSelectedCellAtIndexPath(_  indexPath: IndexPath) {
    
    }
}

extension QWShopingCVC: QWShopingCVCellDelegate {
    
    func onPressedBuyTicket(cell: QWBaseCVCell, goodsVO: GoodsVO) {
        
        guard QWGlobalValue.sharedInstance().isLogin() else {
            QWRouter.sharedInstance().routerToLogin()
            return
        }
        if let price = goodsVO.price, let price_type = goodsVO.price_type,let user = QWGlobalValue.sharedInstance().user {
            if price_type == "轻石" && (user.coin?.intValue)! < price.intValue{
                self.showToast(withTitle: "轻石不足", subtitle: nil, type: .error)
                return
            } else if price_type == "重石" && (user.coin?.intValue)! < price.intValue{
                self.showToast(withTitle: "重石不足", subtitle: nil, type: .error)
                return
            }
        }
        let alertView = QWBuyTicketAlertView { (actionType) in
            
        }
        alertView?.update(withGoods: goodsVO)
        alertView?.show()
//        self.showLoading()
        
//        self.logic.buyTicketWithGoods(goodsVO,count: 2) { (aResponseObject, anError) in
//            self.hideLoading()
//            if let anError = anError {
//                self.showToastWithTitle(anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .Error)
//                return
//            }
//            
//            if let dict = aResponseObject as? [String: AnyObject] {
//                if let code = dict["code"] as? Int where code != 0 {
//                    if let message = dict["data"] as? String {
//                        self.showToastWithTitle(message, subtitle: nil, type: .Error)
//                    }
//                    else {
//                        self.showToastWithTitle("购买失败", subtitle: nil, type: .Error)
//                    }
//                }
//                else {
//                    if let price = goodsVO.price, let price_type = goodsVO.price_type,let user = QWGlobalValue.sharedInstance().user {
//                        if price_type == "轻石" {
//                            user.coin = NSNumber(integer:user.coin!.integerValue - price.integerValue)
//                            self.showToastWithTitle("获得购书券X1", subtitle: nil, type: .Error)
//
//                        } else if price_type == "重石" {
//                            user.gold = NSNumber(integer:user.gold!.integerValue - price.integerValue)
//                        } else {
//                            self.showToastWithTitle("购买失败", subtitle: nil, type: .Error)
//                        }
//                    }
//                }
//            }
//        }
    }
}

