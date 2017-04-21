//
//  Tokenizer.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/26/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

func tokenize(input: String) -> [Token] {
    var tokens = [Token]()
    var content = input
    
   while (content.characters.count > 0) {
    print(content)
        var matched = false
        
        for (pattern, generator) in tokenList {
            if let m = matches(for: pattern, in: content)
            {
                if let t = generator(m) {
                    tokens.append(t)
                    //print (t)
                }
               // print("ooooo \(range)")
                
                content = content.substring(from: m.characters.endIndex)
                matched = true
                break
            }
        }
    
        
        if !matched {
            let index = content.index(content.startIndex, offsetBy: 1)
            tokens.append(.Other(content.substring(to: index)))
            //print(index)
            content = content.substring(from: index)
        }
    }
    return tokens
}

func matches(for regex: String, in text: String) -> String? {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        if results.count == 0 {
            return nil
        }
        return nsString.substring(with: results[0].range)
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return ""
    }
}
