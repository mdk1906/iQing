//
//  QWBookListsDetails.swift
//  Qingwen
//
//  Created by wei lu on 20/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

extension QWBooksListDetails{
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWBookListsDetails"
        vo.storyboardID = "BookListsDetails"
        QWRouter.sharedInstance().register(vo, withKey: "favorite")
    }
}

class QWBooksListDetails:QWBaseVC{
    
    @IBOutlet var rightBarBtn: UIBarButtonItem!

    //var scrollContainer = UIScrollView()
    //@IBOutlet var booksListCollectionView: QWCollectionView!
    @IBOutlet var Container: UIView!
    //@IBOutlet var layout: UICollectionViewFlowLayout!
    
    @IBOutlet var addCollectionBtn:UIButton!
    @IBOutlet var discussBtn:UIButton!
    @IBOutlet var shareBtn:UIButton!
    @IBOutlet weak var addCollectionLabel: UILabel!
    
    @IBOutlet var discuss: UILabel!
    @IBOutlet var footer: UIView!
    var headerView =  QWFavoriteDetailsHeaderView()
    var showAll:Bool = false
    var height:CGFloat!
    var bookListID:NSNumber?
    var work_url :String?
    var pop:QWWordsInputPopUp?
    var popCell:NSNumber?
//    var bodyCollectionView:QWCollectionView?
    var isLeft:Bool = true
    var basicHeight:CGFloat = 220.0
    var pageOffset:CGFloat = 0
    
    lazy var leftVC: QWFavoriteBooks = {
        let vc = QWFavoriteBooks()
        vc.delegate = self
        self.addChildViewController(vc)
        return vc
    }()
    lazy var midVC: QWFavoriteLatestInfo = {
        let vc = QWFavoriteLatestInfo()
        self.addChildViewController(vc)
        return vc
    }()
    var pages: [UIViewController]? {
        return [self.leftVC,self.midVC]
    }
    var currentVC = UIViewController()
    var segmentPaper: MXSegmentedPager!
    var segmentTitles:[String]!
    
    lazy var logic: QWGetBookslistDetailsLogic = {
        let logic = QWGetBookslistDetailsLogic(operationManager: self.operationManager)
        return logic
    }()
    
    lazy var cellOpLogic:QWAddBookCollectionLogic = {
        return QWAddBookCollectionLogic(operationManager: self.operationManager)
    }()

    var bookOrder = "-1"
    
