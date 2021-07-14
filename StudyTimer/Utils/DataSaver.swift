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
            print("Failed Save Entire Data")
        }
    }
    static func SaveSubjectsData(_ subjects: [Subject]) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(subjects), forKey: "Subjects")
            SaveEntireData(Entire(subjects))
            
        }catch{
            print("Failed Save Subjects Data")
        }
    }
    static func SaveMonthData(_ month: Month) {
        do {
            UserDefaults.standard.setValue(try PropertyListEncoder().encode(month), forKey: "Month")
        }catch{
            print("Failed Save Subjects Data")
        }
    }
    static var subjects:[Subject]! {
        get{
            if let data = UserDefaults.standard.data(forKey: "Subjects") {
                do {
                    return try PropertyListDecoder().decode(Array<Subject>.self, from: data)
                }catch{
                    print("nil1")
                    return nil
                }
            }else{
                print("nil2")
                return nil
            }
        }
    }
    static var entire:Entire! {
        get{
            if let data = UserDefaults.standard.data(forKey: "Entire") {
                do {
                    return try PropertyListDecoder().decode(Entire.self, from: data)
                }catch{
                    return nil
                }
            }else{
                return nil
            }
        }
    }
    static var month:Month! {
        get{
            if let data = UserDefaults.standard.data(forKey: "Month") {
                do {
                    return try PropertyListDecoder().decode(Month.self, from: data)
                }catch{
                    return nil
                }
            }else{
                return nil
            }
        }
    }
}
