//
//  QWMyCenterVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/24.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit


extension QWMyCenterVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWMyCenter"
        QWRouter.sharedInstance().register(vo, withKey: "mycenter")
    }
    
}

class QWMyCenterVC: QWBaseVC {
    enum QWMyCenterType: Int {
        case Head = 0             //user
        case Mission                //任务成就勋章
        case Dymic              //我的消息
        case Props                //我的道具
        case Personal             //个人中心
        case Count
        
        case None = 999
        init(section: Int) {
            if let type = QWMyCenterType(rawValue: section) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    
    enum QWMyCenterPropsType: Int {
        case PropsCharge = 0//信仰充值
        case MyVip
        case PropsCount
        
        case None = 999
        init(indexPath: NSIndexPath) {
            if let type = QWMyCenterPropsType(rawValue: indexPath.row) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    enum QWMyCenterMissionType: Int {
        case MyMission
        case MyAchievement
        case MyMedal
        case None = 999
        init(indexPath: NSIndexPath) {
            if let type = QWMyCenterMissionType(rawValue: indexPath.row) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    
    enum QWMyCenterDymicType: Int {
        case PersonalAttention
        //        case PersonalFans
        case PersonalContribution
        case PersonalComments
        case None = 999
        init(indexPath: NSIndexPath) {
            if let type = QWMyCenterDymicType(rawValue: indexPath.row) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    
    enum QWMyCenterPersonalType: Int {
        
        case PersonalMessage = 0  //动态
        case PropsWallet          //我的钱包
        
        
        case PersonalHistory  //历史记录
        //        case PersonalDownload     //下载管理
        case PersonalSetting      //应用设置
        case PersonalCount
        
        case None = 999
        
        case PropsShop            //道具商城 取消
        
        init(indexPath: NSIndexPath) {
            if let type = QWMyCenterPersonalType(rawValue: indexPath.row) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    
    enum QWMyCenterPersonalTypeForVistor: Int {
        case PersonalMessage = 0  //动态
        case PropsWallet          //我的钱包
        case PersonalHistory  //历史记录
        //        case PersonalDownload     //下载管理
        case PersonalSetting          //应用设置
        case PersonalCount
        
        case None = 999
        init(indexPath: NSIndexPath) {
            if let type = QWMyCenterPersonalTypeForVistor(rawValue: indexPath.row) {
                self = type
            }
            else {
                self = .None
            }
        }
    }
    
    @IBOutlet var collectionView: QWCollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    
    var successView: QWSummonsSuccessView?
    
    lazy var logic: QWMyCenterLogic = {
        return QWMyCenterLogic(operationManager: self.operationManager)
    }()
    
    override func resize(_ size: CGSize) {
        self.layout?.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        //        self.layout.minimumLineSpacing = 0.5
        self.layout.minimumInteritemSpacing = 0
        
        self.collectionView.backgroundColor = UIColor(hex: 0xf4f4f4)
        
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        
        self.observeNotification("UNREAD_CHANGED") { [weak self](tempSelf, notification) in
            guard let _ = notification else {
                return
            }
            if let weakSelf = self {
                weakSelf.collectionView.reloadData()
            }
        }
        #if DEBUG
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ip", style: .plain, target: self, action: #selector(onPressedChangeServerBarBtn(_:)))
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard QWGlobalValue.sharedInstance().isLogin() else {
            return
        }
        
        if let user = QWGlobalValue.sharedInstance().user , user.sex == nil{
            if let profile = user.profile_url , profile.length > 0 {
                self.showLoading()
                self.update()
            }else {
                QWGlobalValue.sharedInstance().clear()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LOGIN_STATE_CHANGED), object: nil)
                self.collectionView.reloadData()
                self.showToast(withTitle: "请重新登录", subtitle: nil, type: .alert)
                return
            }
        }else {
            self.update()
        }
        
        QWGlobalValue.sharedInstance().getUnread()
    }
    override func update() {
        self.logic.getUserInfo { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                weakSelf.collectionView.reloadData()
            }
        }
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
    }
    @IBAction func onPressedMyAttention(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWAttention", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onPressedFollowBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWAttention", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "fans")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onPressedContributionBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWContribution", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onPressedChangeServerBarBtn(_ sender: UIButton) {
        let vc = QWTestEnvChangeTVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:UICollectionViewDataSource
extension QWMyCenterVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return QWMyCenterType.Count.rawValue
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = QWMyCenterType(section: section)
        switch sectionType {
        case .Head:
            return 1
        case .Personal:
            if(QWGlobalValue.sharedInstance().isLogin()){
                return QWMyCenterPersonalType.PersonalCount.rawValue
            }else{
                return QWMyCenterPersonalTypeForVistor.PersonalCount.rawValue
            }
            
        case .Props:
            if QWGlobalValue.sharedInstance().isLogin(){
                
                    return 2;
                
            }else{
                return 1;
            }
            
        case .Dymic:
            return 3
        case .Mission:
            return 3
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! QWMyCenterHeadCRView
            switch QWMyCenterType(section: indexPath.section) {
            case .Personal:
                view.titleLelbel.text = "个人中心"
            default:
                view.titleLelbel.isHidden = true
            }
            view.backgroundColor = UIColor.white
            return view
        }
        else  {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath as IndexPath)
            view.backgroundColor = UIColor(hex: 0xf4f4f4)
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let centerType = QWMyCenterType(section: indexPath.section)
        switch centerType {
        case .Head:
            return CGSize(width:QWSize.screenWidth(), height:100)
        case .Dymic, .Props, .Mission:
            return CGSize(width:QWSize.screenWidth(), height:44)
        case .Personal:
            let width = (QWSize.screenWidth() - 6) / 4
            return CGSize(width:width, height:width)
        default:
            return CGSize.zero
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let type = QWMyCenterType(section: section)
        switch type {
        case .Head:
            return CGSize.zero
        case .Personal:
            return CGSize(width:QWSize.screenWidth(), height:34)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let type = QWMyCenterType(section: section)
        if type == .Personal {
            return CGSize.zero
        }
        return CGSize(width:QWSize.screenWidth(), height:5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let type = QWMyCenterType(section: section)
        switch type {
        case .Dymic, .Mission:
            return PX1_LINE * 3
        case .Personal:
            return 2
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let type = QWMyCenterType(section: section)
        switch type {
        case .Personal:
            return UIEdgeInsetsMake(2, 0, 0, 0)
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = QWMyCenterType(section: indexPath.section)
        switch sectionType {
        case .Head:
            if QWGlobalValue.sharedInstance().isLogin() {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user", for: indexPath) as! QWMyCenterHeadCVCell
                cell.delegate = self
                cell.update()
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userlogin", for: indexPath)
                return cell
            }
        case .Mission:
            let sectionType = QWMyCenterMissionType(indexPath: indexPath as NSIndexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvcell", for: indexPath)
            
            let iconImageView = cell.viewWithTag(101) as! UIImageView
            let titleLabel = cell.viewWithTag(102) as! UILabel
            let subTitleLabel = cell.viewWithTag(103) as! UILabel
            
            switch sectionType {
            case .MyMission:
                iconImageView.image = UIImage(named: "任务")
                titleLabel.text = "日常任务"
                if let tasks = QWGlobalValue.sharedInstance().user?.tasks{
                    subTitleLabel.text = "\(tasks)"
                }else {
                    subTitleLabel.text = ""
                }
                
            case .MyAchievement:
                iconImageView.image = UIImage(named: "成就")
                titleLabel.text = "光辉成就"
                if let archieve = QWGlobalValue.sharedInstance().user?.archieve {
                    subTitleLabel.text = "\(archieve)"
                }else {
                    subTitleLabel.text = ""
                }
            case .MyMedal:
                iconImageView.image = UIImage(named: "勋章")
                titleLabel.text = "我的勋章"
                if let medals = QWGlobalValue.sharedInstance().user?.medals{
                    subTitleLabel.text = "\(medals)"
                }else {
                    subTitleLabel.text = ""
                }
            default:
                break
            }
            return cell
        case .Dymic:
            let sectionType = QWMyCenterDymicType(indexPath: indexPath as NSIndexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvcell", for: indexPath)
            
            let iconImageView = cell.viewWithTag(101) as! UIImageView
            let titleLabel = cell.viewWithTag(102) as! UILabel
            let subTitleLabel = cell.viewWithTag(103) as! UILabel
            
            switch sectionType {
            case .PersonalAttention:
                iconImageView.image = UIImage(named: "mycenter_icon_fans")
                titleLabel.text = "我的关注"
                if let follow_count = QWGlobalValue.sharedInstance().user?.follow_count ,let fans_count = QWGlobalValue.sharedInstance().user?.fans_count{
                    let folow :Int = Int(follow_count)
                    let fans :Int = Int(fans_count)
                    
                    subTitleLabel.text = "\(folow + fans )"
                }else {
                    subTitleLabel.text = ""
                }
                
                //            case .PersonalFans:
                //                iconImageView.image = UIImage(named: "mycenter_icon_fans")
                //                titleLabel.text = "关注我的"
                //                if let fans_count = QWGlobalValue.sharedInstance().user?.fans_count {
                //                    subTitleLabel.text = "\(fans_count)"
                //                }else {
                //                    subTitleLabel.text = ""
            //                }
            case .PersonalContribution:
                iconImageView.image = UIImage(named: "mycenter_icon_contribution")
                titleLabel.text = "我的投稿"
                if let work_count = QWGlobalValue.sharedInstance().user?.work_count{
                    subTitleLabel.text = "\(work_count)"
                }else {
                    subTitleLabel.text = ""
                }
            case .PersonalComments:
                iconImageView.image = UIImage(named: "评论")
                titleLabel.text = "我的评论"
                
                if let work_count = QWGlobalValue.sharedInstance().user?.comments {
                    subTitleLabel.text = "\(work_count)"
                }else {
                    subTitleLabel.text = ""
                }
            default:
                break
            }
            return cell
            
        case .Props:
            let sectionType = QWMyCenterPropsType(indexPath: indexPath as NSIndexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvcell", for: indexPath)
            
            let iconImageView = cell.viewWithTag(101) as! UIImageView
            let titleLabel = cell.viewWithTag(102) as! UILabel
            let subTitleLabel = cell.viewWithTag(103) as! UILabel
            switch sectionType {
            case .MyVip:
                iconImageView.image = UIImage(named: "vip")
                if let vip_date = QWGlobalValue.sharedInstance().user?.vip_date {
                    if vip_date == ""{
                        titleLabel.text = "我的VIP（您还不是VIP）"
                        subTitleLabel.text = "充值"
                    }
                    else{
                        titleLabel.text = "我的VIP（还剩" + "\(vip_date)" + "天）"
                        subTitleLabel.text = "续费"
                    }
                    
                }
                else{
                    titleLabel.text = "我的VIP（您还不是VIP）"
                    subTitleLabel.text = "充值"
                }
            case .PropsCharge:
                iconImageView.image = UIImage(named: "mycenter_icon_gold")
                titleLabel.text = "重石（充值）"
                if let gold = QWGlobalValue.sharedInstance().user?.gold {
                    let roundUp = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers,
                                                         scale: 2,
                                                         raiseOnExactness: false,
                                                         raiseOnOverflow: false,
                                                         raiseOnUnderflow: false,
                                                         raiseOnDivideByZero: true)
                    
                    let subtotal = NSDecimalNumber(string:gold.stringValue)
                    let discount = NSDecimalNumber(string:"0")
                    
                    // 加 保留 2 位小数
                    let total = subtotal.adding(discount, withBehavior: roundUp)
                    
                    
                    subTitleLabel.text = "\(total)"
                }else {
                    subTitleLabel.text = ""
                }
                
            default:
                break;
            }
            
            return cell
        case .Personal:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWMyCenterCVCell
            
            
            if QWGlobalValue.sharedInstance().isLogin() {
                let personalType = QWMyCenterPersonalType(indexPath: indexPath as NSIndexPath)
                switch personalType {
                case .PersonalMessage:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_message")
                    cell.iconLabel.text = "消息"
                    cell.countBtn.isHidden = true
                    cell.countBtn.setBackgroundImage(UIImage(named: "mycenter_message_count"), for: .normal)
                    if let unread = QWGlobalValue.sharedInstance().unread , unread.intValue > 0{
                        if unread.intValue > 99 {
                            cell.countBtn.setTitle("99", for: .normal)
                        }else {
                            cell.countBtn.setTitle("\(unread)", for: .normal)
                        }
                        cell.countBtn.isHidden = false
                    } else {
                        cell.countBtn.isHidden = true
                    }
                case .PropsWallet:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_wallet")
                    cell.iconLabel.text = "钱包"
                    cell.countBtn.isHidden = true
                case .PropsShop:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_shop")
                    cell.iconLabel.text = "道具"
                    cell.countBtn.isHidden = true
                case .PersonalHistory:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_history")
                    cell.iconLabel.text = "历史记录"
                    cell.countBtn.isHidden = true
                    //                                    case .PersonalDownload:
                    //                                        cell.iconMessage.image = UIImage(named: "mycenter_icon_download")
                    //                                        cell.iconLabel.text = "下载管理"
                //                                    cell.countBtn.isHidden = true
                case .PersonalSetting:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_setting")
                    cell.iconLabel.text = "应用设置"
                    cell.countBtn.isHidden = true
                default:
                    cell.backgroundColor = UIColor.white
                    cell.iconMessage.isHidden = true
                    cell.countBtn.isHidden = true
                    cell.iconLabel.isHidden = true
                }
            }else{
                let vistorType = QWMyCenterPersonalTypeForVistor(indexPath: indexPath as NSIndexPath)
                switch vistorType {
                case .PersonalMessage:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_message")
                    cell.iconLabel.text = "消息"
                    cell.countBtn.isHidden = true
                    cell.countBtn.setBackgroundImage(UIImage(named: "mycenter_message_count"), for: .normal)
                    if let unread = QWGlobalValue.sharedInstance().unread , unread.intValue > 0{
                        if unread.intValue > 99 {
                            cell.countBtn.setTitle("99", for: .normal)
                        }else {
                            cell.countBtn.setTitle("\(unread)", for: .normal)
                        }
                        cell.countBtn.isHidden = false
                    } else {
                        cell.countBtn.isHidden = true
                    }
                case .PropsWallet:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_wallet")
                    cell.iconLabel.text = "钱包"
                    cell.countBtn.isHidden = true
                case .PersonalHistory:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_history")
                    cell.iconLabel.text = "历史记录"
                    cell.countBtn.isHidden = true
                    //                case .PersonalDownload:
                    //                    cell.iconMessage.image = UIImage(named: "mycenter_icon_download")
                    //                    cell.iconLabel.text = "下载管理"
                //                    cell.countBtn.isHidden = true
                case .PersonalSetting:
                    cell.iconMessage.image = UIImage(named: "mycenter_icon_setting")
                    cell.iconLabel.text = "应用设置"
                    cell.countBtn.isHidden = true
                default:
                    cell.backgroundColor = UIColor.white
                    cell.iconMessage.isHidden = true
                    cell.countBtn.isHidden = true
                    cell.iconLabel.isHidden = true
                }
            }
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerType = QWMyCenterType(section: indexPath.section)
        switch centerType {
        case .Head:
            if QWGlobalValue.sharedInstance().isLogin() {
                let sb = UIStoryboard(name: "QWUser", bundle: nil)
                let vc = sb.instantiateInitialViewController()!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                QWRouter.sharedInstance().routerToLogin()
            }
        case .Mission:
            guard QWGlobalValue.sharedInstance().isLogin() else {
                QWRouter.sharedInstance().routerToLogin()
                return
            }
            let dymicType = QWMyCenterMissionType(indexPath: indexPath as NSIndexPath)
            switch dymicType {
            case .MyMission:
                let vc = QWMyMissionVC()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .MyAchievement:
                let vc = QWMyAchievementVC()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .MyMedal:
                let vc = QWMymedelVC()
                vc.avater =  QWGlobalValue.sharedInstance().user?.avatar
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case .Dymic:
            guard QWGlobalValue.sharedInstance().isLogin() else {
                QWRouter.sharedInstance().routerToLogin()
                return
            }
            let dymicType = QWMyCenterDymicType(indexPath: indexPath as NSIndexPath)
            switch dymicType {
            case .PersonalAttention:
                //                let sb = UIStoryboard(name: "QWAttention", bundle: nil)
                //                let vc = sb.instantiateInitialViewController()!
                //                self.navigationController?.pushViewController(vc, animated: true)
                let sb = UIStoryboard(name: "QWAttention", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "MyAttentionPage") as! QWMyAttentionPageVC
                self.navigationController?.pushViewController(vc, animated: true)
            case .PersonalContribution:
                let sb = UIStoryboard(name: "QWContribution", bundle: nil)
                let vc = sb.instantiateInitialViewController()!
                self.navigationController?.pushViewController(vc, animated: true)
            case .PersonalComments:
                let sb = UIStoryboard(name: "MyComments", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "MyCommentsPage") as! QWMyCommentsPageVC
                let userId :String = QWGlobalValue.sharedInstance().nid!.stringValue
                vc.uid = userId
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case .Personal:
            if QWGlobalValue.sharedInstance().isLogin() {
                let personalType = QWMyCenterPersonalType(indexPath: indexPath as NSIndexPath)
                switch personalType {
                case .PersonalMessage:
                    let sb = UIStoryboard(name: "QWMessageCenter", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .PropsWallet:
                    let sb = UIStoryboard(name: "QWWallet", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .PropsShop:
                    let sb = UIStoryboard(name: "QWShop", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .PersonalHistory:
                    let sb = UIStoryboard(name: "QWHistory", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "HistoryPage") as! QWHistoryPageVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    //                case .PersonalDownload:
                    //                    let sb = UIStoryboard(name: "QWDownload", bundle: nil)
                    //                    let vc = sb.instantiateInitialViewController()!
                //                    self.navigationController?.pushViewController(vc, animated: true)
                case .PersonalSetting:
                    let sb = UIStoryboard(name: "QWMyCenter", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "setting")
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }else{
                
                let vistorType = QWMyCenterPersonalTypeForVistor(indexPath: indexPath as NSIndexPath)
                if (vistorType == .PersonalMessage || vistorType == .PropsWallet || vistorType == .PersonalHistory) {
                    QWRouter.sharedInstance().routerToLogin()
                    return
                }
                
                switch vistorType {
                case .PersonalMessage:
                    let sb = UIStoryboard(name: "QWMessageCenter", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .PropsWallet:
                    let sb = UIStoryboard(name: "QWWallet", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .PersonalHistory:
                    let sb = UIStoryboard(name: "QWHistory", bundle: nil)
                    let vc = sb.instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                    //                case .PersonalDownload:
                    //                    let sb = UIStoryboard(name: "QWDownload", bundle: nil)
                    //                    let vc = sb.instantiateInitialViewController()!
                //                    self.navigationController?.pushViewController(vc, animated: true)
                case .PersonalSetting:
                    let sb = UIStoryboard(name: "QWMyCenter", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "setting")
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                    
                }
            }
            
        case .Props:
            guard QWGlobalValue.sharedInstance().isLogin() else {
                QWRouter.sharedInstance().routerToLogin()
                return
            }
            let propsType = QWMyCenterPropsType(indexPath:indexPath as NSIndexPath)
            switch propsType {
            case .MyVip:
                let vc = QWMyVIPVC()
                self.navigationController?.pushViewController(vc, animated: true)
            case .PropsCharge:
                let charge = QWCharge()
                charge.doCharge()
                
            default:
                break
            }
        default:
            break
        }
    }
}

extension QWMyCenterVC: QWMyCenterHeadCVCellDelegate {
    
    func headCell(cell: QWMyCenterHeadCVCell, sender: AnyObject) {
        //
        //        self.successView = QWSummonsSuccessView.createWithNib()
        //        self.successView!.updateWithCount(40, andCheckInCount: 5)
        //        self.successView!.frame = self.tabBarController!.view.bounds
        //        self.tabBarController?.view .addSubview(self.successView!)
        let vc = QWMyMissionVC()
        self.navigationController?.pushViewController(vc, animated: true)
        self.showLoading()
        self.logic.checkin { [weak self](aResponseObject, anError) in
            if let weakSelf = self {
                if anError == nil {
                    if let aResponseObject = aResponseObject as? [String: AnyObject] {
                        if let code = aResponseObject["code"] as? NSNumber, code.isEqual(to: NSNumber(value: 0)) {
                            let checkIntCount = aResponseObject.objectForCaseInsensitiveKey("check_in_count") as? NSNumber
                            let check_in_u_count = aResponseObject.objectForCaseInsensitiveKey("check_in_u_count") as? NSNumber
                            QWGlobalValue.sharedInstance().user?.check_in_date = NSDate() as Date
                            QWGlobalValue.sharedInstance().user?.check_in_count = checkIntCount
                            QWGlobalValue.sharedInstance().user?.check_in_u_count = check_in_u_count
                            QWGlobalValue.sharedInstance().save()
                            
                            weakSelf.successView = QWSummonsSuccessView.createWithNib()
                            weakSelf.successView!.frame = weakSelf.tabBarController!.view.bounds
                            if let count = aResponseObject.objectForCaseInsensitiveKey("coin") as? NSNumber, let checkIntCount = aResponseObject.objectForCaseInsensitiveKey("check_in_u_count") as? NSNumber ,let dict = aResponseObject.objectForCaseInsensitiveKey("text") as? Dictionary<String, String> {
                                weakSelf.successView!.updateWithCount(count, andCheckInCount: checkIntCount ,andData: dict)
                                
                            }else {
                                let dict = aResponseObject.objectForCaseInsensitiveKey("text") as? Dictionary<String, String>
                                weakSelf.successView!.updateWithCount(0, andCheckInCount: 0,andData: dict!)
                            }
                            weakSelf.tabBarController?.view .addSubview(weakSelf.successView!)
                            weakSelf.update()
                            weakSelf.collectionView.reloadData()
                        }
                        else {
                            if let message = aResponseObject["data"] as? String {
                                weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                            }
                            else {
                                weakSelf.showToast(withTitle: "签到失败", subtitle: nil, type: ToastType.alert)
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
        }
    }
}
