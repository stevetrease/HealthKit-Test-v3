
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit


class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var todayStepsLabel: UILabel!
    @IBOutlet var averageStepsLabel: UILabel!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        todayStepsLabel.text = " "
        averageStepsLabel.text = " "
        
        getTopData()
        getData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    
    // one row in each section for each workout in that day in the workoutData
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthKitManager.dailyStepsArray.count
    }
    
    
    
    // nicely formatted custom TableViewCell for each workoutData item
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
        
        let date = healthKitManager.dailyStepsArray[indexPath.row].timeStamp
        
        if (cal.isDateInToday(date)) {
            cell.textLabel?.text = "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string (from: date)
            cell.textLabel?.text = dateString
        }
        
        let steps = healthKitManager.dailyStepsArray[indexPath.row].value
        let stepFormatter = NumberFormatter()
        stepFormatter.maximumFractionDigits = 0
        stepFormatter.numberStyle = NumberFormatter.Style.decimal
        let stepString = stepFormatter.string (from: steps as NSNumber)!
        cell.detailTextLabel?.text = stepString
        
        if cal.isDateInWeekend (date) {
            cell.backgroundColor = UIColor (white: 0.95, alpha: 1.0)
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    
    
    func getTopData () {
        healthKitManager.getTodayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                print ("getTopData getTodayStepCount callback")
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsToday as NSNumber)!
                self.todayStepsLabel.text = "\(number) today"
            }
        })
        
        healthKitManager.getStepsAverage (completion: { (steps) in
            OperationQueue.main.addOperation {
                print ("getTopData getStepsAverage callback")
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsAverage as NSNumber)!
                
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.spellOut
                let number2 = numberFormatter.string(from: healthKitManager.historyDays as NSNumber)!
                
                self.averageStepsLabel.text = "\(number) \(number2) day average"
            }
        })
    }
    
    
    
    // refresh workoutData and then update the tableView
    func getData () {
        healthKitManager.getDailySteps(completion: { () in
            DispatchQueue.main.async(execute: {
                print ("getData callback")
                self.tableView.reloadData()
                
                // determine date of most steps
                var max = healthKitManager.dailyStepsArray[0]
                for element in healthKitManager.dailyStepsArray {
                    if element.value > max.value {
                        max = element
                    }
                }
                print ("maximum steps of \(max.value) on \(max.timeStamp)")
            })
        })
    }
    
    
    
    // screen tap to refresh workoutData
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getTopData()
        getData()
    }
}
