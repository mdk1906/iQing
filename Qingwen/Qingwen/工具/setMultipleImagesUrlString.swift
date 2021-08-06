//
//  setMultipleImagesUrlString.swift
//  Qingwen
//
//  Created by wei lu on 10/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

@objc class MultipleImagesToolsAsset: NSObject{
    public static func multipleImagesSetUrl(groupUrls urls:[String],defaultImage:UIImage?,animation:Bool,completeHandle:@escaping (_ photos:[UIImageView]) -> ()){
        
        let group = DispatchGroup();
        var photos = [UIImageView]()
        
        for imgUrl in urls{
            group.enter()
            let img = UIImageView()

            img.qw_setImageUrlString( QWConvertImageString.convertPicURL(imgUrl, imageSizeType:.cover), placeholder: defaultImage, animation: true, complete: { (image, error, imageURL) in
                photos.append(img)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            completeHandle(photos)
        }
    }
    
    static func combineMulImgs(imageArray: [UIImageView],size:CGSize,count:CGFloat) -> UIImage?{
         return self.drawImages(imageArray: imageArray, size: size, corner: false, count: count, startX: 0,row: 1)
    }
    
    static func drawImages(imageArray: [UIImageView],size:CGSize,corner:Bool,count:CGFloat,startX:CGFloat,row:CGFloat) -> UIImage? {
        //pic frame size
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, UIScreen.main.scale)
        //horizal style
        var imageX: CGFloat = startX
        //background
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.setBlendMode(.normal)
        UIColor(hex:0xf6f6f6)?.setFill()
        context?.fill(rect)
        var draw_row:CGFloat = 1
        
        for (index,item) in imageArray.enumerated() {
            if(index > 2){
                continue
            }
            var scaledSize:CGSize?
            if(1 == row){
                scaledSize = item.image!.getCompressForSize(size.width/count - 1.5)
            }else{
                scaledSize = item.image!.getCompressFitSizeScale(CGSize(width: size.width/count-5, height: size.height/row))
            }
            
            if(corner == true){
                item.image = item.image!.imageWithCornerRadius(12.0, borderWidth: 1.0, borderColor: UIColor.clear)
            }
            
//            item.image!.draw(in: CGRect(x: imageX, y: ((size.height-scaledSize!.height)/(row+1) - 10)*draw_row, width:scaledSize!.width, height: scaledSize!.height))
//
            item.image!.draw(in: CGRect(x: imageX, y: ((size.height-scaledSize!.height)/(row+1) - 10)*draw_row, width:scaledSize!.width, height: scaledSize!.height))
            // 自增每张图片的Y轴
//            if( CGFloat((index+1)).truncatingRemainder(dividingBy: count)  == 0){
//                draw_row += 1
//                imageX = 0
//            }
            imageX += size.width/3 + 3
            
            
        }
        

        // 1.7.获取已经绘制好的图片
        let drawImage = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
        return (drawImage != nil) ? drawImage : nil
    }
}
