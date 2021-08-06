//
//  QWListFilterVC.swift
//  Qingwen
//
//  Created by Aimy on 10/15/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

protocol QWListFilterVCDelegate: class {
    func doFilter(_ category: QWChannelType, sort: QWSortType)
    func cancelFilter()
}

class QWListFilterVC: QWBaseVC {

    @IBOutlet weak var currentCategoryBtn: UIButton!
    @IBOutlet var showAllBtn: UIButton!
    @IBOutlet var show11Btn: UIButton!
    @IBOutlet var show10Btn: UIButton!

    @IBOutlet var show12Btn: UIButton!

    @IBOutlet weak var currentSortBtn: UIButton!

    @IBOutlet var moveView: UIView!

    @IBOutlet var sortByDefaultBtn: UIButton!
    @IBOutlet var sortByTimeBtn: UIButton!

    @IBOutlet var rightConstraint: NSLayoutConstraint?

    var categoryOptions = QWChannelType.typeNone
    var sortOptions = QWSortType.top

    weak var delegate: QWListFilterVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func show(category: QWChannelType, sort: QWSortType) {
        switch category {
        case .type11:
            self.currentCategoryBtn = self.show11Btn
        case .type10:
            self.currentCategoryBtn = self.show10Btn
        case .typeNone:
            self.currentCategoryBtn = self.showAllBtn
        case .type12:
            self.currentCategoryBtn = self.show12Btn
        default:
            break
        }

        self.currentCategoryBtn.isSelected = true

        switch sort {
        case QWSortType.top:
            self.currentSortBtn = self.sortByDefaultBtn
        case QWSortType.time:
            self.currentSortBtn = self.sortByTimeBtn
        default:
            self.currentSortBtn = self.sortByDefaultBtn
        }

        self.currentSortBtn.isSelected = true

        self.categoryOptions = category
        self.sortOptions = sort
        
        self.rightConstraint?.constant = 280
        self.view.layoutIfNeeded()

        self.rightConstraint?.constant = 0

        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.view.layoutIfNeeded()
        }) 
    }


    func hide(_ callback: @escaping () -> Void) {
        self.rightConstraint?.constant = 280

        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] (_) -> Void in
                self?.view.removeFromSuperview()
                callback()
        }) 
    }

    @IBAction func onPressedCancelBtn(_ sender: AnyObject) {
        self.delegate?.cancelFilter()
    }

    @IBAction func onPressedOKBtn(_ sender: AnyObject) {
        self.delegate?.doFilter(self.categoryOptions, sort: self.sortOptions)
    }

    @IBAction func onPressedShowAllBtn(_ sender: UIButton) {
        self.currentCategoryBtn.isSelected = false
        self.currentCategoryBtn = sender
        self.currentCategoryBtn.isSelected = true
        self.categoryOptions = .typeNone
    }

    @IBAction func onPressedShow11Btn(_ sender: UIButton) {
        self.currentCategoryBtn.isSelected = false
        self.currentCategoryBtn = sender
        self.currentCategoryBtn.isSelected = true
        self.categoryOptions = .type11
    }

    @IBAction func onPressedShow10Btn(_ sender: UIButton) {
        self.currentCategoryBtn.isSelected = false
        self.currentCategoryBtn = sender
        self.currentCategoryBtn.isSelected = true
        self.categoryOptions = .type10
    }

    @IBAction func onPressedShow12Btn(_ sender: UIButton) {
        self.currentCategoryBtn.isSelected = false
        self.currentCategoryBtn = sender
        self.currentCategoryBtn.isSelected = true
        self.categoryOptions = .type12
    }
    
    @IBAction func onPressedSortByDefaultBtn(_ sender: UIButton) {
        self.currentSortBtn.isSelected = false
        self.currentSortBtn = sender
        self.currentSortBtn.isSelected = true
        self.sortOptions = .top
    }

    @IBAction func onPressedSortByTimeBtn(_ sender: UIButton) {
        self.currentSortBtn.isSelected = false
        self.currentSortBtn = sender
        self.currentSortBtn.isSelected = true
        self.sortOptions = .time
    }
}