    @IBAction func didPressTopRightButton(_ sender: Any) {
        if(self.logic.headerData == nil || self.logic.headerData?.nid == nil){
             self.showToast(withTitle: "没有找到该书单", subtitle: nil, type: .alert)
            return
        }
        let action = UIActionSheet()
        action.bk_addButton(withTitle: "调整作品顺序") {(void) in
            let action2 = UIActionSheet()
            action2.bk_addButton(withTitle: "更新时间-正序") {(void) in
                self.bookOrder = "0"
                if(self.logic.headerData?.nid != nil){
                    self.logic.setBookOrderWithCompleteBlock(listId: self.logic.headerData?.nid, order: self.bookOrder, {(aResponseObject, anError) in
                        self.getData()
                    })
                }
            }
            action2.bk_addButton(withTitle: "更新时间-倒序") {(void) in
                self.bookOrder = "-0"
                if(self.logic.headerData?.nid != nil){
                    self.logic.setBookOrderWithCompleteBlock(listId: self.logic.headerData?.nid, order: self.bookOrder, {(aResponseObject, anError) in
                        self.getData()
                    })
                }
            }
            action2.bk_setCancelButton(withTitle: "取消") {
                
            }
//            action2.bk_addButton(withTitle: "信仰") {(void) in
//                self.bookOrder = "-3"
//                if(self.logic.headerData?.nid != nil){
//                    self.logic.setBookOrderWithCompleteBlock(listId: self.logic.headerData?.nid, order: self.bookOrder, {(aResponseObject, anError) in
//                        self.getData()
//                    })
//                }
//            }
//            action2.bk_addButton(withTitle: "战力") {(void) in
//                self.bookOrder = "-2"
//                if(self.logic.headerData?.nid != nil){
//                    self.logic.setBookOrderWithCompleteBlock(listId: self.logic.headerData?.nid, order: self.bookOrder, {(aResponseObject, anError) in
//                        self.getData()
//                    })
//                }
//            }
            action2.show(in:  QWRouter.sharedInstance().rootVC.view)
        }
        
        action.bk_addButton(withTitle: "编辑书单简介") {(void) in
            var params = [String:String]()
            params["action"] = "update"
            params["title"] = self.logic.headerData?.title
            params["intro"] = self.logic.headerData?.intro
            params["id"] = self.logic.headerData?.nid!.stringValue
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "CreateNewBooksList", andParams: params))
        }
        action.bk_setCancelButton(withTitle: "取消") {
            
        }
        action.show(in:  QWRouter.sharedInstance().rootVC.view)
    }
    
    
    func pageConfig(){
        self.segmentTitles = ["作品","动态"]
        self.segmentPaper = MXSegmentedPager(frame: CGRect(x: 0, y: 0, width: QWSize.screenWidth(), height: QWSize.screenHeight()))
        //头部
        self.segmentPaper.parallaxHeader.view = self.headerView
        self.segmentPaper.parallaxHeader.mode = .topFill; // 平行头部填充模式
        self.segmentPaper.parallaxHeader.height = self.basicHeight; // 头部高度
        self.segmentPaper.parallaxHeader.minimumHeight = 78; // 头部最小高度
        
        //self.segmentPaper?.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:44)
        segmentPaper.segmentedControl.backgroundColor = UIColor(hex: 0xf8f8f8)
        segmentPaper.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x888888)!, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        segmentPaper.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0)
        //设置选择时状态
        segmentPaper.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0xFB83AC)!,  NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        segmentPaper.segmentedControl.selectionIndicatorLocation = .down
        segmentPaper.segmentedControl.selectionStyle = .textWidthStripe
        segmentPaper.segmentedControl.selectionIndicatorColor = UIColor(hex: 0xFB83AC)
        segmentPaper.segmentedControl.selectionIndicatorHeight = 3.0
        segmentPaper.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -10)
        //设置下划线
        segmentPaper.segmentedControl.borderType = .bottom
//        segmentPaper.segmentedControl.borderColor = UIColor(hex: 0xDCDCDC)
//        segmentPaper.segmentedControl.borderWidth = 0.5
        self.view.addSubview(self.segmentPaper)
        self.segmentPaper.delegate = self
        self.segmentPaper.dataSource = self
        if(QWSize.screenHeight() == 812.0){//iphoneX
            self.segmentPaper.autoPinEdge(.top, to: .top, of: self.view,withOffset:0)
        }
        else{
            self.segmentPaper.autoPinEdge(.top, to: .top, of: self.view)
        }
        
        self.segmentPaper.autoPinEdge(.bottom, to: .top, of: self.footer)
        self.segmentPaper.autoPinEdge(.left, to: .left, of: self.view)
        self.segmentPaper.autoPinEdge(.right, to: .right, of: self.view)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pop = QWWordsInputPopUp.createWithNib()
        self.pop?.delegate = self
        
        

        var offsetHeight = self.navigationController?.navigationBar.frame.size.height
        if #available(iOS 11.0, *) {
            offsetHeight = offsetHeight! + UIApplication.shared.statusBarFrame.size.height
        }
        
        self.pageConfig()
        self.configHeadView()
        
        self.view.bringSubview(toFront: self.footer)
        self.observeNotification(LOGIN_STATE_CHANGED) { [weak self] (tempSelf, notification) -> Void in
            guard let _ = notification else {
                return
            }
            
            if let weakSelf = self {
                weakSelf.getData()
            }
        }
        
        
        self.getData()
    }
    
    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configNavigationBar()
        self.configDisscussBtn()
