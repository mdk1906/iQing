//
//  QWWalletBillVC.swift
//  Qingwen
//
//  Created by Aimy on 2/25/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWWalletBillVC: QWBaseListVC {

    var user_url: String?
    var button1:UIButton?
    var month:String?
    var year:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()

    override var listVO: PageVO? {
        return self.logic.walletBill
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = 60
        self.tableView.emptyView.errorMsg = "还没有发现账单哦"
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
        month = String(format:"%d",comps.month! - 1)
        year = String(format:"%d",comps.year!)
        self.getData()
        self.createTimeUI()
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

        self.logic.walletBill = nil;
        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getWalletBillWithCompleteBlock (month,year){ [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.hideLoading()
            }
        }
        
    }
    func createTimeUI()  {
        button1 = UIButton(frame:CGRect(x:0, y:0, width:82, height:20))
        let title = year! + "年" + month! + "月"
        button1?.setTitle(title, for: .normal)
        button1?.tag = 10000
        button1?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button1?.setTitleColor(UIColor(hex: 0x474747), for: .normal)
        button1?.addTarget(self,action:#selector(tapped1),for:.touchUpInside)
        let barButton1 = UIBarButtonItem(customView: button1!)
        
        //设置按钮
        let button2 = UIButton(frame:CGRect(x:0, y:0, width:12, height:18))
        button2.setImage(UIImage(named: "iOS箭头"), for: .normal)
        button2.addTarget(self,action:#selector(tapped1),for:.touchUpInside)
        let barButton2 = UIBarButtonItem(customView: button2)
        
        //按钮间的空隙
        let gap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                  action: nil)
        gap.width = 3
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                     action: nil)
        spacer.width = -5
        
        //设置按钮（注意顺序）
        self.navigationItem.rightBarButtonItems = [spacer,barButton2,gap,barButton1]
        
    }
    func tapped1()  {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
        comps.month = comps.month! - 1
        let date = calendar.date(from: comps)
        let datePicker = YLDatePicker(currentDate: nil, minLimitDate: nil, maxLimitDate: date, datePickerType: .YM) { [weak self] (date) in
//            let btn = self?.view.viewWithTag(10000) as! UIButton
            let calendar: Calendar = Calendar(identifier: .gregorian)
            var comps: DateComponents = DateComponents()
            comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: date)
            var comps2: DateComponents = DateComponents()
            comps2 = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
            
            if comps.month == comps2.month{
                comps.month = 1
            }
            let date2 = calendar.date(from: comps)
            self?.button1?.setTitle(date2?.getString(format: "yyyy年MM月"), for: .normal)
            print(date2?.getString(format: "yyyy"))
            print(date2?.getString(format: "MM"))
            self?.year = date2?.getString(format: "yyyy")
            self?.month = date2?.getString(format: "MM")
            self?.tableView.emptyView.errorMsg = "还没有发现账单哦"
            self?.getData()
            //            self?.navigationItem.title = date.getString(format: "yyyy-MM")
        }
        datePicker.show()
        
    }
    
//    override func getMoreData() {
//
//        if self.logic.isLoading {
//            return
//        }
//
//        self.logic.isLoading = true
//
//        self.tableView.emptyView.showError = false
//        self.collectionView.emptyView.showError = false
//
//        self.logic.getWalletBillWithCompleteBlock { [weak self] (aResponseObject, anError) -> Void in
//            if let weakSelf = self {
//                weakSelf.tableView.reloadData()
//                weakSelf.tableView.emptyView.showError = true
//                weakSelf.logic.isLoading = false
//                weakSelf.tableView.tableFooterView = nil
//            }
//        }
//    }
    
}

extension QWWalletBillVC {
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).row] as? WalletBillVO {
            let cell = cell as! QWWalletBillTVCell
            cell.updateWithBillVO(vo)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        didSelectedCellAtIndexPath(indexPath)
////        self.createDetailView(index: indexPath.row)
//        let vo = self.listVO?.results[indexPath.row] as? WalletBillVO
//
//        let alertController = UIAlertController(title: vo?.reason!,
//                                                message: nil, preferredStyle: .alert)
//        //显示提示框
//        self.present(alertController, animated: true, completion: nil)
//        //两秒钟后自动消失
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            self.presentedViewController?.dismiss(animated: false, completion: nil)
//        }
//    }
}

