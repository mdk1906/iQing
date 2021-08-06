//
//  QWWordsInputPopUp.swift
//  Qingwen
//
//  Created by wei lu on 2/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit
protocol QWWordsInputPopDelegate{
    func didConfirmWordsInput(text:NSString)
}

enum popType {
    case Blur
}
class QWWordsInputPopUp: UIView {

    @IBOutlet weak var cancel: UIImageView!
    @IBOutlet weak var textInput: QWTextView!
    var isShowing = false
    var delegate:QWWordsInputPopDelegate?
    var bgEffect:UIVisualEffectView!
    
    @IBAction func clickConfirm(_ sender: Any) {
        if(self.textInput.text.length > 100){
            self.showToast(withTitle: "内容超过100字!", subtitle: "", type: .alert)
            return
        }
        
        if(self.delegate != nil){
            self.delegate?.didConfirmWordsInput(text: self.textInput.text as NSString)
        }
        self.dissmiss()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let ges = UITapGestureRecognizer()
        ges.bk_init { [weak self] (_, _, _) -> Void in
            if let weakSelf = self {
                if(weakSelf.isShowing){
                    weakSelf.dissmiss()
                }
            }
        }
        self.textInput.placeholder = "推荐词在100字以内，可以为空"
        self.cancel.addGestureRecognizer(ges)
        self.cancel.isUserInteractionEnabled = true
        self.bgEffect = UIVisualEffectView(frame: CGRect(x:0,y:0,width:self.layer.frame.width, height:self.layer.frame.height))
        self.bgEffect?.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.backgroundColor = UIColor(white:0, alpha: 0.5)
    }
    
    
    func show(){
        self.isShowing = true
        self.frame = UIScreen.main.bounds
        QWRouter.sharedInstance().rootVC.view.addSubview(self)
    }
    
    func showWithData(content:String?){
        self.textInput.text = content
        self.show()
    }
    
    func dissmiss(){
        self.isShowing = false
        self.removeFromSuperview()
    }
}
