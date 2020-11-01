//
//  calculator.swift
//  calculator
//
//  Created by shiba on 2020/10/24.
//  Copyright © 2020 shiba. All rights reserved.
//

import Foundation

class Calculator {
    static let initText = "0"
    static let errText = "ERROR"
    
    private var numbers = [Double]()
    private var binOps = [BinaryOperator]()
    private(set) var text = Calculator.initText
    private var clearScreen = false
    private var memoryValue = 0.0
    
    func reset(text: String) {
        self.numbers = []
        self.binOps = []
        self.text = text
        self.clearScreen = false
  //      self.memoryValue = 0.0
    }
    
    // 输入小数点或者数字
    func appendText(text: String) {
        if clearScreen {
            self.text = "0"
            clearScreen = false
        }
        if self.text == "0" && Int(text) != nil || self.text == "ERROR" {
            self.text = text
        } else {
            self.text.append(text)
        }
    }
    
    // 一元运算
    func doUnaryOperation(op: UnaryOperator) {
        clearScreen = false
        if let num = Double(text), let result = op.doOperation(num: num) {
            self.text = formatDouble(value: result)
   //         self.text = String(op.doOperation(num: num))
        } else {
            handleError()
        }
    }
    
    // 添加二元运算符
    func appendBinaryOperation(op: BinaryOperator) {
        clearScreen = false
        if let num = Double(text) {
            self.numbers.append(num)
            while !binOps.isEmpty && op.priority <= binOps.last!.priority {
                if numbers.count < 2 {
                    handleError()
                    return
                }
                let num2 = numbers.popLast()!
                let num1 = numbers.popLast()!
                let binOp = binOps.popLast()!
                
                if let num = binOp.doOperation(a: num1, b: num2) {
                    numbers.append(num)
                } else {
                    handleError()
                    return
                }
            }
            self.binOps.append(op)
            self.text = Calculator.initText
        } else {
            handleError()
        }
    }
    
    // 输入等于号的时候求值
    func eval() {
        if let num = Double(text) {
            self.numbers.append(num)
            while !binOps.isEmpty && numbers.count >= 2{
                    let num2 = numbers.popLast()!
                    let num1 = numbers.popLast()!
                    let binOp = binOps.popLast()!
                    
                    if let num = binOp.doOperation(a: num1, b: num2) {
                        numbers.append(num)
                    } else {
                        handleError()
                        return
                    }
            }
            if !binOps.isEmpty || numbers.count != 1 {
                handleError()
            } else {
                reset(text: formatDouble(value: numbers.last!))
            }
        } else {
            handleError()
        }
        clearScreen = true
    }
    
    // 存储管理
    func memoryManage(command: String) {
        switch command {
        case "mc":
            self.memoryValue = 0.0
        case "m+":
            if let num = Double(text) {
                self.memoryValue += num
            } else {
                handleError()
            }
        case "m-":
            if let num = Double(text) {
                self.memoryValue -= num
            } else {
                handleError()
            }
        case "mr":
            self.text = formatDouble(value: memoryValue)
        default:
            handleError()
        }
//        print(memoryValue)
    }
    
    private func formatDouble(value: Double) -> String{
        return String(format: "%.7f", value).removeZeroSuffix()
    }
    
