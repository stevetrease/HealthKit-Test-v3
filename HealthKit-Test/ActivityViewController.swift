
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit


class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
 
    
    // one row in each section for each workout in that day in the workoutData
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (healthKitManager.dailyStepsArray.count)
        return healthKitManager.dailyStepsArray.count
    }
    
    
    // nicely formatted custom TableViewCell for each workoutData item
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
        
        let date = healthKitManager.dailyStepsArray[indexPath.row].timeStamp
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string (from: date)
        cell.textLabel?.text = dateString
        
        let steps = healthKitManager.dailyStepsArray[indexPath.row].value
        let stepFormatter = NumberFormatter()
        stepFormatter.maximumFractionDigits = 0
        stepFormatter.numberStyle = NumberFormatter.Style.decimal
        let stepString = stepFormatter.string (from: steps as NSNumber)!
        cell.detailTextLabel?.text = stepString
        
        if cal.isDateInWeekend (date) {
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = nil
        }
        
        return cell
    }
    
    
    // refresh workoutData and then update the tableView
    func getData () {
        healthKitManager.getDailySteps(completion: { () in
            DispatchQueue.main.async(execute: {
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
        getData()
    }
}
