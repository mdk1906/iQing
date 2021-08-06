//
//  QWUserSignatureVC.swift
//  Qingwen
//
//  Created by Aimy on 10/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

let signatureMax = 50

class QWUserSignatureVC: QWBaseVC {

    @IBOutlet var signatureTV: QWTextView!
    @IBOutlet var countLabel: UILabel!

    lazy var logic: QWUserLogic = {
        return QWUserLogic(operationManager: self.operationManager)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.signatureTV.text = QWGlobalValue .sharedInstance().user?.signature
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.signatureTV.becomeFirstResponder()
    }

    @IBAction func onPressedDoneBtn(_ sender: AnyObject) {
        let signature = self.signatureTV.text!
        if (signature as NSString).length <= 0 {
            self.showToast(withTitle: "签名不能为空", subtitle: nil, type: ToastType.alert)
            return
        }
        
        if (signature as NSString).length > signatureMax {
            self.showToast(withTitle: "签名不能超过50个字符", subtitle: nil, type: ToastType.alert)
            return
        }

        self.showLoading()
        self.logic.modifySignature(signature) { (aResponseObject, anError) -> Void in
            self.hideLoading()
            if let anError = anError as NSError?{
                self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                if let code = dict["code"] as? Int , code != 0 {
                    if let message = dict["data"] as? String {
                        self.showToast(withTitle: message, subtitle: nil, type: .error)
                    }
                    else {
                        self.showToast(withTitle: "修改失败", subtitle: nil, type: .error)
                    }
                }
                else {
                    let user = UserVO.vo(withDict: dict)
                    QWGlobalValue.sharedInstance().user = user
                    self.showToast(withTitle: "修改成功", subtitle: nil, type: .error)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension QWUserSignatureVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.countLabel.text = "\(signatureMax - (textView.text as NSString).length)"
    }
}