//        self.getData()
//        let view = UIView(frame:CGRect.init(0,0, UIScreen.main.bounds.width,44))
//        view.backgroundColor = UIColor.black
//        self.view.addSubview(view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func onPressCollectionBtn(_ sender: Any) {
        if QWGlobalValue.sharedInstance().isLogin() == false {
            QWRouter.sharedInstance().routerToLogin()
            return;
        }
        if self.logic.isLoading {
            return
        }
        
        self.logic.addBookListsCollectionWithCompleteBlock(listId: self.bookListID) { [weak self] (aResponseObject, anError) in
            if let weakSelf = self {
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    weakSelf.logic.headerData = nil
                }else if(aResponseObject != nil){
                    if let dict = aResponseObject as? [String: AnyObject] {
                        if let code = dict["code"] as? Int, code == 0 {
                            guard let collectioTag = weakSelf.logic.headerData?.subscribe?.boolValue else{
                                self?.showToast(withTitle: "获取不到相关信息", subtitle: nil, type: .alert)
                                return
                            }
                            weakSelf.addCollectionBtn.isSelected = collectioTag
                            weakSelf.addCollectionLabel.text = weakSelf.addCollectionBtn.isSelected ? "已收藏": "收藏"
                            if(!collectioTag){//true:subscribed
                                weakSelf.showToast(withTitle: "收藏成功", subtitle: nil, type: .alert)
                            }else{
                                weakSelf.showToast(withTitle: "取消收藏", subtitle: nil, type: .alert)
                            }
                            weakSelf.getData()
                        }else{
                            if let info = dict["msg"] as? String{
                                 weakSelf.showToast(withTitle: info, subtitle: nil, type: .alert)
                            }
                        }

                    }
                }
            }
        }
        
    }
    
    @IBAction func onPressDisscussBtn(_ sender: Any) {
        if let bookList = self.logic.headerData{
            var params = [String:Any]()
            params["url"] = bookList.bf_url
            
            let predicate = NSPredicate(format: "nid == \(self.logic.headerData!.nid!)")
            let bookListCD = BookListsCD.mr_findFirst(with: predicate, in: QWFileManager.qwContext())
            bookListCD?.lastViewDate = self.logic.bfUpdate! as Date
            QWFileManager.qwContext().mr_saveToPersistentStore(completion: nil)
//            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "discuss", andParams: params))
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "discuss", andParams: params))
        }
    }
    
    @IBAction func onPressCharge(_ sender: Any) {
        if let tab = self.tabBarController as? QWTBC{
            tab.doCharge(withFavorite: self.logic.headerData, heavy: true)
        }
        
    }
    
    @IBAction func onPressShareBtn(_ sender: Any) {
        if let bookList = self.logic.headerData{
            var params = [String:Any]()
            params["title"] = bookList.title
            params["image"] = bookList.cover?.first;
            params["intro"] = bookList.intro;
            params["url"] = "https://www.iqing.in/favorite/"+bookList.nid!.stringValue+"/"
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "share", andParams: params))
        }
    }
    
