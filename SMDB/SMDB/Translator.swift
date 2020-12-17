//
//  Translator.swift
//  SMDB
//
//  Created by shiba on 2020/12/17.
//  Copyright © 2020 razeware. All rights reserved.
//

import Foundation
import CoreML

class Translator {
    public static let instance = Translator()
    private let encoder = Es2EnCharEncoder16Bit()
    private let decoder = Es2EnCharDecoder16Bit()
    
    private init() {}
    
    private let esCharToInt = { () -> [String : Int] in
        // 加载json文件
        let reviewFile = Bundle.main.url(forResource: "esCharToInt", withExtension: "json")!
        let data = try! Data(contentsOf: reviewFile)
        let esChar2Int = try! JSONDecoder().decode([String: Int].self, from: data)
        return esChar2Int
    }()
    
    private let intToEnChar = { () -> [Int: String] in
        // 加载json文件
        let reviewFile = Bundle.main.url(forResource: "intToEnChar", withExtension: "json")!
        let data = try! Data(contentsOf: reviewFile)
        let intToEnChar = try! JSONDecoder().decode([Int: String].self, from: data)
        return intToEnChar
    }()
    
    private func getEncderIn(text: String)->MLMultiArray? {
        let cleanedText = text.filter {
            esCharToInt.keys.contains(String($0))
        }
        if cleanedText.isEmpty {
            return nil
        }
        
        let vocabSize = esCharToInt.keys.count
        let encoderIn = initMultiArray(shape: [cleanedText.count as NSNumber, 1, vocabSize as NSNumber])
        for (i, c) in cleanedText.enumerated() {
            encoderIn[i*vocabSize+esCharToInt[String(c)]!] = 1
        }
        return encoderIn
    }
    
    public func translate(text: String)->String? {
        guard let encoderIn = getEncderIn(text: text) else {
            return nil
        }
        guard let encoderOut = try? encoder.prediction(encodedSeq: encoderIn, encoder_lstm_h_in: nil, encoder_lstm_c_in: nil) else {
            return nil
        }
        let startTokenIndex = 0
        let stopTokenIndex = 1
        let maxSequenceLength = 50
        var translateText = ""
        var done = false
        var lastIndex = startTokenIndex
        var lstm_h_in = encoderOut.encoder_lstm_h_out
        var lstm_c_in = encoderOut.encoder_lstm_c_out
        let decoderIn = initMultiArray(shape: [intToEnChar.keys.count as NSNumber])
//        for index in 0..<decoderIn.count {
//            decoderIn[index] = 0
//        }
        while !done {
            decoderIn[lastIndex] = 1
            guard let decoderOut = try? decoder.prediction(encodedChar: decoderIn, decoder_lstm_h_in: lstm_h_in, decoder_lstm_c_in: lstm_c_in) else {
                return nil
            }
            lstm_h_in = decoderOut.decoder_lstm_h_out
            lstm_c_in = decoderOut.decoder_lstm_c_out
            decoderIn[lastIndex] = 0
            lastIndex = argmax(array: decoderOut.nextCharProbs)
            if lastIndex == stopTokenIndex {
                done = true
            } else {
                translateText += intToEnChar[lastIndex]!
            }
            if translateText.count >= maxSequenceLength {
                done = true
            }
        }
//        print("tranlasteText = \(translateText)")
        return translateText
    }
    
//    private func makeMultiArray(shape: [Int])->MLMultiArray? {
//        if let arr = try? MLMultiArray(shape: shape.map{$0 as NSNumber}, dataType: .double) {
//            for index in 0..<arr.count {
//                arr[index] = 0
//            }
//            return arr
//        }
//        return nil
//    }
}

