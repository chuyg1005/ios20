/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import NaturalLanguage

func getLanguage(text: String) -> NLLanguage? {
    //To be replaced
    return  NLLanguageRecognizer.dominantLanguage(for: text)
}

// text为一段评论，block为对这段评论的处理
func getPeopleNames(text: String, block: (String) -> Void) {
    //To be replaced
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    let ignores = Set(["O"])
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
        //        print(type(of: text[tokenRange])) Substring类型
        if tag == .personalName && !ignores.contains(String(text[tokenRange])){
            block(String(text[tokenRange]))
        }
        return true
    }
}

// 获取评论中的每个关键词，并且调用block代码块
func getSearchTerms(text: String, language: String? = nil, block: (String) -> Void) {
    // To be replaced
    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = text
    if let language = language {
        tagger.setLanguage(NLLanguage(rawValue: language), range: text.startIndex..<text.endIndex)
    }
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
        let token = String(text[tokenRange]).lowercased()
        if let tag = tag {
            // 3
            let lemma = tag.rawValue.lowercased()
            block(lemma)
            if lemma != token {
                block(token)
            }
        } else {
            block(token)
        }
        //        if let lemma = tag?.rawValue.lowercased() {
        //            block(lemma)
        //        } else {
        //            block(token)
        //        }
        return true
    }
}

//func lemmatisation(text: String)->String? {
//    var result: String?
//    let tagger = NLTagger(tagSchemes: [.lemma])
//    tagger.string = text
//    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
//    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
//        if let lemma = tag?.rawValue.lowercased() {
//                result = lemma
//        }
//        return true
//    }
////    print(text, result)
//    return result
//}

func analyzeSentiment(text:String) -> Double? {
    // To be replaced
    return nil
}

func getSentimentClassifier() -> NLModel? {
    // To be replaced
    return try? NLModel(mlModel: SentimentClassifier().model)
}

func predictSentiment(text: String, sentimentClassifier: NLModel) -> String? {
    // To be replaced
    return sentimentClassifier.predictedLabel(for: text)
}

// ------------------------------------------------------------------
// -------  Everything below here is for translation chapters -------
// ------------------------------------------------------------------

func getSentences(text: String) -> [String] {
    // To be replaced
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text
    //    print("==========================================")
    //    print(text)
    var sentences = [String]()
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
        sentences.append(String(text[tokenRange]))
        return true
    }
    return sentences
}

func spanishToEnglish(text: String) -> String? {
    // To be replaced
    let instance = Translator.instance
    return instance.translate(text: text)
}

