//
//  QWHeavyBillVC.swift
//  Qingwen
//
//  Created by Aimy on 3/21/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
import StoreKit

class QWHeavyBillVC: QWBaseListVC {

    var user_url: String?
    @IBOutlet var emptyView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    lazy var logic: QWPayLogic = {
        return QWPayLogic(operationManager: self.operationManager)
    }()

    override var listVO: PageVO? {
        return self.logic.goldBill
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emptyView.frame = self.view.bounds
        self.view.addSubview(self.emptyView)
        self.emptyView.isHidden = true

        self.tableView.rowHeight = 60
        self.getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }

    override func update() {
        if let _ = self.listVO {
            return
        }

        self.getData()
    }

    override func getData() {

        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.logic.goldBill = nil;
        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getHeavyWalletBillWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.emptyView.isHidden = weakSelf.listVO?.results.count != 0
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.hideLoading()
            }
        }
    }

    override func getMoreData() {

        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getHeavyWalletBillWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.tableView.tableFooterView = nil
            }
        }
    }
    
    @IBAction func onPressedChargeBtn(_ sender: AnyObject) {
        self.showLoading()
        self.toIAP()

    }

    func showMenu() {

        self.toIAP()
    }

    func toIAP() {
        if SKPaymentQueue.canMakePayments() == false {
            self.showToast(withTitle: "该设备没有支付功能,无法充值", subtitle: nil, type: .alert)
            return
        }
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge", andParams: nil))
    }

//    func to3rd() {
//        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge3", andParams: nil))
//    }
}

extension QWHeavyBillVC {
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).row] as? GoldBillVO {
            let cell = cell as! QWHeavyBillTVCell
            cell.updateWithGoldBillVO(vo)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x505050)
        if let gold = QWGlobalValue.sharedInstance().user?.gold {
            label.text = "  我的重石: \(gold)"
        }
        else {
            label.text = "  我的重石: 0"
        }
        return label
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectedCellAtIndexPath(indexPath)
//        self.createDetailView(index: indexPath.row)
        let vo = self.listVO?.results[indexPath.row] as? GoldBillVO
        let alertController = UIAlertController(title: vo?.reason!,
                                                message: nil, preferredStyle: .alert)
        //显示提示框
        self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
    }
    }
    func createDetailView(index:Int)  {
        let backView = UIView.init()
        backView.frame = CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        backView.backgroundColor = UIColor.black
        backView.tag = 100
        backView.alpha = 0.7
        self.view.addSubview(backView)
        let vo = self.listVO?.results[index] as? GoldBillVO
        
        let bigView = UIView.init()
        bigView.frame = CGRect(x:38,y:211,width:UIScreen.main.bounds.width-76,height:246)
        bigView.backgroundColor = UIColor.colorF8()
        bigView.layer.borderColor = UIColor.colorFE().cgColor
        bigView.layer.borderWidth = 1
        bigView.tag = 200
        self.view.addSubview(bigView)
        
        let titleLab = UILabel.init()
        titleLab.frame = CGRect(x:20,y:20,width:self.getLabWidth(labelStr:(vo?.reason!)!,font:UIFont.systemFont(ofSize: 16),height:16),height:16)
        let index = (vo?.reason!)?.index(((vo?.reason!)?.startIndex)!, offsetBy:4)
        titleLab.text = (vo?.reason!)?.substring(to: index!)
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.systemFont(ofSize: 16)
        bigView.addSubview(titleLab)
        
        let moneyLab = UILabel.init()
        moneyLab.frame = CGRect(x:UIScreen.main.bounds.width-76-20-100,y:20,width:100,height:16)
        if let gold = vo?.gold {
            if gold.intValue > 0 {
                moneyLab.text = "+\(gold)重石"
            }
            else {
                moneyLab.text = "\(gold)重石"
            }
        }
        else {
            moneyLab.text = "0重石"
        }
        moneyLab.textAlignment = .right
        moneyLab.font = UIFont.systemFont(ofSize: 16)
        moneyLab.textColor = UIColor.black
        bigView.addSubview(moneyLab)
        
        let contentLab = UILabel.init()
        contentLab.frame = CGRect(x:20,y:(titleLab.frame).maxY+20,width:UIScreen.main.bounds.width-76-40,height:self.getLabHeight(labelStr:(vo?.reason!)!,font:UIFont.systemFont(ofSize: 12),width:UIScreen.main.bounds.width-76-40))
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.textColor = UIColor(hex: 0x888888)
        contentLab.numberOfLines = 0
        contentLab.text = vo?.reason!
        bigView.addSubview(contentLab)
        
        let timeLab = UILabel.init()
        timeLab.frame = CGRect(x:20,y:(contentLab.frame).maxY+20,width:UIScreen.main.bounds.width-76-40,height:12)
        timeLab.font = UIFont.systemFont(ofSize: 12)
        timeLab.textColor = UIColor(hex: 0x888888)
        timeLab.numberOfLines = 0
        timeLab.text = "时间：" + QWHelper.fullDate(toString: vo?.updated_time)
        bigView.addSubview(timeLab)
        
        let sureBtn = UIButton.init()
        sureBtn.frame = CGRect(x:(UIScreen.main.bounds.width-76-100)/2,y:246-34-18,width:100,height:34)
        sureBtn.backgroundColor = UIColor(hex: 0xFC9B96)
        sureBtn.layer.cornerRadius = 3
        sureBtn.layer.masksToBounds = true
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        sureBtn.setTitle("确认", for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.setTitleColor(UIColor.white, for: .normal)
        bigView.addSubview(sureBtn)
        
    }
    func sureBtnClick()  {
        let backView = self.view.viewWithTag(100) as UIView!
        backView?.removeFromSuperview()
        
        let bigView = self.view.viewWithTag(200) as UIView!
        bigView?.removeFromSuperview()
    }
}
