//
//  QWBooksListDetailsHeaderCell.swift
//  Qingwen
//
//  Created by wei lu on 21/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit
class QWBookListsDetailsHeaderCell: QWBaseCVCell {
    var headView:QWBooksListDetailsHeader!
    var basicHeight:CGFloat = 250
    var actualHeight:CGFloat = 0
    
    override func awakeFromNib() {
    super.awakeFromNib()
    self.headView = QWBooksListDetailsHeader.createWithNib()!;
    self.contentView.addSubview(self.headView)
    self.headView.autoPinEdge(.top, to: .top, of: self.contentView)
    self.headView.autoPinEdge(.left, to: .left, of: self.contentView)
    self.headView.autoPinEdge(.right, to: .right, of: self.contentView)
    self.headView.autoPinEdge(.bottom, to: .bottom, of: self.contentView)
    self.contentView.sendSubview(toBack: self.headView)
    self.clipsToBounds = true;
    }
    
    func updateItemWithData(_ bookLists:FavoriteBooksVO,ShowAll showAll:Bool){
        self.headView.updateWithData(bookLists, ShowAll: showAll)
    }
    
    func getHeaderHeight(textFrame text:String!) -> CGFloat{
        
        
        if(text == nil){
            return self.basicHeight
        }
        if (self.actualHeight > 0) {
            return self.actualHeight;
        }
        let dic = [NSFontAttributeName : UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName:UIColor(hex:0xAEAEAE)!]
        let size = CGSize(width: QWSize.screenWidth()-20, height: CGFloat.greatestFiniteMagnitude)
        if let content = text{
            let frame = content.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil)
            self.actualHeight = frame.size.height + self.basicHeight;

            return self.actualHeight
        }else{
            return self.basicHeight
        }
        
    }
}