    // 运算遇到错误的时候调用该方法
    private func handleError() {
        reset(text: Calculator.errText)
    }
}
//class Calculator {
////    var firstNumber: Double? // 第一个变量
//    var numbers: [Double] // 数值
//    var text: String
//    var binOps: [BinaryOperator]
////    var binOp: BinaryOperator?
//    var resultText: String {
//        return text
//    }
//
//    init(initText: String) {
//        text = initText
//    }
//
//    // 向text追加文字
//    func appendText(text: String) {
//        if self.text == "0" && Int(text) != nil || self.text == "ERROR" {
//            self.text = text
////            if let num = Int(text) {
////                self.text = text
////            } else {
////                self.text.append(text)
////            }
//        } else {
//            self.text.append(text)
//        }
//    }
//
//    func reset(text: String) {
//        numbers = []
//        binOps = []
//        self.text = text
//    }
//
//    func doUnaryOperation(op: UnaryOperator) -> Bool{
//        if let num = Double(text) {
//            text = String(op.doOperation(num: num))
//            return true
//        }
//        return false
//    }
//
//    func setBinOp(binOp: BinaryOperator, text: String) -> Bool {
//        if let num = Double(self.text), firstNumber == nil, self.binOp == nil {
//            firstNumber = num
//            self.text = text
//            self.binOp = binOp
//            return true
//        }
//        return false
//    }
//
//    func doBinaryOperation()->Bool {
//        if let num1 = firstNumber, let op = binOp, let num2 = Double(text), let result = op.doOperation(a: num1, b: num2) {
////            print(firstNumber, text, binOp)
////            text = String(result)
//            reset(text: String(result))
//            return true
//        }
//        return false
//    }
//}
//
enum BinaryOperator : String{
    case ADD = "+"
    case SUB = "-"
    case MUL = "×"
    case DIV = "÷"
    case POW = "xʸ"
    case EE = "EE"
    case ROOT = "ʸ√x"
    
    var priority: Int {
        switch self {
        case .ADD, .SUB:
            return 1
        case .MUL, .DIV, .EE, .ROOT, .POW:
            return 2
        }
    }

    func doOperation(a: Double, b: Double) -> Double? {
        switch self {
        case .ADD:
            return a + b
        case .SUB:
            return a - b
        case .MUL:
            return a * b
        case .DIV:
            return b == 0 ? nil : a / b
        case .ROOT:
            return b == 0 ? nil : pow(a, 1 / b)
        case .EE:
            return a * pow(10, b)
        case .POW:
            return pow(a, b)
//        default:
//            return nil
        }
    }
}

enum UnaryOperator: String {
    case NEGATE = "+/-"
    case PERCENT = "%"
    case SQUARE = "x²"
    case CUBE = "x³"
    case E_EXP = "eˣ"
    case TEN_EXP = "10ˣ"
    case RECIP = "1/x"
    case SQUARE_ROOT = "√x"
    case CUBE_ROOT = "∛x"
    case LN = "ln"
    case LOG10 = "log₁₀"
    case FACTORIAL = "x!"
    case SIN = "sin"
    case COS = "cos"
    case TAN = "tan"
    case SINH = "sinh"
    case COSH = "cosh"
    case TANH = "tanh"
    case E = "e"
    case PI = "π"
    case RAND = "Rand"
    case RAD = "Rad"


    func doOperation(num: Double) -> Double? {
        switch self {
        case .NEGATE:
            return -num
        case .PERCENT:
            return num / 100
        case .SQUARE:
            return pow(num, 2)
        case .CUBE:
            return pow(num, 3)
        case .E_EXP:
            return pow(M_E, num)
        case .TEN_EXP:
            return pow(10, num)
        case .RECIP:
            return num == 0 ? nil : 1 / num
        case .SQUARE_ROOT:
            return sqrt(num)
        case .CUBE_ROOT: // 立方根
            return cbrt(num)
        case .LN:
            return log(num)
        case .LOG10:
            return log10(num)
        case .FACTORIAL:
            // TODO: 实现阶乘函数
            return num < 0 ? nil : num == 0 ? 1 : Double((1...Int(num)).reduce(1, {$0 * $1}))
        case .SIN:
            return sin(num)
        case .COS:
            return cos(num)
        case .TAN:
            return tan(num)
        case .SINH:
            return sinh(num)
        case .COSH:
            return cosh(num)
        case .TANH:
            return tanh(num)
        case .E:
            return M_E
        case .PI:
            return Double.pi
        case .RAND:
            return Double.random(in: 0..<1)
        case .RAD:
            return num * Double.pi / 180
        }
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
    
    func removeZeroSuffix()->String {
        var result = self
        if contains(".") {
            while result.last! == "0" {
                result.removeLast()
            }
            
            if result.last! == "." {
                result.removeLast()
            }
        }
        return result
    }
}
