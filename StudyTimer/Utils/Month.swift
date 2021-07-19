//
//  Month.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/19.
//

import UIKit

///A structure for storing monthly study data.

struct Month : Codable {
    var monthBaseTime:Int
    var monthCurrentTime:Int //This variale will be reseted at the end of the month
    var monthRemainingTime:Int {
        get {
            return monthBaseTime - monthCurrentTime
        }
    }
    var monthProgress:Float {
        get {
            guard monthBaseTime != 0 else { return 0 }
            return Float(monthCurrentTime) / Float(monthBaseTime)
        }
    }

    init(monthBaseTime: Int, monthCurrentTime: Int) {
        self.monthBaseTime = monthBaseTime
        self.monthCurrentTime = monthCurrentTime
    }
}
