//
//  DataSaver.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/14.
//

import UIKit

class DataSaver {
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
            //setUserDefaultsData(newValue: newValue, forKey: "AtLastDate")
        }
    }
    static var dayStudy:[Int]! {//minite
        get {
            return UserDefaults.standard.array(forKey: "dayStudy") as? [Int]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dayStudy")
        }
    }
    static var dayAve:Float {//minite
        get {
            return Float(dayStudy.reduce(0) { $0 + $1 }) / Float(dayStudy.count)
        }
    }
}

fileprivate extension DataSaver {
    
    static func readUserDefaultsData<T:Codable>(forKey:String) -> T? {
        if let data = UserDefaults.standard.data(forKey: forKey) {
            do {
                return try PropertyListDecoder().decode(T.self, from: data)
            }catch{
                return nil
            }
        }else{
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
            print("Failed to Set Month Data")
        }
    }
    
}
