//
//  QWFavoriteBooksCVC.swift
//  Qingwen
//
//  Created by wei lu on 8/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import Foundation
class QWFavoriteBooksCVC: QWBaseVC {
    
    enum QWFavouriteBooksType: Int {
        case booksRecommend = 0
        case booksMyFavorite
        case booksMyCollection
        case count
        case none = 999
        
        init(section: Int) {
            if let type = QWFavouriteBooksType(rawValue: section) {
                self = type
            }
            else {
                self = .none
            }
        }
    }
    
    @IBOutlet weak var favoriteBooksCollectionTopConstraints: NSLayoutConstraint!
    @IBOutlet var favoriteBooksCollection: QWCollectionView!
    @IBOutlet var recommandLayout: UICollectionViewFlowLayout!
    
    lazy var logic: QWFavoriteBooksLogic = {
        return QWFavoriteBooksLogic(operationManager: self.operationManager)
    }()
    
    var loginView: QWMessageLoginView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
//            let guide = self.view.safeAreaLayoutGuide.topAnchor
//            self.favoriteBooksCollection.topAnchor.constraint(equalTo: guide).isActive = true
        }
        
        
        self.loginView = QWMessageLoginView.createWithNib()
        self.view.addSubview(self.loginView!)
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
        
        self.loginView?.autoPinEdge(.top, to: .top, of: self.view)
        self.loginView?.autoPinEdge(.left, to: .left, of: self.view)
        self.loginView?.autoPinEdge(.right, to: .right, of: self.view)
        self.loginView?.autoPinEdge(.bottom, to: .bottom, of: self.view)
        
        
        self.favoriteBooksCollection.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.favoriteBooksCollection.backgroundColor = UIColor.white
        self.recommandLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12)
        self.recommandLayout.minimumInteritemSpacing = 0
        self.recommandLayout.minimumLineSpacing = 0
        self.favoriteBooksCollection.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        
        self.observeNotification(LOGIN_STATE_CHANGED) { [weak self] (tempSelf, notification) -> Void in
            guard let _ = notification else {
                return
            }
            
            if let weakSelf = self {
                weakSelf.logic.myCollectionListVO = nil
                weakSelf.logic.myFavoritelistVO = nil
                weakSelf.logic.recommendlistVO = nil
                weakSelf.favoriteBooksCollection.reloadData()
                weakSelf.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
                weakSelf.getData()
            }
        }
        self.observe(QWReachability.sharedInstance(), property: "currentNetStatus") { [weak self] (_, _, _, _) -> Void in
            if let weakSelf = self {
                if QWReachability.sharedInstance().isConnectedToNet && (
                    (weakSelf.logic.myCollectionListVO == nil) ||
                        (weakSelf.logic.myFavoritelistVO == nil) ||
                        (weakSelf.logic.recommendlistVO == nil)
                    ){
                    weakSelf.getData()
                }
            }
        }
        let index_ad:String = QWGlobalValue.sharedInstance().index_ad!
        if index_ad == "2" {
            
        }
        else if index_ad == "0"{
            favoriteBooksCollectionTopConstraints.constant = QWSize.bannerHeight()
            self.createHeadView()
        }
        else if index_ad == "1"{
            favoriteBooksCollectionTopConstraints.constant = QWSize.bannerHeight()
            self.createAttentionDefaultView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if QWGlobalValue.sharedInstance().isLogin() {
           self.getData()
        }
        
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
        
    }
    
    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }
    
    override func setPageShow(_ enable: Bool) {
        self.favoriteBooksCollection.scrollsToTop = enable
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        
        if !QWGlobalValue.sharedInstance().isLogin(){
            return
        }
        
        self.logic.isLoading = true
        //self.favoriteBooksCollection.emptyView.showError = false

        var step = QWFavouriteBooksType.count.rawValue - 1
        self.logic.recommendlistVO = nil
        self.logic.getRecommendsWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }
        
        self.logic.myFavoritelistVO = nil
        self.logic.getFavoriteBooksWithCompleteBlock(listId: nil, isOwn: 1, { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        })
        
        self.logic.myCollectionListVO = nil
        self.logic.getFavoriteBooksWithCompleteBlock(listId: nil, isOwn: 0, { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        })
    }
    
    override func update() {
        if self.logic.isLoading == false {
            self.favoriteBooksCollection.mj_header.beginRefreshing()
        }
    }
    
    override func repeateClickTabBarItem(_ count: Int) {
        if count % 2 == 0 && self.logic.isLoading == false {
            self.favoriteBooksCollection.mj_header.beginRefreshing()
        }
    }
    
    func updateWithStep(_ step: inout Int) {
        
        step -= 1
        if step > 0 {
            return
        }
        self.logic.isLoading = false
        self.favoriteBooksCollection.reloadData()
        self.favoriteBooksCollection.mj_header.endRefreshing()
        
    }
    
    @IBAction func onPressedSectionHeaderActionBtn(_ sender: UIButton) {
        
    }
    
    func createHeadView()  {
        if(QWSize.screenHeight() == 812.0 || QWSize.screenHeight() == 896.0){//iphoneX
            let headView = QWGDTbannerAdView.init(frame: CGRect(x:0,y:64+24,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
            headView?.backgroundColor = UIColor.white
            self.view.addSubview(headView!)
        }
        else{
            let headView = QWGDTbannerAdView.init(frame: CGRect(x:0,y:64,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
            headView?.backgroundColor = UIColor.white
            self.view.addSubview(headView!)
        }
        
    }
    func createAttentionDefaultView()  {
        if(QWSize.screenHeight() == 812.0 || QWSize.screenHeight() == 896.0){
            let index_adInc:String = QWGlobalValue.sharedInstance().index_adInc!
            let index_adUrl:String = QWGlobalValue.sharedInstance().index_adURL!
            let view = QWDefaultAdImgView.init(frame: CGRect(x:0,y:64 + 24,width:QWSize.screenWidth(),height:QWSize.bannerHeight()), withImgUrl:index_adInc ,withPost:index_adUrl)
            self.view.addSubview(view!)
        }
        else{
            let index_adInc:String = QWGlobalValue.sharedInstance().index_adInc!
            let index_adUrl:String = QWGlobalValue.sharedInstance().index_adURL!
            let view = QWDefaultAdImgView.init(frame: CGRect(x:0,y:64,width:QWSize.screenWidth(),height:QWSize.bannerHeight()), withImgUrl:index_adInc ,withPost:index_adUrl)
            self.view.addSubview(view!)
        }
        
    }
}


extension QWFavoriteBooksCVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.logic.isLoading == false {
            return QWFavouriteBooksType.count.rawValue
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch QWFavouriteBooksType(section: section) {
        case .booksRecommend:
            if let recommend = self.logic.recommendlistVO?.results {
                if(recommend.count > 3){
                    return 3
                }
                return recommend.count
            }
            else {
                return 0
            }
        case .booksMyFavorite:
            if (self.logic.myFavoritelistVO?.results) != nil {
                return 1
            }
            else {
                return 0
            }
        case .booksMyCollection:
            if let voc = self.logic.myCollectionListVO?.results {
                return voc.count
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func resize(_ size: CGSize) {
        //self.recommandLayout?.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if (SWIFT_IS_IPHONE_DEVICE) {
            switch QWFavouriteBooksType(section: (indexPath as NSIndexPath).section) {
            case .booksRecommend:
                let width = (QWSize.screenWidth() - 50) / 3
                return CGSize(width: width, height: width + 33+12);
            case .booksMyFavorite:
                return CGSize(width:QWSize.screenWidth(), height:120);
            case .booksMyCollection:
                return CGSize(width:QWSize.screenWidth(), height:120);
            default:
                return CGSize.zero
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: QWSize.screenWidth(), height: 44)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "fav_header", for: indexPath) as! QWFavoriteBooksHeaderCRView
        view.updateWithIndexPath(indexPath)
        switch QWFavouriteBooksType(section: indexPath.section)  {
        case .booksMyFavorite:
            if let count = self.logic.myFavoritelistVO?.count{
                if (count.intValue >= 1){
                    QWGlobalValue.sharedInstance().created_favorite = 1
                    QWGlobalValue.sharedInstance().save()
//                    view.actionImageView.isHidden = true
//                    view.rightLabel.isHidden = true
                }
                view.titleLabel.text! += "(1)"
            }
        case .booksMyCollection:
            if let count = self.logic.myCollectionListVO?.count{
                if (count.intValue >= 1){
                    view.actionImageView.isHidden = true
                    view.rightLabel.isHidden = true
                }
                view.titleLabel.text! += "("+count.stringValue+")"
            }
        default:
            break
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch QWFavouriteBooksType(section: indexPath.section) {
        case .booksRecommend:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommend", for: indexPath) as! QWRecommendBooksCell
            if let items = self.logic.recommendlistVO?.results?[(indexPath as NSIndexPath).item] as? RecommendBooksVO {
                cell.updateWithRecommendItem(items)
            }
            return cell
        case .booksMyFavorite:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QWBookListsCVCell", for: indexPath) as! QWBookListsCVCell
            if let items = self.logic.myFavoritelistVO?.results?[(indexPath as NSIndexPath).item] as? FavoriteBooksVO {
                cell.updateWithFavItem(items)
            }
            return cell

        case .booksMyCollection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QWBookListsCVCell", for: indexPath) as! QWBookListsCVCell
            if let items = self.logic.myCollectionListVO?.results?[(indexPath as NSIndexPath).item] as? FavoriteBooksVO {
                cell.updateWithFavItem(items)
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        func didSelectItemAtIndex(_ book: NSObject) {
            
            if let data = book as? FavoriteBooksVO{
                var params = [String: Any]()
                params["title"] = data.title
                params["intro"] = data.intro
                params["id"] = data.nid
                if let user = data.user{
                    params["username"] = user.username
                    params["avatar"] = user.avatar
                    params["profile_url"] = user.profile_url
                }
                
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "favorite", andParams: params))
            }else if let data = book as? RecommendBooksVO{
                var params = [String: Any]()

                params["id"] = data.work!.nid
                
                
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "favorite", andParams: params))
            }
        }

        switch QWFavouriteBooksType(section: indexPath.section) {
        case .booksRecommend:
            if let re = self.logic.recommendlistVO?.results?[(indexPath as NSIndexPath).item] as? RecommendBooksVO{
                didSelectItemAtIndex(re)
            }
        case .booksMyFavorite:
            if let fav = self.logic.myFavoritelistVO?.results?[(indexPath as NSIndexPath).item] as? FavoriteBooksVO {
                didSelectItemAtIndex(fav)
            }
        case .booksMyCollection:
            if let col = self.logic.myCollectionListVO?.results?[(indexPath as NSIndexPath).item] as? FavoriteBooksVO {
                didSelectItemAtIndex(col)
            }
        default:
            return
        }
    }
    
}

