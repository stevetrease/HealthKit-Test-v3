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


class HealthKitManager {
    let historyDays = 28
    
    static let sharedInstance = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private let cal = Calendar.current
    
    // on init check for HealthKit authorisations
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        checkHealthKitAuthorization()
    }
    
    
    func stepsBetween (startDate: Date, endDate: Date) -> Int {
        return (Int(arc4random_uniform(10000) + 1))
    }
    
    
    var workoutData: [HKWorkout] = []
    func getWorkouts (completion:@escaping (Double?)->()) {
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
            }
            else {
                print ("No results were returned, check the error")
            }
            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    
    func workoutTypeIcon (_ type: HKWorkoutActivityType) -> String {
        switch type {
        case HKWorkoutActivityType.cycling:
            return ("🚴‍♂️")
        case HKWorkoutActivityType.running:
            return ("🏃")
        case HKWorkoutActivityType.walking:
            return ("🚶")
        default:
            return ("?")
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
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)", "HeakthKit available:", isHealthKitEnabled)
    }
}

