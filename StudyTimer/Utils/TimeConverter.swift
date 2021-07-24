//
//  TimeConverter.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/19.
//

import UIKit

protocol TimeConverter {}
extension TimeConverter {
    func convertMiniteToHour(_ minite:Int) -> String {
        let hours = Float(minite) / Float(60)
        guard hours >= 1 else {
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
            return "\(Int(round(hours)))時間"
        }
    }
    func convertHourToMinite(hour:Int,minite:Int) -> Int {
        let hourToMinite = hour * 60
        return hourToMinite + minite
    }
    func extractHourAndMinitefromMinite(_ minite:Int) -> (Int,Int) {
        let time = Float(minite) / Float(60)
        let hours = floor(time)
        let minite = round((time - hours) * 60)
        return (Int(hours),Int(minite))
    }
    func monthExtracter(date:DateString) -> Int {
        let month = NumberFormatter().number(from: date.components(separatedBy: "月")[0].components(separatedBy: "年")[1]) as! Int
        return month
    }
    @discardableResult func monthDataSetter() -> Int {
        let mon = Calendar.current.component(.month, from: Date())
        if DataSaver.dayStudy == nil {
            DataSaver.dayStudy = [:]
        }
        let monSum = DataSaver.dayStudy.map {(key,value) in
            return value.map {(k,v) in
                if monthExtracter(date: k) == mon {
                    return v.reduce(0) { $0 + $1 }
                }
                return 0
            }
            .reduce(0) { $0 + $1 }
        }
        .reduce(0) { $0 + $1 }

        DataSaver.month = Month(monthBaseTime: DataSaver.month.monthBaseTime, monthCurrentTime: monSum)
        
        return monSum
    }
    func studyTimePerDayUntilTheLastDateOfArrival(remainingTime:Int,nilValue:((UIAlertAction) -> Void)? = nil) -> String {
        guard DataSaver.atLastDate != nil else {
            return ""
        }
        let elapsedDays = Calendar.current.dateComponents([.day], from: Date(), to: DataSaver.atLastDate).day!
        let aveTime = Int(Float(remainingTime) / Float(elapsedDays))
        return convertMiniteToHour(aveTime)
    }
}
