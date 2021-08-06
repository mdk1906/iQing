//
//  QWAddImageCVCell.swift
//  Qingwen
//
//  Created by Aimy on 2/22/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

protocol QWAddImageCVCellDelegate: NSObjectProtocol {

    func addImageCell(_ cell: QWAddImageCVCell, onPressedRetryBtn: AnyObject?)
    func addImageCell(_ cell: QWAddImageCVCell, onPressedDeleteBtn: AnyObject?)

}

class QWAddImageCVCell: QWBaseCVCell {

    weak var delegate: QWAddImageCVCellDelegate?

    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var retryBtn: UIButton!
    @IBOutlet var heightCons: NSLayoutConstraint!

    let imageHeight: Double = 100 / 0.75

    var vo: SubmitImageVO?

    @IBAction func onPressedRetryBtn(_ sender: AnyObject) {
        self.delegate?.addImageCell(self, onPressedRetryBtn: sender)
    }

    @IBAction func onPressedDeleteBtn(_ sender: AnyObject) {
        self.delegate?.addImageCell(self, onPressedDeleteBtn: sender)
    }

    override func prepareForReuse() {
        if let vo = vo {
            self.removeObservations(of: vo.progress, forKeyPath: "fractionCompleted")
        }
    }

    deinit {
        if let vo = vo {
            self.removeObservations(of: vo.progress, forKeyPath: "fractionCompleted")
        }
    }

    func updateWithSubmitImageVO(_ vo: SubmitImageVO) {

        if let vo = self.vo {
            self.removeObservations(of: vo.progress, forKeyPath: "fractionCompleted")
        }

        self.vo = vo

        heightCons.constant = 0;

        if (UIDevice.current.systemVersion as NSString).floatValue > 8.0 {
            self.observe(vo.progress, property: "fractionCompleted") { [weak self] (tempSelf, object, old, newVal) -> Void in
                if let progress = newVal as? Double {
                    print("progress = \(Int(progress * 100))\n")
                    self?.performInMainThreadBlock({ () -> Void in
                        if let weakSelf = self {
                            weakSelf.progressLabel.text = "\(Int(progress * 100))%"
                            weakSelf.heightCons.constant = CGFloat(weakSelf.imageHeight * progress * Double(-1.0))
                        }
                    })
                }
            }
        }

        if let progressView = progressView {
            if (UIDevice.current.systemVersion as NSString).floatValue > 8.0 {
                if vo.type == .loading {
                    progressView.isHidden = false
                }
                else {
                    progressView.isHidden = true
                }
            }
            else {
                if vo.type == .loading {
                    progressView.isHidden = false
                }
                else {
                    progressView.isHidden = true
                }
            }
        }

        if let retryBtn = retryBtn {
            if vo.type == .failed {
                retryBtn.isHidden = false
            }
            else {
                retryBtn.isHidden = true
            }
        }

        if let progressLabel = progressLabel {
            if (UIDevice.current.systemVersion as NSString).floatValue > 8.0 {
                if vo.type == .loading {
                    progressLabel.isHidden = false
                }
                else {
                    progressLabel.isHidden = true
                }
            }
            else {
                progressLabel.isHidden = true
            }
        }

        if let loadingView = loadingView {
            if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
                if vo.type == .loading {
                    loadingView.isHidden = false
                }
                else {
                    loadingView.isHidden = true
                }
            }
            else {
                loadingView.isHidden = true
            }
        }

        if let imageView = imageView, let image = vo.image {//fuck simulator crash
            imageView.image = image
        }
    }
}
