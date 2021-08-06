//
//  QWAddImageView.swift
//  Qingwen
//
//  Created by Aimy on 2/20/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWAddImageView: UIView {

    @IBOutlet var layout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var countLabel: UILabel!

    var logic: QWDiscussLogic?

    var images = [SubmitImageVO]()

    let maxCount = 6

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "QWAddImageAddCVCell", bundle: nil), forCellWithReuseIdentifier: "add")
        self.collectionView.register(UINib(nibName: "QWAddImageCVCell", bundle: nil), forCellWithReuseIdentifier: "image")

        self.collectionView.backgroundColor = UIColor(hex: 0xFAFAFA)

        self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.layout.minimumInteritemSpacing = 10
        self.layout.minimumLineSpacing = 10

        self.layout.itemSize = CGSize(width: 100, height: 100 / 0.75)
    }

    func uploadImages(_ medias: [SubmitImageVO]) {

        var medias = medias

        if medias.count == 0 {
            return
        }

        let media = medias.removeFirst()
        media.type = .loading

        self.logic?.uploadImage(media, andCompleteBlock: { (aResponseObject, anError) -> Void in
            if let anError = anError as NSError?{
                media.type = .failed
                self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                self.collectionView.reloadData()
                self.uploadImages(medias)
                return
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                if let code = dict["code"] as? Int , code != 0 {
                    if let message = dict["data"] as? String {
                        self.showToast(withTitle: message, subtitle: nil, type: .error)
                    }
                    else {
                        self.showToast(withTitle: "上传失败", subtitle: nil, type: .error)
                    }
                    media.type = .failed
                }
                else {
                    media.type = .loaded
                    if let path = dict["path"] as? String {
                        media.path = path
                    }
                }
            }
            self.collectionView.reloadData()
            self.uploadImages(medias)
        })
        self.collectionView.reloadData()
    }

    func clear() {
        self.images.removeAll()
        var rect = self.collectionView.frame
        rect.size.height = 1
        self.collectionView.frame = rect
        self.collectionView.reloadData()
    }

    func isLoading() -> Bool {
        let images = self.images.filter { (image: SubmitImageVO) -> Bool in
            return image.type == .loading
        }
        
        if images.count > 0 {
            return true
        }

        return false
    }

    func imageUrls() -> [String] {
        return self.images.flatMap({ (image) -> String? in
            if image.type == .loaded {
                return image.path
            }

            return nil
        })
    }
}

extension QWAddImageView: QWAddImageCVCellDelegate {

    func addImageCell(_ cell: QWAddImageCVCell, onPressedRetryBtn: AnyObject?) {
        if self.isLoading() {
            self.showToast(withTitle: "请等待图片上传完成", subtitle: nil, type: .alert)
            return
        }

        if let indexPath = self.collectionView.indexPath(for: cell) {
            self.uploadImages([self.images[(indexPath as NSIndexPath).item]])
        }
    }

    func addImageCell(_ cell: QWAddImageCVCell, onPressedDeleteBtn: AnyObject?) {
        if self.isLoading() {
            self.showToast(withTitle: "请等待图片上传完成", subtitle: nil, type: .alert)
            return
        }
        if let indexPath = self.collectionView.indexPath(for: cell) {
            self.images.remove(at: (indexPath as NSIndexPath).item)
            self.collectionView.deleteItems(at: [indexPath])
            self.countLabel.text = "\(self.images.count)/\(self.maxCount)"
        }
    }
}

extension QWAddImageView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).item == images.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath)
            return cell;
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! QWAddImageCVCell
            cell.delegate = self;
            cell.updateWithSubmitImageVO(images[(indexPath as NSIndexPath).item])
            return cell;
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).item == images.count {

            if self.isLoading() {
                showToast(withTitle: "请等待图片上传完成", subtitle: nil, type: .alert)
                return;
            }

            if images.count == maxCount {
                self.showToast(withTitle: "图片不能超过\(maxCount)张", subtitle: nil, type: .alert)
                return
            }

            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "choosephoto", andParams: ["count": maxCount - self.images.count])) { (params) -> AnyObject! in
                if let params = params, let images = params["images"] as? [UIImage] {
                    let images = images.flatMap({ (image) -> SubmitImageVO in
                        let submit = SubmitImageVO()
                        submit.image = image
                        return submit
                    })
                    self.uploadImages(images)
                    self.images += images
                    self.countLabel.text = "\(self.images.count)/\(self.maxCount)"
                    self.collectionView.reloadData()
                }
                return nil
            }
        }
    }
}
