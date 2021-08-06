//
//  QWBestCVC.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWBestCVC: QWBaseVC {

    enum QWBestType: Int {
        case slide = 0
        case discuss
        case recommend  //编辑推荐
        case new        //签约新秀
        case recommend2 //小编推荐
        case hot        //热门作品
        case discount   //限时优惠
        case zone       //分区
        case update     //最近更新
        case count
        
        case none = 999

        init(section: Int) {
            if let type = QWBestType(rawValue: section) {
                self = type
            }
            else {
                self = .none
            }
        }
    }

    @IBOutlet var collectionView: QWCollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!

    lazy var logic: QWBestLogic = {
        return QWBestLogic(operationManager: self.operationManager)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.collectionView.backgroundColor = UIColor.white
        self.layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        self.layout.minimumInteritemSpacing = 0
        self.layout.minimumLineSpacing = 0
        self.collectionView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(overLordLaunch), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observe(QWReachability.sharedInstance(), property: "currentNetStatus") { [weak self] (_, _, _, _) -> Void in
            if let weakSelf = self {
                if QWReachability.sharedInstance().isConnectedToNet && (weakSelf.logic.slideVO == nil || weakSelf.logic.bestVO == nil ) {
                    weakSelf.getData()
                }
            }
        }
        
        if let dict = QWGlobalValue.sharedInstance().systemSwitchesDic{
            
            if  dict["home"] as! Int == 2 {
                self.collectionView.isHidden = true
                let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                self.view.addSubview(view)
            }
            else if  dict["home"] as! Int == 1 {
                if QWGlobalValue.sharedInstance().isLogin() == false {
                    self.collectionView.isHidden = true
                    let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                    self.view.addSubview(view)
                    return;
                }
                else{
                    self.collectionView.isHidden = false
                }
                
            }
            else{
                
            }
            
        }
        
    }

    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }

    override func setPageShow(_ enable: Bool) {
        self.collectionView.scrollsToTop = enable
    }
    func overLordLaunch() {
        print("12312312321")
    }
    override func getData() {
        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true
        self.collectionView.emptyView.showError = false

        var step = QWBestType.count.rawValue - 1
        
        self.logic.slideVO = nil
        self.logic.getSlideWithComplete { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }
        
        self.logic.getOngoingActivityList { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.collectionView.reloadData()

            }
        }
        
        self.logic.bestVO = nil
        self.logic.getRecommendWithComplete { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }

        self.logic.smallBestVO = nil
        self.logic.getSmallBestVO { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)

            }
        }

        self.logic.newlyWorkVO = nil
        self.logic.getNewlyWorkVO { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }

        self.logic.hotWorkVO = nil
        self.logic.getHotWorkVO { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)

            }
        }

        self.logic.dicountWorkVO = nil
        self.logic.getDicountWorkVO { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)

            }
        }
        
        self.logic.zoneRecommendVO = nil
        self.logic.getZoneRecommendVO { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
                
            }
        }
        self.logic.updateListVO = nil
        self.logic.getUpdateListVO { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
                
            }
        }
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
    }

    override func getMoreData() {
        self.logic.getUpdateListVO { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                let section = QWBestType.update.rawValue
                let indexSet = NSIndexSet(index: section) as IndexSet
                weakSelf.collectionView.reloadSections(indexSet)
            }
        }
    }
    override func update() {
        if self.logic.isLoading == false {
            self.collectionView.mj_header.beginRefreshing()
        }
    }

    override func repeateClickTabBarItem(_ count: Int) {
        if count % 2 == 0 && self.logic.isLoading == false {
            self.collectionView.mj_header.beginRefreshing()
        }
    }

    func updateWithStep(_ step: inout Int) {
        step -= 1
        if step > 0 {
            return
        }

        self.logic.isLoading = false
        self.collectionView.emptyView.showError = true
        self.collectionView.mj_header.endRefreshing()
        self.collectionView.reloadData()
    }

    @IBAction func onPressedSectionHeaderActionBtn(_ sender: UIButton) {
        
    }
    func showAchievement()  {
        print("显示")
    }
}

