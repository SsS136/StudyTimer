//
//  Entire.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/19.
//

import UIKit

struct Entire : Codable {
    var entireBaseTime:Int//minite
    var entireProgress:Float {
        get{
            guard entireBaseTime != 0 else { return 0 }
            return Float(entireCurrentTime) / Float(entireBaseTime)
        }
    }
    var entireCurrentTime:Int //minite
    var entireRemainingTime:Int {
        get {
            return entireBaseTime - entireCurrentTime
        }
    }//minite
    init(_ subjects:[Subject]) {
        entireBaseTime = subjects.map{ $0.baseTime }.reduce(0) { $0 + $1 }
        entireCurrentTime = subjects.map{ $0.currentTime }.reduce(0) { $0 + $1 }
    }
    init(entireBaseTime:Int,entireCurrentTime:Int) {
        self.entireBaseTime = entireBaseTime
        self.entireCurrentTime = entireCurrentTime
    }
}
