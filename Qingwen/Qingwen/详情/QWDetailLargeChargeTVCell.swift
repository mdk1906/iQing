//
//  QWDetailDynamicTVCell.swift
//  Qingwen
//
//  Created by mumu on 16/9/18.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

enum QWCharegeType: NSInteger{
    case coin = 0 //轻石
    case gold     //重石
    case fatith   //信仰
}

class QWDetailLargeChargeTVCell: QWBaseTVCell {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var layout: UICollectionViewFlowLayout!
    
    var doChargeBlock = {() in }
    
    var listVO: UserPageVO?
    var chargeType: QWCharegeType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var width:CGFloat = 0
        if SWIFT_ISIPHONE9_7 {
            if SWIFT_IS_LANDSCAPE {
                width = QWSize.screenWidth() / 9
            } else  {
                width = QWSize.screenWidth() / 7
            }
        }else if SWIFT_ISIPHONE4_7 || SWIFT_ISIPHONE5_5 {
            
            width = (QWSize.screenWidth() - 20) / 5
        } else {
            width = (QWSize.screenWidth() - 20) / 4
        }
        self.layout.itemSize = CGSize(width: width, height: 75)
        self.layout.minimumLineSpacing = 1
        self.layout.sectionInset = UIEdgeInsetsMake(8, 10, 0, 10)

        self.collectionView.scrollsToTop = false
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.isScrollEnabled = true
        self.showEmpty()
    }
    
    fileprivate func showEmpty() {
        if let vo = listVO , vo.results.count > 0 {
            self.collectionView.backgroundView = nil
        } else  {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: QWSize.screenWidth(), height: 85)
            )
            label.text = "快投石给作者打打气吧"
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = UIColor(hex: 0x505050)
            label.bk_tapped({ 
                self.doChargeBlock()

            })
            self.collectionView.backgroundView = label
        }
    }
    
    func updateChagreWithListVO(_ vo: UserPageVO, chargeType: NSNumber) {
        self.collectionView.backgroundColor = UIColor.white
        self.listVO = vo
        self.showEmpty()
        self.collectionView.reloadData()
        self.chargeType = QWCharegeType(rawValue: chargeType.intValue)
    }
}
extension QWDetailLargeChargeTVCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let vo = self.listVO {
            return vo.results.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func isStoneCharge(_ user: UserVO) -> Bool {
            if let coin = user.coin , coin.intValue > 0 {
                return true
            } else  {
                return false
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWDetailLargeChargeCVCell
        if let vo = self.listVO ,let user = vo.results[(indexPath as NSIndexPath).item] as? UserVO {
            cell.updateChargeCellWithUserPageVO(user)
            cell.updateWithUserFaith(indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vo = self.listVO,let userVO = vo.results[(indexPath as NSIndexPath).item] as? UserVO, let user = userVO.user , vo.results.count > 0 else {
           return
        }
        var params = [String: AnyObject]()

        params["profile_url"] = user.profile_url as AnyObject?
        params["username"] = user.username as AnyObject?
        if let sex = user.sex {
            params["sex"] = sex
        }
        if let avatar = user.avatar {
            params["avatar"] = avatar as AnyObject?
        }
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "user", andParams: params))
    }
}