//MARK: Search
extension QWBestCVC {
    
    @IBAction func onPressedSearchBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension QWBestCVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.logic.isShow() {
            return QWBestType.count.rawValue
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch QWBestType(section: section) {
        case .slide:
            if let _ = self.logic.slideVO?.results {
                return 1
            }
            else {
                return 0
            }
        case .discuss:
            return 1
        case .recommend:
            if let vos = self.logic.bestVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case  .new:
            if let vos = self.logic.newlyWorkVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case .recommend2:
            if let vos = self.logic.smallBestVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case .hot:
            if let vos = self.logic.hotWorkVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case .discount:
            if let vos = self.logic.dicountWorkVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case .zone:
            if let vos = self.logic.zoneRecommendVO?.results {
                
                return vos.count
            }
            else {
                return 0
            }
        case .update:
            if let vos = self.logic.updateListVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }

    override func resize(_ size: CGSize) {
        self.layout?.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (SWIFT_IS_IPHONE_DEVICE) {
            switch QWBestType(section: (indexPath as NSIndexPath).section) {
            case .slide:
                let width = ceil(min(QWSize.screenWidth(), QWSize.screenHeight()))
                return CGSize(width:width, height:width / 2);
            case .discuss:
                return CGSize(width:QWSize.screenWidth() - 20, height:92);
            case .recommend:
                let width = floor((QWSize.screenWidth() - 40) / 3)
                return CGSize(width: width, height: width + 33);
            case .recommend2, .discount:
                let width = floor((QWSize.screenWidth() - 50) / 4)
                return CGSize(width: width, height: width / 0.75 + 50);
            case .new, .hot, .zone:
                let width = floor((QWSize.screenWidth() - 30) / 2)
                return CGSize(width: width, height: (width / 2) / 0.75 + 10)
            case .update:
                return CGSize(width: QWSize.screenWidth(), height: 130)
            default:
                return CGSize.zero
            }
        }
        else {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                switch QWBestType(section: indexPath.section) {
                case .slide:
                    return CGSize(width:max(QWSize.screenWidth(), QWSize.screenHeight()), height:min(QWSize.screenWidth(), QWSize.screenHeight()) / 2);
                case .discuss:
                    return CGSize(width: QWSize.screenWidth(), height: 148)
                case .recommend:
                    let width = floor((QWSize.screenWidth() - 70) / 6)
                    return CGSize(width: width, height: width + 28);
                case .recommend2, .discount:
                    let width = floor((QWSize.screenWidth() - 120) / 6)
                    return CGSize(width: width, height: width / 0.75 + 50);
                case .new, .hot, .zone:
                    let width = floor((QWSize.screenWidth() - 50) / 4)
                    return CGSize(width: width, height: (width / 2) / 0.75 + 10)
                case .update:
                    return CGSize(width: QWSize.screenWidth(), height: 130)
                default:
                    return CGSize.zero
                }
            }
            else {
                switch QWBestType(section: (indexPath as NSIndexPath).section) {
                case .slide:
                    let width = ceil(min(QWSize.screenWidth(), QWSize.screenHeight()))
                    return CGSize(width:width, height:width / 2);
                case .discuss:
                    return CGSize(width:QWSize.screenWidth() - 20, height:148);
                case .recommend:
                    let width = floor((QWSize.screenWidth() - 50) / 4)
                    return CGSize(width: width, height: width + 28);
                case .recommend2, .discount:
                    let width = floor((QWSize.screenWidth() - 50) / 4)
                    return CGSize(width: width, height: width / 0.75 + 50);
                case .new, .hot, .zone:
                    let width = floor((QWSize.screenWidth() - 40) / 3)
                    return CGSize(width: width, height: (width / 2) / 0.75 + 10)
                case .update:
                    return CGSize(width: QWSize.screenWidth(), height: 130)
                default:
                    return CGSize.zero
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch QWBestType(section: section) {
        case .slide, .discuss:
            return CGSize.zero
        case .update:
            return CGSize(width: QWSize.screenWidth(), height: 28)
        default:
            return CGSize(width: QWSize.screenWidth(), height: 38)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch QWBestType(section: section) {
        case .slide:
            return CGSize.zero
        default:
            return CGSize(width: QWSize.screenWidth(), height: 2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! QWBestHeaderCRView
            view.updateWithIndexPath(indexPath)
            return view
        }
        else  {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            view.backgroundColor = UIColor(hex: 0xf4f4f4)
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch QWBestType(section: indexPath.section) {
        case .slide:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slide", for: indexPath) as! QWBestHeaderCVCell
            if let items = self.logic.slideVO?.results as? [BestItemVO] {
                cell.updateWithBestItems(items)
            }
            return cell
        case .discuss:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discuss", for: indexPath) as! QWBestDiscussCVCell
            cell.updateDiscussItem(withEntrances:self.logic.entrances as? [EntranceVO])
//            cell.activityPageBtn.isHidden = !self.logic.showActivityPageNumber
            cell.activityPageBtn.isHidden = true
            return cell

        case .recommend:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommend", for: indexPath) as! QWBestCVCell
            if let best = self.logic.bestVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                cell.updateWithBestItem(best)
            }
            return cell
            
        case .new:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hot", for: indexPath) as! QWHotCVCell
            if let best = self.logic.newlyWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                cell.updateWithBestItem1(best)
            }
            return cell
        case .recommend2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guess", for: indexPath) as! QWBestCVCell
            if let best = self.logic.smallBestVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
            cell.updateWithBestItem1(best)
            }
            return cell
        case .hot:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hot", for: indexPath) as! QWHotCVCell
            if let best = self.logic.hotWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                cell.updateWithBestItem1(best)
            }
            return cell
        case .discount:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guess", for: indexPath) as! QWBestCVCell
            if let best = self.logic.dicountWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                cell.updateWithBestItem1(best)
            }
            return cell
        case .zone:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hot", for: indexPath) as! QWBestCVCell
            if let best = self.logic.zoneRecommendVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                cell.updateWithBestItem1(best)
                print("updateWithBestItem1 = ",best)
            }
            return cell
        case .update:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! QWBookCVCell2
            if let book = self.logic.updateListVO?.results?[(indexPath as NSIndexPath).item] as? BookVO {
                cell.updateWithBookVO(book)
            }
            if let list = self.logic.updateListVO?.results, let count = self.logic.updateListVO?.count?.intValue {
                if list.count == indexPath.item + 2 && list.count < count {
                    getMoreData()
                }
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        func didSelectItemAtIndex(_ best: BestItemVO) {
            if let href = best.href {
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString:href)!)
                return
            }
            if let book = best.work {
                var params = [String: String]()
                params["id"] = book.nid?.stringValue
                params["book_url"] = book.url
                if best.work_type == .game {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
                }
                else {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
                }
            }
        }
        
        switch QWBestType(section: indexPath.section) {
        case .recommend:
            if let best = self.logic.bestVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO{
                didSelectItemAtIndex(best)
            }
        case .new:
            if let best = self.logic.newlyWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                didSelectItemAtIndex(best)
            }
        case .recommend2:
            if let best = self.logic.smallBestVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                didSelectItemAtIndex(best)
            }
        case .hot:
            if let best = self.logic.hotWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO{
                didSelectItemAtIndex(best)
            }
        case .discount:
            if let best = self.logic.dicountWorkVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                didSelectItemAtIndex(best)
            }
        case .zone:
            if let best = self.logic.zoneRecommendVO?.results?[(indexPath as NSIndexPath).item] as? BestItemVO {
                didSelectItemAtIndex(best)
            }
        case .update:
            if let book = self.logic.updateListVO?.results?[indexPath.item] as? BookVO {
                var params = [String: String]()
                params["id"] = book.nid?.stringValue
                params["book_url"] = book.url
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
            }
        default:
            return
        }
    }
    
}



