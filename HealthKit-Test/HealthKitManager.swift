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


class HealthKitManager {
    let historyDays = 7
    
    static let sharedInstance = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    private let cal = Calendar.current
    
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        checkHealthKitAuthorization()
    }
    
    
    private var earliestPermittedSampleDate: Date {
        return (healthStore.earliestPermittedSampleDate())
    }
    
    
    var workoutData: [HKWorkout] = []
    func getWorkouts (completion:@escaping ()->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let sampleType = HKObjectType.workoutType()
        
        let endDate = Date()
        let startDate =  cal.date(byAdding: .day, value: -historyDays, to: endDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let limit = 0
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [ sortDescriptor ]) { query, results, error in
            if let results = results {
                
                self.workoutData = []
                
                for result in results {
                    if let workout = result as? HKWorkout {
                        self.workoutData.append(workout)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: healthKitDidUpdateNotification1), object: nil)
            }
            else {
                print ("No results were returned, check the error")
            }
        }
        healthStore.execute(query)
    }
    
    
    func workoutTypeString (_ type: HKWorkoutActivityType) -> String {
        switch type {
        case HKWorkoutActivityType.walking:
            return ("walking")
        default:
            return ("unknown workout type")
        }
    }
    
    
    private func checkHealthKitAuthorization() ->() {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
                HKObjectType.workoutType(),
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

