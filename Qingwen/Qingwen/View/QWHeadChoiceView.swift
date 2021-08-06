//
//  QWHeadChoiceView.swift
//  Qingwen
//
//  Created by mumu on 17/3/28.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWHeadChoiceView: UIView {
    
    struct ChoiceButton {
        let padding: CGFloat
        let width: CGFloat
        var height: CGFloat
        
        init() {
            self.padding = 8
            self.height = 40
            self.width = 35
        }
        init(padding: CGFloat, width: CGFloat, height: CGFloat) {
            self.padding = padding
            self.width = width
            self.height = height
        }
    }

    fileprivate var titles: [String]?
    
    var block: QWActionBlock?
    var currentBtn: UIButton?
    
    var choiceButton: ChoiceButton
    
    required init?(coder aDecoder: NSCoder) {
        self.choiceButton = ChoiceButton()
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.choiceButton = ChoiceButton()
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    convenience init(titles:[String]?, fromPointX:CGFloat) { //从左侧开始
        self.init()
        self.titles = titles
        self.frame = self.getFrame(fromLeft: true, x:fromPointX)
        self.configView()
    }
    
    convenience init(titles:[String]?, toPointX:CGFloat) { //从右侧开始
        self.init()
        self.titles = titles
        self.frame = self.getFrame(fromLeft: false, x:toPointX)
        self.configView()
    }
    
    fileprivate func getFrame(fromLeft: Bool, x: CGFloat) -> CGRect {
        guard let titles = titles else {
            return CGRect.zero
        }
        
        if fromLeft {
            return CGRect(x: x, y: 0, width: choiceButton.padding * CGFloat(titles.count - 1) + CGFloat(titles.count) * choiceButton.width, height: choiceButton.height)
        }
        else {
            let startX = QWSize.screenWidth() - (choiceButton.padding * CGFloat(titles.count - 1) + CGFloat(titles.count) * choiceButton.width) - x
            return CGRect(x: startX, y: 0, width: choiceButton.padding * CGFloat(titles.count - 1) + CGFloat(titles.count) * choiceButton.width, height: choiceButton.height)
        }
    }
    
    fileprivate func configView(){
        guard let titles = titles else {
            return
        }
        
        for (index,title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: (choiceButton.padding * CGFloat(index))  + choiceButton.width * CGFloat(index), y: 8, width: choiceButton.width, height: 24)
            button.tag = index
            self.addSubview(button)
            
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.color55(), for: .normal)
            button.setTitleColor(UIColor.colorA6(), for: .selected)
            button.selectedBackgroundColor = UIColor.colorEE()
            
            button.layer.cornerRadius = 2
            button.layer.masksToBounds = true
            button.titleEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
            
            button.addTarget(self, action:#selector(QWHeadChoiceView.onPressedBtn(_:)) , for: .touchUpInside)
            
            if index == 0 {
                button.isSelected = true
                self.currentBtn = button
            }
        }
        
    }

    @objc private func onPressedBtn(_ sender: UIButton) {
        if  sender == self.currentBtn  {
            return
        }
        self.currentBtn?.isSelected = false
        self.currentBtn = sender;
        self.currentBtn?.isSelected = true
        self.block?(sender)
    }
    
}