/************************************/
/*UI Config*/
/************************************/
    var estCellHeight:CGFloat{
        get{
            let start = CGFloat(270) + 44.0
            var end:CGFloat = 0;
            if #available(iOS 11.0, *) {
                end = self.Container.bottom - self.view.safeAreaInsets.bottom - 44.0
            } else {
                end = self.Container.bottom - 44.0
            }
            let diff = end - start
            return diff
        }
    }
    
    var HEIGHT_LENGTH:CGFloat {
        get{
            if let height = self.navigationController?.navigationBar.frame.size.height{
                return height
            }
            return 36.0
        }
    }
    
    var headHeightConstraints:NSLayoutConstraint?
    func configHeadView(){
//        self.headerView.autoPinEdge(.left, to: .left, of: self.view)
//        self.headerView.autoPinEdge(.right, to: .right, of: self.view)
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        //self.headHeightConstraints = self.headerView.autoSetDimension(.height, toSize: 270)
        self.headerView.headView.delegate = self
    }
    
    func reloadHeadView(){
        
        //Data
        if let items = self.logic.headerData{
            self.headerView.updateItemWithData(items, ShowAll: self.showAll)
            self.height = self.headerView.getHeaderHeight(textFrame:items.intro)
        }
        //UI
        if(self.showAll){
            //self.headerView.removeConstraint(self.headHeightConstraints!)
            //self.headHeightConstraints = self.headerView.autoSetDimension(.height, toSize: self.height)
            self.segmentPaper.parallaxHeader.height = self.height
            //headHeightConstraints?.constant = self.height
        }else{
            self.headHeightConstraints?.constant = self.basicHeight
            
        }
        self.view.layoutIfNeeded()
    }
    
    func configNavigationBar()
    {
        func defaultNavBar(){
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.clear]
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default )
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.shadowImage = UIImage();
             self.navigationController?.view.backgroundColor = UIColor.clear
            self.navigationItem.leftBarButtonItem?.tintColor =  UIColor(hex: 0xF8F8F8)
            self.rightBarBtn.tintColor = (self.rightBarBtn.isEnabled == true) ?  UIColor(hex: 0xF8F8F8):UIColor.clear
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        guard let scrollView = self.segmentPaper.subviews[0] as? UIScrollView else {
            defaultNavBar()
            return
        }
        
        let offset = scrollView.contentOffset.y - self.pageOffset
        if (offset > HEIGHT_LENGTH + 64) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white.withAlphaComponent(1.0)]
            
        }else if(offset > HEIGHT_LENGTH){
            let alpha = (offset - HEIGHT_LENGTH) / 64
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white.withAlphaComponent(alpha)]

        }
        else{
            defaultNavBar()
        }
        
        if(self.pageOffset == 0){
            self.pageOffset = scrollView.contentOffset.y
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
//            let style = self.scrollContainer
//            if(style.contentOffset.y > HEIGHT_LENGTH){
//                return UIStatusBarStyle.default
//            }else{
//                return UIStatusBarStyle.lightContent
//            }
//        }else{
//            return UIStatusBarStyle.lightContent
//        }
        return UIStatusBarStyle.lightContent
    }

    func configCollectionBtn(){
        if let bookList = self.logic.headerData{
            if(bookList.subscribe?.boolValue == true){
                self.addCollectionLabel.text = "已收藏"
                self.addCollectionBtn.isSelected = true
            }else{
                self.addCollectionLabel.text = "收藏"
                self.addCollectionBtn.isSelected = false
            }
           
        }
    }
    
    func configDisscussBtn(){
        self.discuss.text = "讨论"
        if let count = self.logic.bfCount{
            if(count.intValue > 0){
                self.discuss.text = "讨论(" + count.stringValue + ")"
                
                //congfig badge
                let predicate = NSPredicate(format: "nid == \(self.logic.headerData!.nid!)")
                var listCD = BookListsCD.mr_findFirst(with: predicate, in: QWFileManager.qwContext())
                if (listCD == nil){//new one
                    listCD = BookListsCD.mr_createEntity(in: QWFileManager.qwContext())
                    listCD!.nid = self.logic.headerData!.nid!
                    
                    QWFileManager.qwContext().mr_saveToPersistentStore(completion: nil)
                    self.discussBtn.showIndicator(true)
                    return
                }
                
                if(listCD!.lastViewDate?.compare(self.logic.bfUpdate! as Date) == .orderedAscending || listCD?.lastViewDate == nil){
                    self.discussBtn.showIndicator(true)
                }
            }
            
        }
    }
    

