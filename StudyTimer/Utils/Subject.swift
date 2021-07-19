//
//  Subjects.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit

struct Subject : Codable, Hashable {
    var title:String
    var baseTime:Int //minite
    var currentTime:Int //minite
    var progress:Float {
        get {
            return Float(currentTime) / Float(baseTime)
        }
    }
    var remainingTime:Int { //minite
        get {
            return baseTime - currentTime
        }
    }
}
