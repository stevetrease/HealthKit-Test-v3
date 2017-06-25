//
//  HealthKitManager.swift
//  iOS Steps
//
//  Created by Steve on 30/01/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import Foundation
import HealthKit


var healthKitManager = HealthKitManager()

class HealthDataType {
    var timeStamp = Date()
    var data = 0.0
}

let healthKitDidUpdateNotification1 = "healthKitDidUpdateNotification1"
let healthKitDidUpdateNotification2 = "healthKitDidUpdateNotification2"


class HealthKitManager {
    
    let historyDays = 7
    
    static let sharedInstance = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    private let numberFormatter = NumberFormatter()
    private let cal = Calendar.current
    
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        checkHealthKitAuthorization()
    }
    
    
    private var earliestPermittedSampleDate: Date {
        return (healthStore.earliestPermittedSampleDate())
    }
    
    
    func getTodayStepCount(completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                print ("getTodayStepCount: \(String(describing: steps))")
                completion(steps)
            } else {
                print ("getTodayStepCount: results are nil - returning zero steps")
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    private func checkHealthKitAuthorization() ->() {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!
            ]
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
                if (error != nil) {
                    isHealthKitEnabled = true
                } else {
                    isHealthKitEnabled = false
                }
            }
        } else {
            isHealthKitEnabled = false
        }
        print ("HeakthKit available? ", isHealthKitEnabled)
    }
}

