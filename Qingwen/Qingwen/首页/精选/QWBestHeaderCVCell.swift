//
//  QWBestHeaderCVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWBestHeaderCVCell: QWBaseCVCell {

    @IBOutlet var headerView: iCarousel!
    @IBOutlet var pageControl: UIPageControl!

    var items: [BestItemVO] = []

    var timer: QWDeadtimeTimer?

    override func awakeFromNib() {
        super.awakeFromNib()

        timer = QWDeadtimeTimer()

        headerView.delegate = self
        headerView.dataSource = self
        headerView.isPagingEnabled = true
        headerView.isScrollEnabled = false
        headerView.type = .linear

        self.placeholder = UIImage(named: "placeholder2to1")
    }

    deinit {
        timer?.stop()
    }

    func updateWithBestItems(_ bestItems: [BestItemVO]) {
        self.items = bestItems
        self.headerView.reloadData()
        self.timer?.run(withDeadtime: Date.distantFuture, andBlock: { [weak self] (date) -> Void in
            struct second {
                 static var second = 0
            }

            if let weakSelf = self {
                if weakSelf.headerView.window != nil && weakSelf.headerView.numberOfItems > 1 && second.second % 5 == 0 && !weakSelf.headerView.isScrolling && !weakSelf.headerView.isDragging && !weakSelf.headerView.isDecelerating {
                    weakSelf.headerView.scrollToItem(at: ((weakSelf.headerView.currentItemIndex + 1) % weakSelf.headerView.numberOfItems), animated:true)
                }
            }

            second.second += 1
        })

        self.pageControl.numberOfPages = items.count
        self.headerView.isScrollEnabled = items.count > 0
    }
}

extension QWBestHeaderCVCell: iCarouselDataSource, iCarouselDelegate {

    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var tempView = view
        if tempView == nil {
            tempView = UIView(frame: CGRect(x: 0, y: 0, width: min(QWSize.screenWidth(), QWSize.screenHeight()), height: min(QWSize.screenWidth(), QWSize.screenHeight()) / 2))
            let imageView = UIImageView.autolayout()
            imageView?.tag = 999
            tempView?.addSubview(imageView!)
            imageView?.autoSetDimensions(to: tempView!.bounds.size)
            imageView?.autoCenterInSuperview()
        }

        if let imageView = tempView?.viewWithTag(999) as? UIImageView {
            let item = self.items[index]
            imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(item.cover, imageSizeType:.slide2), placeholder: self.placeholder, animation: true)
        }

        return tempView!
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case iCarouselOption.wrap:
            return 1.0
        default:
            return value
        }
    }

    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        self.pageControl.currentPage = carousel.currentItemIndex
    }

    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
//        // FIXME: Game  Book合并的时候改
//        //判断是否是Game
//        func routerGameUrl(_ vo: BestItemVO) -> String? {
//            let pattern = "/play/\\d+"
//            do {
//                let range = NSMakeRange(0, vo.href!.length)
//                let regx = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//                let matches = regx.matches(in: vo.href!, options: .reportProgress, range: range)
//                if matches.count > 0 {
//                    let res = matches[0]
//                    let gameUrl = (vo.href! as NSString).substring(with: res.range).replacingOccurrences(of: "play", with: "game")
//                    
//                    return "\(QWOperationParam.currentDomain())" + "/" + "\(gameUrl)/"
//                }else {
//                    return nil
//                }
//            } catch _ as NSError {
//         }
//            return nil
//        }
//        func routerActivityUrl(_ vo: BestItemVO) -> String? {
//            let pattern = "aid=\\d+"
//            do {
//                let range = NSMakeRange(0, vo.href!.length)
//                let regx = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//                let matches = regx.matches(in: vo.href!, options: .reportProgress, range: range)
//                if matches.count > 0 {
//                    let res = matches[0]
//                    let activityId = (vo.href! as NSString).substring(with: res.range).replacingOccurrences(of: "aid=", with: "")
//                    
//                    return "\(QWOperationParam.currentDomain())" + "/activity/" + "\(activityId)/"
//                }else {
//                    return nil
//                }
//            } catch _ as NSError {
//            }
//            return nil
//        }
        
        let vo = self.items[index]
//        vo.href = "http://www.iqing.in/play/85"
//        vo.href = "http://www.iqing.in/forum/55dfe20f9d2fd159f2bbc125"
//        vo.href = "http://www.iqing.in/u/10011"
//        vo.href = "http://www.iqing.in/activity.html?aid=13"
//        vo.href = "http://www.iqing.in/book/10564"
        if let href = vo.href {
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString:href)!)
        }
        else {
            if let work = vo.work {
                var params = [String: String]()
                params["id"] = work.nid?.stringValue
                params["book_url"] = work.url
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
    
            }
        }
    }
}

