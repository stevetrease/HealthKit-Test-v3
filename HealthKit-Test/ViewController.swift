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
        // NotificationCenter.default.addObserver(self, selector: #selector(refreshObserver), name: NSNotification.Name(rawValue: healthKitDidUpdateNotification1), object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func refreshObserver () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        print ("*** ", healthKitManager.workoutData.count)
        return healthKitManager.workoutData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        
        let workout = healthKitManager.workoutData[indexPath.row]
        
        var text = healthKitManager.workoutTypeString(workout.workoutActivityType)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 0
        text = text + " " + numberFormatter.string(from: workout.duration as NSNumber)!
        
        let energyFormatter = EnergyFormatter()
        let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
        text = text + " " + energyFormatter.string(fromJoules: energy!)
        
        
        /*
         print (workout.startDate, terminator:"\t")
         print (workout.endDate, terminator:"\t")
         
         let numberFormatter = NumberFormatter()
         numberFormatter.numberStyle = NumberFormatter.Style.decimal
         numberFormatter.maximumFractionDigits = 0
         numberFormatter.string(from: workout.duration as NSNumber)!, terminator:"\t")
         
         let energyFormatter = EnergyFormatter()
         let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
         print (energyFormatter.string(fromJoules: energy!), terminator:"\t")
         
         let distance = workout.totalDistance?.doubleValue(for: HKUnit.mile())
         numberFormatter.maximumFractionDigits = 1
         numberFormatter.minimumFractionDigits = 1
         print (numberFormatter.string(from: distance! as NSNumber)!) */
       
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        print ("--- ", healthKitManager.workoutData.count)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
        healthKitManager.getWorkouts (completion: { (x) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            print ("+++ ", healthKitManager.workoutData.count)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
}
