//
//  ViewController.swift
//  HealthKit-Test
//
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return healthKitManager.historyDays
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //ourlySteps = self.stepsArray.filter { self.cal.isDateInToday ($0.timeStamp) }
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        return dayData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        
        let day = cal.date(byAdding: .day, value: -indexPath.section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        let workout = dayData[indexPath.row]
        
        // var text = "\(indexPath.section):\(indexPath.row)"
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .positional
        timeFormatter.allowedUnits = [ .hour, .minute ]
        timeFormatter.zeroFormattingBehavior = [ .dropLeading ]
        let components1 = cal.dateComponents( [.hour, .minute], from: workout.startDate)
        var text = timeFormatter.string(from: components1)!
        
        let components2 = cal.dateComponents( [.hour, .minute], from: workout.endDate)
        text = text + " - " + timeFormatter.string(from: components2)!
        
        let timeFormatter2 = DateComponentsFormatter()
        timeFormatter2.unitsStyle = .abbreviated
        timeFormatter2.allowedUnits = [ .hour, .minute ]
        timeFormatter2.zeroFormattingBehavior = [ .dropLeading ]
        text = text + " " + timeFormatter2.string(from: workout.duration)!
        
        text = text + " " + healthKitManager.workoutTypeString(workout.workoutActivityType)
        
        let energyFormatter = EnergyFormatter()
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
        text = text + " " + energyFormatter.string(fromJoules: energy!)
        
        let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile())
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        text = text + " " + numberFormatter.string(from: distance! as NSNumber)!
       
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        
        if section == 0 {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string (from: day!)
        }
    }
    
    
    func getData () {
        healthKitManager.getWorkouts (completion: { (x) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
}
