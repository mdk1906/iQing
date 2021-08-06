//
//  QWWalletVC.swift
//  Qingwen
//
//  Created by Aimy on 2/25/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWWalletVC: QWBaseVC {

    @IBOutlet weak var tableView: QWTableView!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet weak var banlenceLab: UILabel!
    
    let dataSource = [["icon_income","我的收入"], ["icon_gold","我的重石"], ["icon_coin" ,"我的轻石"]]
    let identifer = "commonCell"
    var emptyView: QWEmptyView = QWEmptyView.createWithNib()

    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            let constant = self.view.safeAreaInsets.top;
            self.tableView.contentInset = UIEdgeInsetsMake(constant, 0, 0, 0)
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
        self.tableView.rowHeight = 52
        self.view.addSubview(self.emptyView)
        self.view.sendSubview(toBack: self.emptyView)
        self.emptyView.autoCenterInSuperview()
        
        self.tableView.register(QWCommonTVCell.self, forCellReuseIdentifier: identifer)
        getData()
    }

    override func getData() {

        self.emptyView.showError = false
        
        self.logic.myWallet = nil

        self.logic.getMyWalletWithCompleteBlock { (aResponseObject, anError) -> Void in
            if let anError = anError as NSError?{
                self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                self.emptyView.showError = true
                return
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                if let code = dict["code"] as? Int , code != 0 {
                    if let message = dict["data"] as? String {
                        self.showToast(withTitle: message, subtitle: nil, type: .error)
                        self.emptyView.showError = true
                    }
                    else {
                        self.emptyView.showError = true
                    }
                }
                else {
                    self.update()
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }

        }
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
    }

    override func update() {
        if let current = self.logic.myWallet?.current {
            let attrString1 = NSMutableAttributedString(string: "￥\(current)")
            attrString1.addAttribute(NSFontAttributeName,value: UIFont(name: "HelveticaNeue-Bold", size: 18)!,
                                     range: NSMakeRange(0,1) )
            self.banlenceLab.attributedText = attrString1
        }
        if let withdraw_balance = self.logic.myWallet?.withdraw_balance {
            self.currentLabel.text = "￥\(withdraw_balance)"
        }
        if let total = self.logic.myWallet?.total {
            self.totalLabel.text = "￥\(total)"
            
        }
    }
}

extension QWWalletVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath as IndexPath)
        as! QWCommonTVCell

        switch indexPath.row {
        case 0:
            cell.updateCell(withIconImageString: self.dataSource[indexPath.row].first, titleString: self.dataSource[indexPath.row].last, subTitle: self.logic.myWallet?.current)
        case 1:
            if let gold = QWGlobalValue.sharedInstance().user?.gold {
                cell.updateCell(withIconImageString: self.dataSource[indexPath.row].first, titleString: self.dataSource[indexPath.row][1], subTitle: gold.stringValue)
            }
        case 2:
            if let coin = QWGlobalValue.sharedInstance().user?.coin {
                cell.updateCell(withIconImageString: self.dataSource[indexPath.row].first, titleString: self.dataSource[indexPath.row][1], subTitle: coin.stringValue)
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "income", sender: nil)
        case 1:
            let vc = QWHeavyBillVC.createFromStoryboard(withStoryboardID: "heavybill", storyboardName: "QWWallet")!
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = QWBillVC.createFromStoryboard(withStoryboardID: "bill", storyboardName: "QWCoin")!
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break;
        }
    }
    
}