/************************************/
/*Data Process*/
/************************************/
    override func getData() {
        if self.logic.isLoading {
            return
        }
        self.showLoading()
        //self.booksListCollectionView.emptyView.showError = false
        self.logic.bookList = nil
        //local data
        var step = 3
        if let extraData = self.extraData {
            let data = FavoriteBooksVO()
            self.logic.isLoading = true
            
            if (extraData.objectForCaseInsensitiveKey("id") != nil || extraData.objectForCaseInsensitiveKey("work_id") != nil) {
                if let nid = extraData.objectForCaseInsensitiveKey("id") as? NSNumber{
                    data.nid = nid
                    self.bookListID = nid
                }else if let sid = extraData.objectForCaseInsensitiveKey("id") as? NSString{
                    if let stid = sid.toNumberIfNeeded() {
                        data.nid = stid
                        self.bookListID = stid
                    }
                }
                
                
                self.midVC.listID = self.bookListID
                self.logic.getbookListDetailsWithCompleteBlock(listId: self.bookListID)  { [weak self] (aResponseObject, anError) in
                    if let weakSelf = self {
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            weakSelf.logic.headerData = nil
                        }else if(aResponseObject != nil){
                            weakSelf.configCollectionBtn()
                            weakSelf.updateWithStep(&step)
                        }
                    }
                }
                
                self.logic.getbookListWithCompleteBlock(listId: self.bookListID) {[weak self] (aResponseObject, anError) in
                    if let weakSelf = self {
                        weakSelf.hideLoading()
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            weakSelf.logic.bookList = nil
                        }
                        else if(aResponseObject != nil){
                            weakSelf.updateWithStep(&step)
                        }
                    }
                    
                }
                
                self.logic.getFaithPointBlock(listId: self.bookListID){ [weak self] (aResponseObject,anError) in
                    if let weakSelf = self {
                        weakSelf.hideLoading()
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            weakSelf.logic.faithPointsPage = nil
                        }
                        else if(aResponseObject != nil){
                            weakSelf.updateWithStep(&step)
                        }
                    }
                }
                
                
                self.logic.getAwardsLatestBlock(listId: self.bookListID){ [weak self] (aResponseObject,anError) in
                    if let weakSelf = self {
                        weakSelf.hideLoading()
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            weakSelf.logic.awardDymicPageVO = nil
                        }
                        else if(aResponseObject != nil){
                            weakSelf.updateWithStep(&step)
                        }
                    }
                }
                
                
            }
        }else{
            self.hideLoading()
        }
        
        
        if self.bookListID != nil{
            self.midVC.listID = self.bookListID
            self.logic.getbookListDetailsWithCompleteBlock(listId: self.bookListID)  { [weak self] (aResponseObject, anError) in
                if let weakSelf = self {
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        weakSelf.logic.headerData = nil
                    }else if(aResponseObject != nil){
                        weakSelf.configCollectionBtn()
                        weakSelf.updateWithStep(&step)
                    }
                }
            }
            
            self.logic.getbookListWithCompleteBlock(listId: self.bookListID) {[weak self] (aResponseObject, anError) in
                if let weakSelf = self {
                    weakSelf.hideLoading()
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        weakSelf.logic.bookList = nil
                    }
                    else if(aResponseObject != nil){
                        weakSelf.updateWithStep(&step)
                    }
                }
                
            }
            
            self.logic.getFaithPointBlock(listId: self.bookListID){ [weak self] (aResponseObject,anError) in
                if let weakSelf = self {
                    weakSelf.hideLoading()
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        weakSelf.logic.faithPointsPage = nil
                    }
                    else if(aResponseObject != nil){
                        weakSelf.updateWithStep(&step)
                    }
                }
            }
            
            
            self.logic.getAwardsLatestBlock(listId: self.bookListID){ [weak self] (aResponseObject,anError) in
                if let weakSelf = self {
                    weakSelf.hideLoading()
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        weakSelf.logic.awardDymicPageVO = nil
                    }
                    else if(aResponseObject != nil){
                        weakSelf.updateWithStep(&step)
                    }
                }
            }
        }
    }

    func getbf(){
        if let bf = self.logic.headerData?.bf_url{
            self.logic.getBFDetailsBlock(bf_url: bf as NSString){ [weak self] (aResponseObject,anError) in
                if let weakSelf = self {
                    weakSelf.hideLoading()
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    }
                    else if(aResponseObject != nil){
                        weakSelf.configDisscussBtn()
                    }
                }
            }
            
        }
    }
    
    func updateWithStep(_ step: inout Int) {
        step -= 1
        if self.logic.headerData != nil,self.logic.headerData?.work_count == 0{
            //self.booksListCollectionView.emptyView.showError = true
            self.title = self.logic.headerData?.title
            self.logic.isLoading = false
            //self.booksListCollectionView.reloadData()
            self.reloadHeadView()
        }
        else if(self.logic.headerData == nil){
            self.midVC.bodyTableView.emptyView.showError = false
            self.leftVC.bodyCollectionView.emptyView.showError = false
            return
        }
        else if step > 0 {
            return
        }
        self.logic.isLoading = false
        //self.booksListCollectionView.emptyView.showError = true
        self.title = self.logic.headerData?.title

        if (self.logic.headerData != nil){
            guard let isOwn = self.logic.headerData?.own else{
                return
            }
            self.rightBarBtn.isEnabled = isOwn.boolValue
            self.rightBarBtn.tintColor = (isOwn.boolValue == true) ? UIColor(hex: 0xF8F8F8): UIColor.clear
        }
        
        self.updateVCData()
        self.getbf()
        self.leftVC.bodyCollectionView.reloadData()
        self.midVC.bodyTableView.reloadData()
        self.reloadHeadView()
    }
    
    
    func updateVCData(){
        self.leftVC.cellData = self.logic.bookList
        self.leftVC.isOwn = self.rightBarBtn.isEnabled
        self.midVC.listID = self.bookListID
    }

    
}


