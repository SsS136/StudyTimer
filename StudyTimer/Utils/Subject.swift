//
//  Subjects.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit

struct Subject : Codable {
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

final class Month : Codable {
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
    static let shared = Month(monthBaseTime: 0, monthCurrentTime: 0)
    private init(monthBaseTime: Int, monthCurrentTime: Int) {
        self.monthBaseTime = monthBaseTime
        self.monthCurrentTime = monthCurrentTime
    }
}

protocol TimeConverter {}
extension TimeConverter {
    func convertMiniteToHour(_ minite:Int) -> String {
        let hours = Float(minite) / Float(60)
        guard hours > 1 else {
            let hour = floor(hours)
            guard hours - hour != 0 else {
                return "0分"
            }
            let minite = 60 * (hours - hour)
            return "\(Int(minite))分"
        }
        if hours < 100 {
            let hour = floor(hours)
            let minite = round((hours - hour) * 60)
            return "\(Int(hour))時間\(Int(minite))分"
        }else{
            print((Int(round(hours))))
            return "\(Int(round(hours)))時間"
        }
    }
    func convertHourToMinite(hour:Int,minite:Int) -> Int {
        let hourToMinite = hour * 60
        print(hourToMinite + minite)
        return hourToMinite + minite
    }
}
