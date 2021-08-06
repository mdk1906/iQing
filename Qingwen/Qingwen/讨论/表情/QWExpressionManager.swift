//
//  QWExpressionManager.swift
//  Qingwen
//
//  Created by Aimy on 12/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWExpressionManager: NSObject {
    private static var __once: () = {
            Static.staticInstance = QWExpressionManager()
        }()
    struct Static {
        static var onceToken : Int = 0
        static var staticInstance : QWExpressionManager? = nil
    }

    class var sharedManager : QWExpressionManager {

        _ = QWExpressionManager.__once

        return Static.staticInstance!
    }

    let expressions: [String]
    let pattern: String
    let imagePattern: [String: UIImage]

    override init() {
        if let path = Bundle.main.path(forResource: "expression", ofType:"plist"), let strings = NSArray(contentsOfFile: path) as? [String] {
            self.expressions = strings
        }
        else {
            self.expressions = [String]()
        }

        var imagePattern = [String: UIImage]()
        for expression in self.expressions {
            imagePattern[":[\(expression)]:"] = UIImage(named: expression)
        }
        self.imagePattern = imagePattern

        var pattern = "\\[("
        if let expression = self.expressions.first {
            pattern += expression
        }
        for expression in self.expressions.dropFirst() {
            pattern += "|" + expression
        }
        pattern += ")\\]"
        self.pattern = pattern

        super.init()
    }
}
