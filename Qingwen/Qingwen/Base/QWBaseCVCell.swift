//
//  QWBaseCVCell.swift
//  Qingwen
//
//  Created by wei lu on 1/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

extension QWBaseCVCell{
//    func hSingleSelBtn(typeE aTypeE:Int) {
//        
//        let frameE:CGRect = self.frame;
//        let aWidthH:CGFloat = frameE.width;
//        let aHeightT:CGFloat = frameE.height;
//
//        if aTypeE==1 {
//            //横向
//            let widthH:CGFloat = (aWidthH-20-30*CGFloat(titleArray.count))/CGFloat(titleArray.count);
//
//            for i:Int in 0 ..< titleArray.count {
//                let btn = UIButton(frame: CGRect(x: 10+(widthH+20)*CGFloat(i), y: (aHeightT-16)/2, width:16,height: 16))
//                btn.setImage(UIImage(named: "choose"), for: UIControlState.normal)
//                btn.setImage(UIImage(named: "unchoose"), for: UIControlState.selected)
//                if i==0 {
//                    btn.isSelected = true;
//                }else{
//                    btn.isSelected = false;
//                }
//                btn.tag = i+10000;
//                btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside);
//                self.addSubview(btn);
//            }
//        }else{
//            //纵向
//            let hidthH = CGFloat(aHeightT / CGFloat(titleArray.count));
//
//            for i:Int in 0 ..< titleArray.count {
//
//                let btn = UIButton(frame: CGRect(x:10,y:(hidthH-16)/2 + hidthH * CGFloat(i), width:16, height:16));
//                btn.setImage(UIImage(named: "unchoose"), for: UIControlState.normal);
//                btn.setImage(UIImage(named: "choose"), for: UIControlState.selected);
//                if i==0 {
//                    btn.isSelected = true;
//                }else{
//                    btn.isSelected = false;
//                }
//                btn.tag = i+10000;
//                btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside);
//                self.addSubview(btn);
//            }
//        }
//        self.tag = 10000;
//    }
//    
//    func btnClick(btn:UIButton) {
//        if !btn.isSelected {
//            btn.isSelected = !btn.isSelected;
//            //上一个按钮还原
//            let buttonN = self.viewWithTag(self.tag) as? UIButton;
//            buttonN?.isSelected = false;
//
//            self.tag = btn.tag;
//        }
//    }
}

