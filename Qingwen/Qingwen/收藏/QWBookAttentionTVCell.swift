//
//  QWBookAttentionCVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBookAttentionTVCell: QWListTVCell {

    func updateWithVO(_ attention: AttentionVO) {
        
        guard let book = attention.work else {
            return
        }

        if attention.work_type == .game {
            self.updateWithGameVO(book: book)
        }
        else {
            self.updateWithBookVO(book)
//            if let bookId = book.nid, let bookCD = BookCD.mr_findFirst(byAttribute: "nid", withValue: bookId, in: QWFileManager.qwContext()), let old_updated_time = bookCD.updated_time, let new_updated_time = book.updated_time , old_updated_time.compare(new_updated_time) == .orderedAscending {
//                self.countBtn?.setTitle("  有更新", for: UIControlState())
//                self.countBtn?.setBackgroundImage(UIImage(named: "list_count_bg_2"), for: UIControlState());
//            }
            if book.is_vip == "1"{
                self.countBtn?.isHidden = false
                self.countBtn?.setBackgroundImage(book.vipImg(), for: .normal)
                
                self.countBtn?.setTitle("VIP", for: .normal)
            }
        }
        
    }
}
