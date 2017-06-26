//
//  ViewController.swift
//  HealthKit-Test
//
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        // tableView.dataSource = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        
        let text = "Cell \(indexPath.row)"
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return "Section \(section)"
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        healthKitManager.getWorkouts (completion: { (count) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            print (count)
        })
        
        healthKitManager.getDailySteps (completion: { (count) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        })
        
        healthKitManager.getTodayStepCount (completion: { (steps) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: steps! as NSNumber)!
                print ("\(number) today")
            }
        })
    }
}
