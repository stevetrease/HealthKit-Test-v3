//
//  ViewController.swift
//  HealthKit-Test
//
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        healthKitManager.getWorkouts (completion: { (count) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            print (count)
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
