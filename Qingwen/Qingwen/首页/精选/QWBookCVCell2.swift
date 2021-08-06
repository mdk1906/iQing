//
//  QWBookCVCell2.swift
//  Qingwen
//
//  Created by mumu on 17/4/1.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWBookCVCell2: QWListCVCell {

    @IBOutlet weak var beliefLabel: UILabel!
    @IBOutlet weak var combatLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    override func updateWithBookVO(_ book: BookVO) {
        super.updateWithBookVO(book)
        
        if let author = book.author?.first as? UserVO, let authorName = author.username {
            authorLabel.text = "作者：\(authorName)"
        }
        else {
            authorLabel.text = ""
        }
        beliefLabel.text = book.belief != nil ? "信仰：\(QWHelper.count(toShortString: book.belief)!)" : ""
        combatLabel.text = book.combat != nil ? "战力：\(QWHelper.count(toShortString: book.combat)!)" : ""
    }
}
