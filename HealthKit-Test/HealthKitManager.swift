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
    static let sharedInstance = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private let numberOfDays = 365 / 4
    let historyDays = 7
    
    private let cal = Calendar.current
    
    
    // on init check for HealthKit authorisations
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        checkHealthKitAuthorization()
    }
    
    
    var dailyStepsArray: [(timeStamp: Date, value: Double)] = []
    
    
    var stepsToday: Double = 0.0
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
                self.stepsToday = steps!
                completion(steps)
            } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                self.stepsToday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    
    var stepsYesterday: Double = 0.0
    func getYesterdayStepCount(completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)

        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                self.stepsYesterday = steps!
                completion(steps)
            } else {
                self.stepsYesterday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    func getStepCountForDay(_ day: Date, completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let startDate = cal.startOfDay(for: day)
        let endDate = cal.date(byAdding: .day, value: 1, to: startDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                completion(steps)
            } else {
                print("getStepCountForDay: results are nil - returning zero steps")
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    
    var stepsAverage: Double = 1000000.0
    func getStepsAverage (completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -historyDays, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                self.stepsAverage = steps! / Double(self.historyDays)
                completion(steps! / Double(self.historyDays))
            } else {
                print("getStepsAverage: results are nil - returning zero steps")
                self.stepsAverage = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    
    func getHourlySteps (completion:@escaping ()->()) {
    }

    
    
    func getDailySteps (completion:@escaping ()->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        var interval = DateComponents()
        interval.day = 1
        
        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let queryStartTime = Date()
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate!,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = self.cal.date(byAdding: .day, value: -1, to: self.cal.startOfDay(for: Date()))
            let startDate = self.cal.date(byAdding: .day, value: -self.numberOfDays, to: endDate!)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate!) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    tempArray.insert((timeStamp: date, value: steps), at: 0)
                }
            }
            self.dailyStepsArray = tempArray
            
            let queryEndTime = Date()
            let elapsedTime: Double = queryEndTime.timeIntervalSince(queryStartTime)
            let elapsedTimePerDay = elapsedTime / Double (self.numberOfDays)
            
            print ("elapsed time        : \(elapsedTime)")
            print ("elapsed time per day: \(elapsedTimePerDay)")
            
            completion ()
        }
        healthStore.execute(query)
    }
    
    
    private func checkHealthKitAuthorization() ->() {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
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

