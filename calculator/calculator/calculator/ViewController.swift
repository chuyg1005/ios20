//
//  ViewController.swift
//  calculator
//
//  Created by shiba on 2020/10/21.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var calculator = Calculator()
    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func touchNumber(_ sender: UIButton) {
        if let title = sender.currentTitle {
            calculator.appendText(text: title)
            updateView()
        }
    }
    
    @IBAction func allClear() {
        calculator.reset(text: Calculator.initText)
        updateView()
    }
    
    @IBAction func touchUnary(_ sender: UIButton) {
        if let title = sender.currentTitle, let op = UnaryOperator(rawValue: title) {
            calculator.doUnaryOperation(op: op)
            updateView()
        }
    }
    
    @IBAction func eval() {
        calculator.eval()
        updateView()
    }
    
    @IBAction func touchBinary(_ sender: UIButton) {
        if let title = sender.currentTitle, let op = BinaryOperator(rawValue: title) {
            calculator.appendBinaryOperation(op: op)
            updateView()
        }
    }
    
    func updateView() {
        result.text = calculator.text
    }
}

