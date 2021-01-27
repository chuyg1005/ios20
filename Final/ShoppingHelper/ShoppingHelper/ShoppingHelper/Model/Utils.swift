//
//  Utils.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import Foundation
import NaturalLanguage

let sentimentClassifier = try? NLModel(mlModel: SentimentClassifier().model)
//let urlSession = URLSession(configuration: )


func processUrl(url: String, completion:@escaping (String)->Void) {
//    print(url)
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"]
    let session = URLSession(configuration: config)
    if let url = URL(string: url) {
//        print(url)
//                    print("url obj create")
        let task = session.dataTask(with: url) {data, response, error in
//            print(url.absoluteString+" finished")
            if let error = error {
                print("miss error")
                print("\(error.localizedDescription)")
                return
            }
            //
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("server error")
                    return
            }
            //            if let mimeType = httpResponse.mimeType {
            //                print(mimeType)
            //            }
            //            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
            //            if let mimeType = httpResponse.mimeType,
            //            print(data)
            
            if let data = data {
                if let html = String(data: data, encoding: .utf8){
                    //                print(html)
                    //                process(html)
                    completion(html)
                    
                } else {
                    let cfEnc = CFStringEncodings.GB_18030_2000
                    let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                    if let html = String(data: data, encoding: String.Encoding(rawValue: enc)) {
//                        print(html)
                        completion(html)
                    }
                }
            }
        }
        task.resume()
    }
}

// 1
func analyzeSentiment(text: String) -> Double {

//    // 3
//    let tagger = NLTagger(tagSchemes: [.sentimentScore])
//    tagger.string = text
//
//    // Ask for the results
//    let sentiment = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0
//
//    // Read the sentiment back and print it
//    let score = Double(sentiment?.rawValue ?? "0") ?? 0 // score取值范围在[-1, 1]，转换0-10
//    // 4
//    return (score + 1) * 5
    guard let prediction = predictSentiment(text: text) else {
        return 4.0
    }
//    print(text + " " + prediction)
    return prediction == "pos" ? 8.0 : 0.0
    
}

func predictSentiment(text: String)->String? {
//    print(sentimentClassifier?.configuration.language)
    return sentimentClassifier?.predictedLabel(for: text)
}

