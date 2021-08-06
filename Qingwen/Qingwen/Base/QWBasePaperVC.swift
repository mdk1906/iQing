//
//  QWBasePaperVC.swift
//  Qingwen
//
//  Created by mumu on 16/8/12.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWBasePaperVC: QWBaseVC {
    
    var segmentPaper: MXSegmentedPager?
    var segmentTitles: [String] {
        return [""]
    }
    var pages: [UIViewController]?  {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    var currentVC = UIViewController()
    
    override func viewDidLayoutSubviews() {
        self.initSegmentPaper()
    }
}

//MARK: instantiation
extension QWBasePaperVC {
    fileprivate func initSegmentPaper() {
        if #available(iOS 11.0, *) {
            let safeInset = self.view.safeAreaInsets.top
             segmentPaper = MXSegmentedPager(frame: CGRect(x: 0, y: safeInset, width: QWSize.screenWidth(), height: QWSize.screenHeight() - safeInset))
        }else{
            segmentPaper = MXSegmentedPager(frame: CGRect(x: 0, y: 64, width: QWSize.screenWidth(), height: QWSize.screenHeight() - 64))
        }
        
        
        segmentPaper?.dataSource = self
        segmentPaper?.delegate = self
        self.view.addSubview(self.segmentPaper!)

        segmentPaper?.segmentedControl.backgroundColor = UIColor(hex: 0xf8f8f8)
        segmentPaper?.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x888888)!, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
//        segmentPaper?.segmentedControl
        segmentPaper?.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0)
        //设置选择时状态
        segmentPaper?.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0xFB83AC)!,  NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        segmentPaper?.segmentedControl.selectionIndicatorLocation = .down
        segmentPaper?.segmentedControl.selectionStyle = .textWidthStripe
        segmentPaper?.segmentedControl.selectionIndicatorColor = UIColor(hex: 0xFB83AC)
        segmentPaper?.segmentedControl.selectionIndicatorHeight = 3.0
        segmentPaper?.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -10)
        //设置下划线
        segmentPaper?.segmentedControl.borderType = .bottom
//        segmentPaper?.segmentedControl.borderColor = UIColor(hex: 0xDCDCDC)
//        segmentPaper?.segmentedControl.borderWidth = 0.5
        
//        segmentPaper?.segmentedControl.userInteractionEnabled = false //Segment不能点击
        self.automaticallyAdjustsScrollViewInsets = false
    }

}

extension QWBasePaperVC: MXSegmentedPagerDataSource, MXSegmentedPagerDelegate {
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if let pages = self.pages {
            return pages.count
        }
        return 0
    }
    
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentTitles[index]
    }
    
    func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return 40
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        guard let vc = self.pages?[index] else {
            return UIViewController().view
        }
        self.currentVC = vc
        return vc.view
    }
    
}
