//
//  QWAddBookCollectionCell.swift
//  Qingwen
//
//  Created by wei lu on 1/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit
class QWAddBookCollectionCell: QWListTVCell {

    @IBOutlet weak var title: UILabel!
    var listId:NSNumber!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true;
    }
    
    func updateWithVO(_ bookLists:FavoriteBooksVO?,Section section:Int){
        if(section == 1){
            guard let vo = bookLists else{
                return
            }
            self.title.text = vo.title
            self.listId = vo.nid
        }else{
            self.title.text = "我喜欢的"
            self.listId = 0
        }
        
    }
    
    
}
