//
//  QWBillVC.swift
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBillVC: QWBaseListVC {

    var user_url: String?
    var billType: QWChargeLogic.BillType = .income

    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()

    override var listVO: PageVO? {
        return self.logic.bill
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = 60
        if #available(iOS 11.0, *) {
            let constant = self.view.safeAreaInsets.top;
            self.tableView.contentInset = UIEdgeInsetsMake(constant, 0, 0, 0)
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }

        self.getData()
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

        self.logic.bill = nil;
        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false
        self.title = "我的轻石"
        self.logic.getBillWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
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

        self.logic.getBillWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.tableView.tableFooterView = nil
            }
        }
    }
}

extension QWBillVC {
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).row] as? BillVO {
            let cell = cell as! QWBillTVCell
            cell.updateWithBillVO(vo)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x505050)
        if let coin = QWGlobalValue.sharedInstance().user?.coin {
            label.text = "  我的轻石: \(coin)"
        }
        else {
            label.text = "  我的轻石: 0"
        }
        return label
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectedCellAtIndexPath(indexPath)
//        self.createDetailView(index: indexPath.row)
        let vo = self.listVO?.results[indexPath.row] as? BillVO

        let alertController = UIAlertController(title: vo?.detail!,
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
        let vo = self.listVO?.results[index] as? BillVO
        
        let bigView = UIView.init()
        bigView.frame = CGRect(x:38,y:211,width:UIScreen.main.bounds.width-76,height:246)
        bigView.backgroundColor = UIColor.colorF8()
        bigView.layer.borderColor = UIColor.colorFE().cgColor
        bigView.layer.borderWidth = 1
        bigView.tag = 200
        self.view.addSubview(bigView)
        
        let titleLab = UILabel.init()
        titleLab.frame = CGRect(x:20,y:20,width:self.getLabWidth(labelStr:(vo?.detail!)!,font:UIFont.systemFont(ofSize: 16),height:16),height:16)
        let index = (vo?.detail!)?.index(((vo?.detail!)?.startIndex)!, offsetBy:4)
        titleLab.text = (vo?.detail!)?.substring(to: index!)
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.systemFont(ofSize: 16)
        bigView.addSubview(titleLab)
        
        let moneyLab = UILabel.init()
        moneyLab.frame = CGRect(x:UIScreen.main.bounds.width-76-20-100,y:20,width:100,height:16)
        if let coin = vo?.coin {
            if vo?.receiver == QWGlobalValue.sharedInstance().user?.nid {
                moneyLab.text = "+\(coin)轻石"
            }
            else {
                moneyLab.text = "-\(coin)轻石"
            }
        }
        else {
            moneyLab.text = "0轻石"
        }
        moneyLab.textAlignment = .right
        moneyLab.font = UIFont.systemFont(ofSize: 16)
        moneyLab.textColor = UIColor.black
        bigView.addSubview(moneyLab)
        
        let contentLab = UILabel.init()
        contentLab.frame = CGRect(x:20,y:(titleLab.frame).maxY+20,width:UIScreen.main.bounds.width-76-40,height:self.getLabHeight(labelStr:(vo?.detail!)!,font:UIFont.systemFont(ofSize: 12),width:UIScreen.main.bounds.width-76-40))
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.textColor = UIColor(hex: 0x888888)
        contentLab.numberOfLines = 0
        contentLab.text = vo?.detail!
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

