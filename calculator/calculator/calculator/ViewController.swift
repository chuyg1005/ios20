//
//  ViewController.swift
//  calculator
//
//  Created by shiba on 2020/10/21.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    lazy var calc = Calculator(resultLabel.text!)
    
    @IBAction func touchButton(_ sender: UIButton) {
       // resultLabel.text = nil
        // print("label: \(sender.currentTitle!)")
        calc.doOperation(sender.currentTitle!)
        resultLabel.text = calc.result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

