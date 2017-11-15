
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
    private var refresher: UIRefreshControl!
    var stepsArray: [(timeStamp: Date, value: Double)] = []
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        // setup pull to refresh
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString (string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(getData), for: .valueChanged)
        
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
        // return stepsArray.count
        return healthKitManager.dailyStepsArray.count
    }
    
    
    
    // nicely formatted custom TableViewCell for each workoutData item
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
        
        let date = healthKitManager.dailyStepsArray[indexPath.row].timeStamp
        // let date = stepsArray[indexPath.row].timeStamp
        
        if (cal.isDateInToday(date)) {
            cell.textLabel?.text = "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string (from: date)
            cell.textLabel?.text = dateString
        }
        
        let steps = healthKitManager.dailyStepsArray[indexPath.row].value
        // let steps = stepsArray[indexPath.row].value
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
            healthKitManager.getStepsAverage (completion: { (steps) in
                OperationQueue.main.addOperation {
                    let numberFormatter = NumberFormatter()
                    numberFormatter.maximumFractionDigits = 0
                    numberFormatter.numberStyle = NumberFormatter.Style.decimal
                    let number = numberFormatter.string(from: healthKitManager.stepsAverage as NSNumber)!
                    
                    numberFormatter.maximumFractionDigits = 0
                    numberFormatter.numberStyle = NumberFormatter.Style.spellOut
                    let number2 = numberFormatter.string(from: healthKitManager.historyDays as NSNumber)!
                    
                    self.averageStepsLabel.text = "\(number) \(number2) day average"
                    
                    if (healthKitManager.stepsToday > healthKitManager.stepsAverage) {
                        self.todayStepsLabel.textColor = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1.0)
                    } else {
                        self.todayStepsLabel.textColor = .black
                    }
                }
            })
            
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsToday as NSNumber)!
                self.todayStepsLabel.text = "\(number) today"
                
                if (healthKitManager.stepsToday > healthKitManager.stepsAverage) {
                    self.todayStepsLabel.textColor = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1.0)
                } else {
                    self.todayStepsLabel.textColor = .black
                }
            }
        })
    }
    
    
    
    // refresh workoutData and then update the tableView
    @objc func getData () {
        healthKitManager.getDailySteps(completion: { () in
            DispatchQueue.main.async(execute: {
                print ("getData callback")
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                
                // determine date of most steps
                /* var max = healthKitManager.dailyStepsArray[0]
                for element in healthKitManager.dailyStepsArray {
                    if element.value > max.value {
                        max = element
                    }
                }
                print ("maximum steps of \(max.value) on \(max.timeStamp)") */
            })
        })
        /*
        for day in 1...28 {
            let date = cal.date(byAdding: .day, value: -day, to: Date())!
            healthKitManager.getStepCountForDay (date, completion: { (steps) in
                // print (day, steps)
                self.stepsArray.insert((timeStamp: date, value: steps!), at: day)
                print ("+")
                self.tableView.reloadData()
            })
        }*/
    }
    
    
    
    // screen tap to refresh workoutData
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getTopData()
        getData()
    }
}
