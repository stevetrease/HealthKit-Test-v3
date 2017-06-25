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
    
    private let cal = Calendar.current
    
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
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
    
    
    func getWorkouts (completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let sampleType = HKObjectType.workoutType()
        
        let endDate = Date()
        let startDate =  cal.date(byAdding: .day, value: -historyDays * 2, to: endDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let limit = 0
        
        var workouts: [HKWorkout] = []
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [ sortDescriptor ]) { query, results, error in
            if let results = results {
                print ("results: \(results.count)")
                for result in results {
                    if let workout = result as? HKWorkout {
                        workouts.append(workout)
                        
                        print (self.workoutTypeString(workout.workoutActivityType), terminator:"\t")
                        
                        print (workout.startDate, terminator:"\t")
                        print (workout.endDate, terminator:"\t")
                        
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = NumberFormatter.Style.decimal
                        numberFormatter.maximumFractionDigits = 0
                        print (numberFormatter.string(from: workout.duration as NSNumber)!, terminator:"\t")
                        
                        let energyFormatter = EnergyFormatter()
                        let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
                        print (energyFormatter.string(fromJoules: energy!), terminator:"\t")
                            
                        let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile())
                        numberFormatter.maximumFractionDigits = 1
                        numberFormatter.minimumFractionDigits = 1
                        print (numberFormatter.string(from: distance! as NSNumber)!)
                    }
                }
            }
            else {
                print ("No results were returned, check the error")
            }
            
        }
        healthStore.execute(query)
    }
    
    
    private func workoutTypeString (_ type: HKWorkoutActivityType) -> String {
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

