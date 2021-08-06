//
//  QWChoosePhotoVC.swift
//  Qingwen
//
//  Created by Aimy on 2/22/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
import AssetsLibrary

extension QWChoosePhotoVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWChoosePhoto"
        QWRouter.sharedInstance().register(vo, withKey: "choosephoto")
    }
}

class QWChoosePhotoVC: QWBaseVC {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    @IBOutlet var doneBtn: UIBarButtonItem!

    let library = ALAssetsLibrary()
    var images = [ALAsset]()
    var selectedImages = [ALAsset]()

    var maxCount = 6;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.collectionView.backgroundColor = UIColor(hex: 0xFAFAFA)

        self.layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.layout.minimumInteritemSpacing = 5
        self.layout.minimumLineSpacing = 5

        if let extraData = self.extraData {
            if let count = extraData["count"] as? Int {
                maxCount = count
            }
        }

        self.doneBtn.title = "确定(0/\(maxCount))"

        getData()
    }

    override func getData() {
        showLoading()
        images.removeAll()

        performInThreadBlock { () -> Void in
            var groups = [ALAssetsGroup]()
            self.library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, stop) -> Void in
                guard let group = group , group.numberOfAssets() > 0 else {
                    for group in groups {
                        var images = [ALAsset]()
                        group.enumerateAssets(options: .reverse, using: { (result, index, stop) -> Void in
                            if let result = result {
                                images.append(result)
                            }
                        })

                        if let type = group.value(forProperty: ALAssetsGroupPropertyType) as? NSNumber , type.uint32Value ==  ALAssetsGroupSavedPhotos {
                            self.images.insert(contentsOf: images, at: 0)
                        }
                        else {
                            self.images += images
                        }

                        self.performInMainThreadBlock({ () -> Void in
                            self.hideLoading()
                            self.collectionView.reloadData()
                        })
                    }
                    return
                }

                groups.append(group)

                }, failureBlock: { (error) -> Void in

            })
        }
    }

    @IBAction func onPressedOKBtn(_ sender: AnyObject) {
        if QWGlobalValue.sharedInstance().isLogin() == false {
            QWRouter.sharedInstance().routerToLogin()
            return;
        }
        
        let images = self.selectedImages.flatMap({ UIImage(cgImage: $0.defaultRepresentation().fullScreenImage().takeUnretainedValue()) });
        if let extraData = self.extraData {
            if let p_block = extraData.objectForCaseInsensitiveKey(QWRouterCallbackKey) {
                let block = unsafeBitCast(p_block, to: QWNativeFuncVOBlockType.self)
                _ = block(["images": images as AnyObject])
            }
        }
        self.leftBtnClicked(nil);
    }
}

extension QWChoosePhotoVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (SWIFT_IS_IPHONE_DEVICE) {
            let width = floor((QWSize.screenWidth() - 20) / 3)
            return CGSize(width: width, height: width);
        }
        else {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                let width = floor((QWSize.screenWidth() - 20) / 3)
                return CGSize(width: width, height: width);
            }
            else {
                let width = floor((QWSize.screenWidth() - 30) / 5)
                return CGSize(width: width, height: width);
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWChoosePhotoCVCell
        cell.updateWithAsset(self.images[(indexPath as NSIndexPath).item], seletedImages: self.selectedImages)
        return cell;
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.images[(indexPath as NSIndexPath).item]
        guard let url = asset.value(forProperty: ALAssetPropertyAssetURL) as? URL else {
            return
        }

        if let image = selectedImages.filter({ (selectedImage) -> Bool in
            guard let selectedUrl = selectedImage.value(forProperty: ALAssetPropertyAssetURL) as? URL else {
                return false
            }

            return selectedUrl == url
        }).first {
            self.selectedImages.removeObject(image)
        }
        else {
            if selectedImages.count == maxCount {
                self.showToast(withTitle: "图片不能超过\(maxCount)张", subtitle: nil, type: .alert)
                return
            }

            self.selectedImages.append(asset)
        }

        self.doneBtn.title = "确定(\(self.selectedImages.count)/\(maxCount))"
        self.collectionView.reloadData()
    }
}
