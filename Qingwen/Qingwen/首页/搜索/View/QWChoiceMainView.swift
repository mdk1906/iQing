//
//  QWChoiceMainView.swift
//  Qingwen
//
//  Created by mumu on 2017/7/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

protocol QWChoiceMainViewDelegate: NSObjectProtocol {
    func choiceMainView(_ choiceMainView: QWChoiceMainView, didClickChoiceBtn button: (UIButton, NSNumber?))
}

class QWChoiceMainView: UIView {
    
    let mainViewhight = CGFloat(40)
    let secondViewHeight = QWSize.screenHeight() - 104
    var config = false
    
    var topLayout: NSLayoutConstraint?
    private var heightLayout: NSLayoutConstraint?
    weak var delegate: QWChoiceMainViewDelegate?
    
    @IBOutlet var currentBtn: UIButton!
    @IBOutlet var mainButtons: Array <UIButton>!
    @IBOutlet var firstView: UIView!
    
    var currentSelectSecondChoices = [Array<Any>]()
    
    var dataSoure = [Array<Any>]()

    lazy var secondeView:QWChoiceSecondView = {
        
        let view = QWChoiceSecondView.createWithNib()!
        self.addSubview(view)
        view.autoPinEdge(.top, to: .bottom, of: self.firstView)
        view.autoPinEdge(.left, to: .left, of: self)
        view.autoPinEdge(.right, to: .right, of: self)
        view.autoSetDimension(.height, toSize: self.secondViewHeight)
        view.isHidden = true
        view.deleage = self
        return view
    }()
    
    func changeTitles() {
        for (_, choice) in currentSelectSecondChoices.enumerated() {
            let first = choice[0] as! Int
            let tags = choice[1] as! String
            self.dataSoure[first][0] = tags
        }
    }
    
    override func didMoveToSuperview() {
        if self.config == false {
            self.config = true
            
            if #available(iOS 11.0, *) {
                let guide = self.superview!.safeAreaLayoutGuide
                self.topLayout = self.topAnchor.constraint(equalTo: guide.topAnchor)
                self.topLayout?.isActive = true
            }else{
                self.topLayout = self.autoPinEdge(.top, to: .top, of: self.superview!)
            }
            
            self.autoPinEdge(.left, to: .left, of: self.superview!)
            self.autoPinEdge(.right, to: .right, of: self.superview!)
            self.heightLayout = self.autoSetDimension(.height, toSize: CGFloat(mainViewhight))
        }
    }
    
    func updateButtons(withTitles titles: [Array<Any>]) {
        self.dataSoure = titles
        for (index,btn) in mainButtons.enumerated() {
            if index > titles.count - 1 {
                btn.isHidden = true
            }
            else {
                let title = titles[index][0] as? String
                btn.setTitle(title, for: UIControlState())
                btn.isHidden = false
            }
        }
        
        for (index,btn) in self.mainButtons.enumerated() {
            if index > dataSoure.count - 1 {
                break
            }
            if dataSoure[btn.tag].count > 1, let titles = dataSoure[btn.tag][1] as? NSArray,titles.count > 1 { //有两级分层
                btn.horizontalCenterTitleAndImage(14)
            }
            else {
                btn.setImage(#imageLiteral(resourceName: "search_btn2_selected"), for: .selected)
                btn.setImage(nil, for: .normal)
                btn.setTitleColor(UIColor(hex: 0xFB83AC), for: .selected)
                btn.horizontalCenterImageAndTitle()
                if index == 0 {
                    btn.isSelected = true
                }
            }
        }
    }

    @IBAction func onPressedChoiceBtn(_ sender: UIButton) {
        
        if self.dataSoure[sender.tag].count > 1 { //子分类
            if sender.tag == self.currentBtn.tag && self.currentBtn.isSelected == true{
                self.currentBtn.isSelected = false
                self.hideSecondView()
                return;
            }
            self.currentBtn.isSelected = false
            self.currentBtn = sender
            self.currentBtn.isSelected = true
            
            self.showSecondView()
            self.secondeView.updateButtons(withTitles: dataSoure,mainSelect: self.currentBtn.tag)
        }
        else {
            self.currentBtn.isSelected = false
            self.currentBtn = sender
            self.currentBtn.isSelected = true
            self.delegate?.choiceMainView(self, didClickChoiceBtn: (sender, nil))
        }
    }
    
    fileprivate func hideSecondView() {
        self.secondeView.isHidden = true
        self.heightLayout?.constant = mainViewhight
    }
    
    fileprivate func showSecondView(){
        self.secondeView.isHidden = false
        self.heightLayout?.constant = mainViewhight + secondViewHeight
    }
}

//MARK: QWChoiceSecondViewDelegate
extension QWChoiceMainView: QWChoiceSecondViewDelegate {
    func secondView(_ secondView: QWChoiceSecondView, didClickChoice sender: Int) {
        
        guard sender >= 0 else {
            self.currentBtn.isSelected = false
            self.hideSecondView()
            return
        }
        if sender >= 0, let titles = self.dataSoure[self.currentBtn.tag][1] as? [Any], let title = titles[sender] as? String {
            self.currentBtn.setTitle(title, for: UIControlState())
            self.currentBtn.horizontalCenterTitleAndImage(14)
            self.currentBtn.isSelected = false
            if sender == 0 {
                self.currentBtn.setTitleColor(UIColor(hex: 0x979797), for: .normal)
                self.currentBtn.setImage(#imageLiteral(resourceName: "search_btn_delected"), for: .normal)

            }
            else {
                self.currentBtn.setTitleColor(UIColor(hex: 0xFB83AC), for: .normal)
                self.currentBtn.setImage(#imageLiteral(resourceName: "search_btn_selecteddown"), for: .normal)
            }

            self.hideSecondView()
            self.delegate?.choiceMainView(self, didClickChoiceBtn: (self.currentBtn,NSNumber(value: sender)))
        }
    }
}

