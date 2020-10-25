//
//  calculator.swift
//  calculator
//
//  Created by shiba on 2020/10/24.
//  Copyright © 2020 shiba. All rights reserved.
//

import Foundation

class Calculator {
    var exp: [String]
    var needsToClear: Bool
    let priority: [String:Int] = [
        "+": 1,
        "-": 1,
        "×": 2,
        "÷": 2
    ]
    
    var result: String {
        return exp.joined()
    }
    
    init(_ initContent: String?) {
        exp = []
        needsToClear = true
        if let value = initContent {
            exp.append(value)
        }
    }
    
    func doOperation(_ text: String) {
        let opRegex = try! NSRegularExpression(pattern: "^[+\\-×÷]$", options: [])
        let numRegex = try! NSRegularExpression(pattern: "^[\\d\\.]$", options: [])
        let floatRegex = try! NSRegularExpression(pattern: "^-?\\d*\\.?\\d*$", options: [])
        if needsToClear {
            exp = []
            needsToClear = false
        }
        if text == "AC" {
            exp = ["0"]
            needsToClear = true
        } else if opRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).count != 0{
        //    print("operation regex matched")
            exp.append(text)
        } else if numRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).count != 0 {
            if exp.isEmpty || floatRegex.matches(in: exp[exp.endIndex-1], options: [], range: NSRange(location: 0, length: exp[exp.endIndex-1].count)).count == 0 {
                exp.append(text)
            } else {
                exp[exp.endIndex-1] += text
            }
        } else if text == "="{
            exp = [eval()]
            needsToClear = true
        } else {
            if exp.isEmpty {
                exp = ["0"]
                needsToClear = true
            }
            else if text == "+/-" && floatRegex.matches(in: exp[exp.endIndex-1], options: [], range: NSRange(location: 0, length: exp[exp.endIndex-1].count)).count != 0{
                //print("test")
                if exp[exp.endIndex-1].starts(with: "-") {
                    let str = exp[exp.endIndex-1]
                    exp[exp.endIndex-1] = str.substingInRange(1..<str.count) ?? "0"
                    // print(exp[exp.endIndex-1])
                } else {
                    exp[exp.endIndex-1] = "-" + exp[exp.endIndex-1]
                }
            } else if text == "%" && floatRegex.matches(in: exp[exp.endIndex-1], options: [], range: NSRange(location: 0, length: exp[exp.endIndex-1].count)).count != 0 {
                exp[exp.endIndex-1] = String((Double(exp[exp.endIndex-1]) ?? 0) / 100)
            } else {
                exp = ["ERROR"]
                needsToClear = true
            }
        }
    }
    
    func eval() -> String{
        for i in 0..<exp.count {
            if exp[i].hasPrefix(".") {
                exp[i] = "0" + exp[i]
            }
            if exp[i].hasSuffix(".") {
                exp[i] = exp[i] + "0"
            }
        }
        var operands = [Double]()
        var operators = [String]()
        for item in exp {
            if let num = Double(item) {
                operands.append(num)
            } else {
                while !(operators.isEmpty || priority[item]! > priority[operators[operators.endIndex-1]]!) {
                    let op = operators.removeLast()
                    if operands.count > 1 {
                        let num2 = operands.removeLast()
                        let num1 = operands.removeLast()
                        if op == "+" {
                            operands.append(num1 + num2)
                        } else if op == "-" {
                            operands.append(num1 - num2)
                        } else if op == "×" {
                            operands.append(num1 * num2)
                        } else if op == "÷" {
                            operands.append(num1 / num2)
                        } else {
                            return "ERROR"
                        }
                    } else {
                        return "ERROR"
                    }
                }
                operators.append(item)
            }
        }
        while !(operators.isEmpty) {
            let op = operators.removeLast()
            if operands.count > 1 {
                let num2 = operands.removeLast()
                let num1 = operands.removeLast()
                if op == "+" {
                    operands.append(num1 + num2)
                } else if op == "-" {
                    operands.append(num1 - num2)
                } else if op == "×" {
                    operands.append(num1 * num2)
                } else if op == "÷" {
                    operands.append(num1 / num2)
                } else {
                    return "ERROR"
                }
              } else {
                  return "ERROR"
              }
        }
        if operands.count != 1 {
            return "ERROR"
        }
        return String(operands[0])
    }
}

extension String {
   //获取子字符串
    func substingInRange(_ r: Range<Int>) -> String? {
        if r.lowerBound < 0 || r.upperBound > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy:r.lowerBound)
        let endIndex   = self.index(self.startIndex, offsetBy:r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
