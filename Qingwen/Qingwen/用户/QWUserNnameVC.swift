//
//  QWUserNnameVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/3/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit
let nNameMax = 24
class QWUserNnameVC: QWBaseVC {

    @IBOutlet weak var nNameTF: UITextField!
   
    lazy var logic: QWUserLogic = {
        return QWUserLogic(operationManager: self.operationManager)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nNameTF.text = QWGlobalValue .sharedInstance().username
        print("nname = %@",QWGlobalValue .sharedInstance().username ?? String())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.nNameTF.becomeFirstResponder()
        
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        let nName = self.nNameTF.text!
        if (nName as NSString).length <= 0 {
            self.showToast(withTitle: "昵称不能为空", subtitle: nil, type: ToastType.alert)
            return
        }
        
        if (nName as NSString).length > nNameMax {
            self.showToast(withTitle: "昵称不能超过24个字符", subtitle: nil, type: ToastType.alert)
            return
        }
        let alertController = UIAlertController(title: "修改昵称",
                                                message: "昵称只能修改一次，是否确认修改？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确认", style: .default, handler: {
            action in
            print("点击了确定")
            self.showLoading()
            self.logic.modifynName(nName) { (aResponseObject, anError) -> Void in
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
                        QWGlobalValue.sharedInstance().username = dict["username"] as? String
                        QWGlobalValue.sharedInstance().update_username = dict["update_username"] as? NSNumber
                        self.showToast(withTitle: "修改成功", subtitle: nil, type: .error)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension QWUserNnameVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
}
}
