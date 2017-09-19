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
    let numberOfDays = 7
    
    static let sharedInstance = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private let cal = Calendar.current
    
    // on init check for HealthKit authorisations
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        checkHealthKitAuthorization()
    }
    
    
    var dailyStepsArray: [(timeStamp: Date, value: Double)] = []
    
    func getDailySteps (completion:@escaping ()->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        var interval = DateComponents()
        interval.day = 1
        
        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
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
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -self.numberOfDays, to: endDate)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    // tempArray.append((timeStamp: date, value: steps))
                    tempArray.insert((timeStamp: date, value: steps), at: 0)
                }
            }
            self.dailyStepsArray = tempArray
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

