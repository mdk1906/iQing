//
//  QWPaySuccessVC.swift
//  Qingwen
//
//  Created by Aimy on 3/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWPaySuccessVC: QWBaseVC {

    var product: ProductVO?

    @IBOutlet var mainView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet weak var promptAccontLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fd_interactivePopDisabled = true
        // Do any additional setup after loading the view.
//        self.view.addSubview(self.mainView)
        if let product = self.product {
            print(product)
            if product.name == "VIP"{
                self.priceLabel.text = "充值金额：" + product.vip_bonus!
                self.titleLabel.text = "商品信息： \(product.gold!)天VIP"
                self.userLabel.text = "充值账户： \(QWGlobalValue.sharedInstance().username!)"
                QWGlobalValue.sharedInstance().vip_date = "\(String(describing: product.gold))"
                self.promptAccontLab.text = "您购买的VIP将在1-3分钟到账"
               
            }
            else{
                self.priceLabel.text = "充值金额： \(product.currency!)元"
                self.titleLabel.text = "商品信息： \(product.gold!)重石, 赠送\(product.bonus!)轻石"
                self.userLabel.text = "充值账户： \(QWGlobalValue.sharedInstance().username!)"
            }
            
        }
    }
    
    override func leftBtnClicked(_ sender: AnyObject?) {
        if let viewControllers = self.navigationController?.viewControllers {
            var vc: UIViewController?
            (viewControllers as NSArray).enumerateObjects(options: .reverse, using: { (obj, index, stop) -> Void in
                if !(obj as AnyObject).isKind(of: QWChargeVC.self) && !(obj as AnyObject).isKind(of: QWPaySuccessVC.self) && !(obj as AnyObject).isKind(of: QWMyVIPVC.self) {
                    vc = obj as? UIViewController
                    stop.pointee = true
                }
            })
            if let vc = vc {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                if self.promptAccontLab.text == "您购买的VIP将在1-3分钟到账"{
                     NotificationCenter.default.post(name: NSNotification.Name("VIPisAccount"), object: self, userInfo: nil)
                }
            }
            else {
                _ = self.navigationController?.popViewController(animated: true)
                if self.promptAccontLab.text == "您购买的VIP将在1-3分钟到账"{
                    NotificationCenter.default.post(name: NSNotification.Name("VIPisAccount"), object: self, userInfo: nil)
                }
            }
        }
    }
}