/************************************/
/*Delaegat*/
/************************************/

extension QWBooksListDetails:MXSegmentedPagerDataSource, MXSegmentedPagerDelegate{
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        
        return 2
    }
    
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentTitles[index]
    }
    
    func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return 44
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        guard let vc = self.pages?[index] else {
            return UIViewController().view
        }
        self.currentVC = vc
        return vc.view
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        self.configNavigationBar()
    }
}

extension QWBooksListDetails:QWWordsInputPopDelegate{
    func didConfirmWordsInput(text:NSString){
//        if(text.length == 0){
//            text = ""
//        }
        self.showLoading()
        self.cellOpLogic.modifyMyrecommend(recommend: text, workId:self.popCell, { [weak self] (aResponseObject, anError) in
            
            if let weakSelf = self{
                weakSelf.hideLoading()
                
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                }else if let rep = aResponseObject as? [String: AnyObject]{
                    if let code = rep["code"] as? Int,code == 0{
                        weakSelf.showToast(withTitle: "修改成功", subtitle: nil, type: .alert)
                        weakSelf.getData()
                    }else{
                        if let msg = rep["msg"] as? String{
                            weakSelf.showToast(withTitle: msg, subtitle: nil, type: .alert)
                        }else{
                            weakSelf.showToast(withTitle: "修改失败", subtitle: nil, type: .alert)
                        }
                    }
                }
            }
        })
    }
}

extension QWBooksListDetails:QWBooksListDetailsHeaderDelegate{
    
    func didSelectedCellAtIndexPath(_ sender: UIButton?){
        self.showAll = !self.showAll;
        self.reloadHeadView()
        //self.booksListCollectionView.performBatchUpdates(
//            {
//                self.booksListCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
//        }, completion: nil)
    }

}


extension QWBooksListDetails:QWFavoriteBooksDelegate{
    func getMore() {
        self.logic.getbookListWithCompleteBlock(listId: self.bookListID) {[weak self] (aResponseObject, anError) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                }
                else if(aResponseObject != nil){
                    weakSelf.leftVC.bodyCollectionView.reloadData()
                }
            }
            
        }
    }
    
    func cellPopAction(doAction:BooklistsWorkActionType,workId: NSNumber?, data: BooksListVO?) {
        if (data == nil || workId == nil){
            return
        }

        self.popCell = workId
        switch doAction {
        case .Update:
            self.pop?.showWithData(content:data!.recommend)
        case .Delete:
            let alert = UIAlertView()
            alert.bk_init(withTitle: "删除作品", message: "")
            alert.bk_addButton(withTitle: "取消") {

            }
            alert.bk_addButton(withTitle: "确定") { [weak self]() -> Void in
                if let weakSelf = self {
                    weakSelf.cellOpLogic.deleteBookFormList(workId:weakSelf.popCell!, ({ [weak weakSelf](aResponseObject, anError) in
                        if let weakSelf = weakSelf {
                            if anError == nil {
                                if let aResponseObject = aResponseObject as? [String: AnyObject] {
                                    if let code = aResponseObject["code"] as? NSNumber , code.isEqual(to: NSNumber(value: 0)) {

                                        weakSelf.showToast(withTitle: "删除成功", subtitle: nil, type: ToastType.alert)
                                        self?.getData()
                                    }
                                    else {
                                        if let message = aResponseObject["msg"] as? String {
                                            weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                                        }
                                        else {
                                            weakSelf.showToast(withTitle: "删除失败 ", subtitle: nil, type: ToastType.alert)
                                        }
                                    }
                                }
                            }
                            else {
                                if let anError = anError as NSError? {
                                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: ToastType.error)
                                }

                            }
                            weakSelf.hideLoading()

                        }
                    }))
                }
            }
            alert.show()

        default:
            break
        }

    }
}
extension QWBooksListDetails:UIScrollViewDelegate{
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.configNavigationBar();
        }
}


