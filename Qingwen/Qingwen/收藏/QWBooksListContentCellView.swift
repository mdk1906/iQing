//
//  QWBooksListContentCellView.swift
//  Qingwen
//
//  Created by wei lu on 31/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

protocol cellExtraActionDelagate {
    func tapMore()
}

class QWBooksListContentView:UIView{
    
    @IBOutlet weak var cover: UIImageView!
    
    @IBOutlet weak var count: UIButton!
    
    @IBOutlet weak var workType: UIButton!
    
    @IBOutlet weak var workTitle: UILabel!
    
    @IBOutlet weak var recommed: YYLabel!
    
    @IBOutlet weak var extraBtn: UIButton!
    
    public enum fiction_type:Int {
        case Fiction = 1
        case Game = 2
    }
    var delegate:cellExtraActionDelagate?
    
    @IBAction func tapCellMore(_ sender: Any) {
        self.delegate?.tapMore()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true;
        self.extraBtn.alpha = 0.0
    }
    
    func updateItemWithData(_ bookLists:BooksListVO,ShowAll showAll:Bool){
        if let book = bookLists.work{
            self.workTitle.text = book.title
            self.cover.qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: QWImageSizeType.coverThumbnail), placeholder: nil, animation: true)
        }else{
            self.showToast(withTitle: "您收藏的书已不存在", subtitle: nil, type: .alert)
            return
        }
        if let recommed_words = bookLists.recommend{
            self.recommed.text = recommed_words
        }
        if (bookLists.work_type.rawValue == 2){
            self.workType.setTitle("演绘", for: .normal)
            self.workType.backgroundColor = UIColor(hex:0xFCA860)
            if let rightCount = bookLists.work?.scene_count{
                self.count.setTitle(QWHelper.count(toString: rightCount)+"幕", for: .normal)
            }
        }else{
            if let rightCount = bookLists.work?.count{
                self.count.setTitle(QWHelper.count(toString: rightCount), for: .normal)
            }
            self.workType.backgroundColor = UIColor(hex:0xFE99BA)
            self.workType.setTitle("小说", for: .normal)
        }
    }
    
    
}
