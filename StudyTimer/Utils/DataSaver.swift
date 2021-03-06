//
//  DataSaver.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/14.
//

import UIKit

typealias SubjectTitle = String
typealias DateString = String


///[String (refering to subject) : [String (refering to Date):[Int (refering to minite)]]]
/// This type refers to the amount of study time per day for each subject
typealias DayStudyData = [SubjectTitle:[DateString:[Int]]]

/// This type refers to the amount of study per day
typealias PerDay = [Dictionary<DateString,Int>.Element]


///class for storing many study data in UserDefaults.
class DataSaver : TimeConverter {
    static func SaveEntireData(_ entire: Entire) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(entire), forKey: "Entire")
        }catch{
            print("Failed to Save Entire Data")
        }
    }
    static func SaveSubjectsData(_ subjects: [Subject]) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(subjects), forKey: "Subjects")
            SaveEntireData(Entire(subjects))
            
        }catch{
            print("Failed to Save Subjects Data")
        }
    }
    static func SaveMonthData(_ month: Month) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(month), forKey: "Month")
        }catch{
            print("Failed to Save Subjects Data")
        }
    }
    static var subjects:[Subject]! {
        get{
            return readUserDefaultsData(forKey: "Subjects")
        }
        set {
            setUserDefaultsData(newValue: newValue, forKey: "Subjects") {
                SaveEntireData(Entire(newValue))
            }
        }
    }
    static var entire:Entire! {
        get{
            return readUserDefaultsData(forKey: "Entire")
        }
        set{
            setUserDefaultsData(newValue: newValue, forKey: "Entire")
        }
    }
    static var month:Month! {
        get{
            return readUserDefaultsData(forKey: "Month")
        }
        set {
            setUserDefaultsData(newValue: newValue, forKey: "Month")
        }
    }
    
    static var backgroundDate:Date! {
        get {
            return UserDefaults.standard.object(forKey: "Date") as? Date

        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "Date")
        }
    }
    
    static var elapsedTime:Float {
        get {
            return UserDefaults.standard.float(forKey: "etime")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "etime")
        }
    }

    static var atLastDate:Date! {
        get {
            do {
                if let data = UserDefaults.standard.data(forKey: "AtLastDate") {
                    return try JSONDecoder().decode(Date.self, from: data)
                }else {
                    print("failed to set data")
                    return nil
                }
            }catch{
                print("failed to set data")
                return nil
            }
            //return readUserDefaultsData(forKey: "AtLastDate")
        }
        set {
            do {
                UserDefaults.standard.setValue(try JSONEncoder().encode(newValue),forKey: "AtLastDate")
            }catch{
                print("failed to set data")
            }
        }
    }
    ///DayStudyData = [String:[String:[Int]]]
    ///[String (refering to subject) : [String (refering to Date):[Int (refering to minite)]]]
    static var dayStudy: DayStudyData! {//minite
        //example {Subject Object : [2021 1/1 : [100,1000],2021 1/2 : [111,4333,1322]] }
        get {
            return readUserDefaultsData(forKey: "dayStudy")
        }
        set {
            setUserDefaultsData(newValue: newValue, forKey: "dayStudy")
        }
    }
    /// Perday = [Dictionary<DateString,Int>.Element]
    static var studyTimePerDay:PerDay! {
        get {
            guard dayStudy != nil else { return PerDay()}
            let allData = dayStudy
                .map { $1 }
                .flatMap { $0 }
            var store = [DateString:[Int]]()
            allData.forEach { store[$0, default: []].append(contentsOf: $1) }
            var store_1 = [DateString:Int]()
            store.forEach {
                store_1.updateValue($1.reduce(0) { $0 + $1 }, forKey: $0)
            }
            let df = DateFormatter()
            df.dateFormat = "yyyy???MM???dd???"
            return store_1.sorted {
                df.date(from: $0.0)! > df.date(from: $1.0)!
            }
           // return store_1
        }
    }
    
    static var today:String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        return formatter.string(from: Date())
    }
    static var dayAve:Float {//minite
        get {
            if dayStudy == nil { dayStudy = [:] }
            guard dayStudy.count != 0 else { return 0 }
            let total = dayStudy.map {(key,value) in
                value.map { (key,value) in
                    value.reduce(0) { $0 + $1 }
                }
                .reduce(0) { $0 + $1 }
            }
            .reduce(0) { $0 + $1 }
            
            let count = Array(
                Set(
                    dayStudy.map {(key,value) in
                        value.map { (key2,value2) in
                            key2
                        }
                    }
                    .flatMap {$0}
                )
            )
            .count
            return Float(total) / Float(count)
        }
    }
    static func subjectDayAverage(dayStudy:[Dictionary<DateString, [Int]>.Element]) -> Int {
        let total = dayStudy.map {(key,value) in
            value.reduce(0) { $0 + $1 }
        }.reduce(0) { $0 + $1 }
        let count = dayStudy.count
        guard count != 0 else { return 0 }
        return Int(Float(total) / Float(count))
    }
    private static func convertMiniteToHour(_ minite:Int) -> String {
        let hours = Float(minite) / Float(60)
        guard hours > 1 else {
            let hour = floor(hours)
            guard hours - hour != 0 else {
                return "0???"
            }
            let minite = 60 * (hours - hour)
            return "\(Int(minite))???"
        }
        if hours < 100 {
            let hour = floor(hours)
            let minite = round((hours - hour) * 60)
            return "\(Int(hour))??????\(Int(minite))???"
        }else{
            return "\(Int(round(hours)))??????"
        }
    }
}

fileprivate extension DataSaver {
    
    static func readUserDefaultsData<T:Codable>(forKey:String) -> T? {
        if let data = UserDefaults.standard.data(forKey: forKey) {
            do {
                return try PropertyListDecoder().decode(T.self, from: data)
            }catch{
                print("failed to decode data")
                return nil
            }
        }else{
            print("failed to get data")
            return nil
        }
    }
    
    static func setUserDefaultsData<T:Codable>(newValue:T,forKey:String,completion: (() -> Void)? = nil) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(newValue), forKey: forKey)
            if let com = completion {
                com()
            }
        }catch{
            print("Failed to Set Data")
        }
    }
    
}
