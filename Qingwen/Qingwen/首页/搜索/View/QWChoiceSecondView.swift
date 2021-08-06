//
//  QWChoiceSecondView.swift
//  Qingwen
//
//  Created by mumu on 2017/7/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

protocol QWChoiceSecondViewDelegate: NSObjectProtocol{
    func secondView(_ secondView: QWChoiceSecondView, didClickChoice select: Int)
}

class QWChoiceSecondView: UIView {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    @IBOutlet var heightLayout: NSLayoutConstraint!
    @IBOutlet var coverView: UIView!
    
    var recordDic = [Int:Int]() //记录所有的选择
    
    var recordValue = 0 //记录当前的选择Item
    var recordKey = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        self.layout.minimumInteritemSpacing = 5
        self.layout.minimumLineSpacing = 10
        self.collectionView.register(UINib(nibName: "QWChoiceButtonCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView.backgroundColor = UIColor(hex: 0xf8f8f8)
        self.coverView.bk_tapped { 
            self.deleage?.secondView(self, didClickChoice: -1)
        }
    }
    
    weak var deleage: QWChoiceSecondViewDelegate?
    var titles: [String]?
    
    func updateButtons(withTitles titles: [Array<Any>], mainSelect:Int) {
        self.titles = titles[mainSelect][1]  as? [String]
        let title = titles[mainSelect][0] as! String
        recordKey = mainSelect
        if let recordValue = self.recordDic[mainSelect] {
            self.recordValue = recordValue
        }
        else {
            if let recordValue = self.titles?.index(of: title) {
                 self.recordValue = recordValue
            }
            else {
                self.recordValue = 0
            }

            self.recordDic[mainSelect] = self.recordValue
        }
        
        if (self.titles?.count)! > 7 {
            heightLayout.constant = 240
        }
        else {
            heightLayout.constant = 40
        }
        self.collectionView.reloadData()
    }
}

extension QWChoiceSecondView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let titles = self.titles else{
            return CGSize.zero
        }
        if titles.count < 7 {
            let width = (QWSize.screenWidth() - CGFloat((titles.count + 1) * 10)) / CGFloat( titles.count)
            return CGSize(width: width, height: 40)
        }
        else {
            let width = (QWSize.screenWidth() - 70) / 5
            return CGSize(width: width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.titles?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? QWChoiceButtonCell,let title = self.titles?[indexPath.item] {
            cell.updateBtnTitle(title: title)
            if self.recordValue == indexPath.item {
                cell.choiceBtn.isSelected = true
            }
            else {
                cell.choiceBtn.isSelected = false
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at:IndexPath(item: self.recordValue, section: 0)) as? QWChoiceButtonCell {
           cell.choiceBtn.isSelected = false
        }
        self.recordDic[self.recordKey] = indexPath.item
        self.deleage?.secondView(self, didClickChoice: indexPath.item)
    }
}
