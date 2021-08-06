//
//  QWSummonsSelectView.swift
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

import StoreKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc
protocol QWSummonsSelectViewDelegate: NSObjectProtocol {
    func selectView(_ view: QWSummonsSelectView, didSelectedCount count: NSNumber, type: NSNumber,chargeType:NSNumber)
}

class QWSummonsSelectView: UIView {

    @IBOutlet var coinView: UIView!
    @IBOutlet var heavyCoinView: UIView!

    @IBOutlet var coinBGView: UIView!
    @IBOutlet var heavyCoinBGView: UIView!

    @IBOutlet var currentCoinBtn: UIButton!
    @IBOutlet var currentHeavyCoinBtn: UIButton!
    
    @IBOutlet var coinBtns: [UIButton]!
    @IBOutlet var heavyCoinBtns: [UIButton]!

    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var heavyCoinLabel: UILabel!

    @IBOutlet var faithLabel: UILabel!
    
    weak var delegate: QWSummonsSelectViewDelegate?

    var type = 0;
    var chargeType = 0;
    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()

    @IBAction func onPressedCancelBtn(_ sender: AnyObject) {
        self.removeFromSuperview()
    }

    func updateDisplay() {

        if let coin = QWGlobalValue.sharedInstance().user?.coin {
            self.coinLabel.text = "我的轻石: \(coin)"
        }

        if let gold = QWGlobalValue.sharedInstance().user?.gold {
            self.heavyCoinLabel.text = "我的重石: \(gold)"
        }

        self.coinBGView.layer.borderWidth = PX1_LINE
        self.heavyCoinBGView.layer.borderWidth = PX1_LINE

        if type == 0 {
            self.coinView.isHidden = true
            self.heavyCoinView.isHidden = false
            self.coinBGView.layer.borderColor = UIColor(hex: 0x646ad8)?.cgColor
            self.heavyCoinBGView.layer.borderColor = UIColor.clear.cgColor
            if(chargeType == 0){
                self.faithLabel.text = "投递100轻石, 获得1信仰"
            }else{
                self.faithLabel.text = ""
            }
            
        }
        else {
            self.coinView.isHidden = false
            self.heavyCoinView.isHidden = true
            self.coinBGView.layer.borderColor = UIColor.clear.cgColor
            self.heavyCoinBGView.layer.borderColor = UIColor(hex: 0xffa659)?.cgColor
            if(chargeType == 0){
                self.faithLabel.text = "投递9重石, 获得90信仰"
                
            }else{
                self.faithLabel.text = ""
            }

        }
    }

    @IBAction func onPressedCoinBtn(_ sender: UIButton) {
        self.currentCoinBtn.isSelected = false
        self.currentCoinBtn = sender
        self.currentCoinBtn.isSelected = true
        if(chargeType == 0){
        let faithPoints = (sender.titleLabel!.text! as NSString).integerValue / 100
        self.faithLabel.text = "投递\(sender.titleLabel!.text!)轻石, 获得\(faithPoints)信仰"
        }
        
    }

    @IBAction func onPressedHeavyCoinBtn(_ sender: UIButton) {
        self.currentHeavyCoinBtn.isSelected = false
        self.currentHeavyCoinBtn = sender
        self.currentHeavyCoinBtn.isSelected = true
        if(chargeType == 0){
        let faithPoints = (sender.titleLabel!.text! as NSString).integerValue * 10
        self.faithLabel.text = "投递\(sender.titleLabel!.text!)重石, 获得\(faithPoints)信仰"
        }
    }

    @IBAction func onPressedCoinView(_ sender: AnyObject) {
        self.type = 0
        self.updateDisplay()
    }

    @IBAction func onPressedHeavyCoinView(_ sender: AnyObject) {
        self.type = 1
        self.updateDisplay()
    }

    @IBAction func onPressedDoneBtn(_ sender: UIButton) {
        if type == 0 {
            let count = currentCoinBtn.currentTitle! as NSString;
            if count.integerValue > QWGlobalValue.sharedInstance().user?.coin?.intValue {
                self.showToast(withTitle: "轻石不足", subtitle: nil, type: .alert)
                return
            }
            self.delegate?.selectView(self, didSelectedCount: NSNumber(value: count.integerValue as Int), type: NSNumber(value: self.type), chargeType: NSNumber(value: self.chargeType))
        }
        else {
            let count = currentHeavyCoinBtn.currentTitle! as NSString;
            if count.integerValue > QWGlobalValue.sharedInstance().user?.gold?.intValue {
                self.showToast(withTitle: "重石不足", subtitle: nil, type: .alert)
                return
            }
            
            self.delegate?.selectView(self, didSelectedCount: NSNumber(value: count.integerValue as Int), type: NSNumber(value: self.type), chargeType: NSNumber(value: self.chargeType))
            
        }
    }

    
    @IBAction func onPressedHideGesture(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onPressedChargeBtn(_ sender: UIButton?) {
        QWRouter.sharedInstance().rootVC.showLoading()
        self.toIAP()
    }

    func showMenu() {
        self.onPressedCancelBtn(self)
        self.toIAP()
        
    }

    func toIAP() {
        if SKPaymentQueue.canMakePayments() == false {
            self.showToast(withTitle: "该设备没有支付功能,无法充值", subtitle: nil, type: .alert)
            return
        }
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge", andParams: nil))
        self.onPressedCancelBtn(self)
    }

//    func to3rd() {
//        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge3", andParams: nil))
//        self.onPressedCancelBtn(self)
//    }
}
