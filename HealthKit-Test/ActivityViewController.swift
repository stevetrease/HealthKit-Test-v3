
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit
import Charts

let numberOfZeroCells = 2


class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var todayStepsLabel: UILabel!
    @IBOutlet var yesterdayStepsLabel: UILabel!
    @IBOutlet var averageStepsLabel: UILabel!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
    private var refresher: UIRefreshControl!
    var stepsArray: [(timeStamp: Date, value: Double)] = []
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // setup pull to refresh
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString (string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(getData), for: .valueChanged)
        
        // zero labels
        todayStepsLabel.text = " "
        yesterdayStepsLabel.text = " "
        averageStepsLabel.text = " "
        
        // setup click to paste
        yesterdayStepsLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.copyStepsPressed))
        yesterdayStepsLabel.addGestureRecognizer(gestureRecognizer)
        
        getData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return stepsArray.count
        print (healthKitManager.dailyStepsArray.count)
        return healthKitManager.dailyStepsArray.count + numberOfZeroCells
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            // initial cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "zeroCell")! as! ZeroCellTableViewCell
            
            cell.barChartView.legend.enabled = false
            
            cell.barChartView.xAxis.drawLabelsEnabled = true
            cell.barChartView.xAxis.drawGridLinesEnabled = false
            cell.barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            
            cell.barChartView.leftAxis.axisMinimum = 0
            cell.barChartView.leftAxis.drawGridLinesEnabled = false
            cell.barChartView.leftAxis.drawLabelsEnabled = false
            cell.barChartView.leftAxis.drawAxisLineEnabled = false
            
            cell.barChartView.rightAxis.drawLabelsEnabled = false
            cell.barChartView.rightAxis.drawAxisLineEnabled = false
            
            cell.barChartView.chartDescription?.text = ""
            cell.barChartView.drawBordersEnabled = false
            
            var dailyStepDataEntries: [BarChartDataEntry] = []
            var xLabels: [String] = []
            
            if healthKitManager.dailyStepsArray.count > 0 {
                for day in 0..<healthKitManager.historyDays {
                    let timeStamp = healthKitManager.dailyStepsArray[day].timeStamp
                    let value = healthKitManager.dailyStepsArray[day].value
                    // print ("\(day)", "\(timeStamp)", "\(value)")
                    
                    let dailyStepEntry = BarChartDataEntry(x: Double(healthKitManager.historyDays - day), y: value)
                    dailyStepDataEntries.append(dailyStepEntry)

                    let formatter = DateFormatter()
                    formatter.dateFormat = "E"
                    xLabels.append (formatter.string (from: timeStamp))
                }
                
                let barDataSet = BarChartDataSet(values: dailyStepDataEntries, label: "")
                barDataSet.colors = [UIColor.lightGray]
                let barData = BarChartData(dataSets: [barDataSet])
                cell.barChartView.data = barData

                cell.barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(value, _) in
                    let index = healthKitManager.historyDays - Int(value)
                    return (xLabels[index])
                })
                
                cell.barChartView.data?.notifyDataChanged()
                cell.barChartView.notifyDataSetChanged()
            } else {
                print ("no data for bar chart 1")
            }
            
            return cell
        } else if (indexPath.row == 1) {
            // initial cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "zeroCell")! as! ZeroCellTableViewCell
            
            cell.barChartView.legend.enabled = false
            
            cell.barChartView.xAxis.drawLabelsEnabled = true
            cell.barChartView.xAxis.drawGridLinesEnabled = false
            cell.barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            
            cell.barChartView.leftAxis.axisMinimum = 0
            cell.barChartView.leftAxis.drawGridLinesEnabled = false
            cell.barChartView.leftAxis.drawLabelsEnabled = false
            cell.barChartView.leftAxis.drawAxisLineEnabled = false
            
            cell.barChartView.rightAxis.drawLabelsEnabled = false
            cell.barChartView.rightAxis.drawAxisLineEnabled = false
            
            cell.barChartView.chartDescription?.text = ""
            cell.barChartView.drawBordersEnabled = false
            
            var dailyStepDataEntries: [BarChartDataEntry] = []
            var xLabels: [String] = []
            
            if healthKitManager.dailyStepsArray.count > 0 {
                for day in 0..<healthKitManager.historyDays {
                    let timeStamp = healthKitManager.dailyStepsArray[day].timeStamp
                    let value = healthKitManager.dailyStepsArray[day].value
                    // print ("\(day)", "\(timeStamp)", "\(value)")
                    
                    let dailyStepEntry = BarChartDataEntry(x: Double(healthKitManager.historyDays - day), y: value)
                    dailyStepDataEntries.append(dailyStepEntry)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E"
                    xLabels.append (formatter.string (from: timeStamp))
                }
                
                let barDataSet = BarChartDataSet(values: dailyStepDataEntries, label: "")
                barDataSet.colors = [UIColor.lightGray]
                let barData = BarChartData(dataSets: [barDataSet])
                cell.barChartView.data = barData
                
                cell.barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(value, _) in
                    let index = healthKitManager.historyDays - Int(value)
                    return (xLabels[index])
                })
                
                cell.barChartView.data?.notifyDataChanged()
                cell.barChartView.notifyDataSetChanged()
            } else {
                print ("no data for bar chart 2")
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
            
            let date = healthKitManager.dailyStepsArray[indexPath.row - numberOfZeroCells].timeStamp
            
            if (cal.isDateInToday(date)) {
                cell.textLabel?.text = "Today"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateString = formatter.string (from: date)
                cell.textLabel?.text = dateString
            }
            
            let steps = healthKitManager.dailyStepsArray[indexPath.row - 1].value
            // let steps = stepsArray[indexPath.row].value
            let stepFormatter = NumberFormatter()
            stepFormatter.maximumFractionDigits = 0
            stepFormatter.numberStyle = NumberFormatter.Style.decimal
            let stepString = stepFormatter.string (from: steps as NSNumber)!
            cell.detailTextLabel?.text = stepString
            
            if steps > healthKitManager.stepsAverage {
                cell.detailTextLabel?.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
            } else {
                cell.detailTextLabel?.textColor = .black
            }
            
            if cal.isDateInWeekend (date) {
                cell.backgroundColor = UIColor (white: 0.95, alpha: 1.0)
            } else {
                cell.backgroundColor = .clear
            }
            
            return cell
        }
    }
    
    
    
    @objc func getData () {
        // get yesterday's steps
        healthKitManager.getYesterdayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsYesterday as NSNumber)!
                self.yesterdayStepsLabel.text = "\(number) yesterday"
                
                if (healthKitManager.stepsYesterday > healthKitManager.stepsAverage) {
                    self.yesterdayStepsLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                } else {
                    self.yesterdayStepsLabel.textColor = .black
                }
            }
        })
        
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
                    
                    self.averageStepsLabel.text = "\(number) \(number2)-day average"
                    
                    if (healthKitManager.stepsToday > healthKitManager.stepsAverage) {
                        self.todayStepsLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                    } else {
                        self.todayStepsLabel.textColor = .black
                    }
                    
                    if (healthKitManager.stepsYesterday > healthKitManager.stepsAverage) {
                        self.yesterdayStepsLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                    } else {
                        self.yesterdayStepsLabel.textColor = .black
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
                    self.todayStepsLabel.textColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                } else {
                    self.todayStepsLabel.textColor = .black
                }
            }
        })
        
        // get historical days steps
        healthKitManager.getDailySteps(completion: { () in
            DispatchQueue.main.async(execute: {
                print ("getData getDailySteps callback")
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            })
        })
        
        // get hourly steps steps
        healthKitManager.getHourlySteps(completion: { () in
            DispatchQueue.main.async(execute: {
                print ("getData getHourlySteps callback")
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            })
        })
    }
    
    
    
    @objc func copyStepsPressed () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        UIPasteboard.general.string = String(Int(healthKitManager.stepsYesterday))
    }
}
