//
//  SubmitImageVO.swift
//  Qingwen
//
//  Created by Aimy on 2/23/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

func ==(lhs: SubmitImageVO, rhs: SubmitImageVO) -> Bool {
    return lhs.id == rhs.id
}

class SubmitImageVO: Equatable {

    enum LoadingType {
        case loading
        case loaded
        case failed
    }

    var type: SubmitImageVO.LoadingType = .loading
    let id: Int
    var image: UIImage?

    var path = ""

    var progress = Progress()

    init() {
        let range = Range(uncheckedBounds: (lower: 1, upper: 1000))
        id = randomInRange(range)
    }
}
