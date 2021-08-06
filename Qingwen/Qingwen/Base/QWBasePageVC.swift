//
//  QWBasePageVC.swift
//  Qingwen
//
//  Created by Aimy on 10/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

extension UIViewController {
    func setPageShow(_ enable: Bool) {

    }
}

class QWBasePageVC: QWBaseVC {

    @IBOutlet weak var titleView: UIView!

    var pages: [UIViewController]? {
        return nil
    }

    var segmentPaper: MXSegmentedPager?

    @IBOutlet var titleBtns: [UIButton]!
    var currentBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTitleBtns()
        segmentPaper = MXSegmentedPager(frame: self.view.bounds)
        segmentPaper?.dataSource = self
        segmentPaper?.delegate = self
        self.view.addSubview(segmentPaper!)
    }
    
    func initTitleBtns() {
        self.navigationItem.titleView = self.titleView
        
        self.titleBtns = self.titleBtns.sorted { $0.tag < $1.tag }
        
        self.currentBtn = self.titleBtns.first
    }

    override func viewWillLayoutSubviews() {
        segmentPaper?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        super.viewWillLayoutSubviews()
    }

    @IBAction func onPressedTitleBtn(_ sender: UIButton) {
        if sender.tag == self.currentBtn?.tag {
            return
        }

        didSelectedIndex(index: sender.tag)
        segmentPaper?.pager.showPage(at: sender.tag, animated: true)
    }

    @IBAction func onPressedTitleBtnWithSender(sender: UIButton) {
        if sender.tag == self.currentBtn?.tag {
            return
        }
        
        didSelectedIndex(index: sender.tag)
        segmentPaper?.pager.showPage(at: sender.tag, animated: true)
    }
    
    func didSelectedIndex(index: Int) {
        if index == self.currentBtn?.tag {
            return
        }

        if let currentBtn = self.currentBtn, let vc = self.pages?[currentBtn.tag] {
            vc.setPageShow(false)
        }

        self.currentBtn?.isSelected = false
        self.currentBtn = self.titleBtns[index]
        self.currentBtn?.isSelected = true

        if let vc = self.pages?[index] {
            vc.setPageShow(true)
        }
    }
}

extension QWBasePageVC: MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        didSelectedIndex(index: index)
    }

    func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return 0
    }

    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if let pages = self.pages {
            return pages.count
        }
        return 0;
    }

    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        guard let vc = self.pages?[index] else {
            return UIViewController().view
        }

        return vc.view
    }
}

