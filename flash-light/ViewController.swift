//
//  ViewController.swift
//  light
//
//  Created by apple on 2020/9/24.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func switchBackground(_ sender: UIButton) {
        if sender.currentTitle == "On" {
            self.view.backgroundColor = .white
            sender.backgroundColor = .black
            sender.setTitleColor(.white, for: .normal)
            sender.setTitle("Off", for: .normal)
        } else {
            self.view.backgroundColor = .black
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
            sender.setTitle("On", for: .normal)
        }
    }
}

