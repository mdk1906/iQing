//
//  FaithPointCell.swift
//  Qingwen
//
//  Created by wei lu on 7/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//  之前的没法复用!

import UIKit

class QWFaithPointTVCell: QWBaseTVCell {
    
    
    lazy var collectionView:QWCollectionView = {
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
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: 75)
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsetsMake(8, 10, 0, 10)
        layout.scrollDirection = .horizontal

        let collection = QWCollectionView(frame: .zero, collectionViewLayout: layout )
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    var doChargeBlock = {() in }
    
    var listVO: UserPageVO?
    var faithType: QWCharegeType?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "QWBooksListLatestCell")
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpViews(){
        self.contentView.addSubview(self.collectionView)
        self.collectionView.autoPinEdge(.top, to: .top, of: self.contentView)
        self.collectionView.autoPinEdge(.left, to: .left, of: self.contentView)
        self.collectionView.autoPinEdge(.right, to: .right, of: self.contentView)
        self.collectionView.autoPinEdge(.bottom, to: .bottom, of: self.contentView)
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
        self.listVO = nil
        self.listVO = vo
        self.showEmpty()
        self.collectionView.reloadData()
        self.faithType = QWCharegeType(rawValue: chargeType.intValue)
    }
}
extension QWFaithPointTVCell: UICollectionViewDataSource, UICollectionViewDelegate {
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
        collectionView.register(QWFaithPointUnitCell.self, forCellWithReuseIdentifier: "cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWFaithPointUnitCell
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
