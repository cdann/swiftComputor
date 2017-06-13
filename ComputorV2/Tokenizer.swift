//
//  Tokenizer.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/26/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation




class Tokenizer {
    var index = 0
    private let _tokens : [Token]
    
    static func lex(input: String) -> [Token] {
        var tkns = [Token]()
        var content = input
        
        while (content.characters.count > 0) {
            //print(content)
            var matched = false
            for (pattern, generator) in tokenList {
                if let m = matches(for: pattern, in: content)
                {
                    if let t = generator(m) {
                        tkns.append(t)
                        //print (t)
                    }
                    
                    content = content.substring(from: m.characters.endIndex)
                    matched = true
                    break
                }
            }
            if !matched {
                let index = content.index(content.startIndex, offsetBy: 1)
                tkns.append(.Other(content.substring(to: index)))
                content = content.substring(from: index)
            }
        }
        return tkns
    }
    
    init(input: String) {
        _tokens = Tokenizer.lex(input: input)
    }
    
    func end() -> Bool {
        //print ("\(_tokens.count)   vs  \(self.index)")
        if (self.index >= _tokens.count) {
            return true
        }
        return false
    }
    
    func consume(len:Int = 1) -> Token? {
        if self.end() {
            return nil
        }
        let current = index
        self.index = self.index + len
        return _tokens[current]
    }
    
    func expect(search:Token) -> Either<Bool> {
        let current = self.consume()
        guard current != nil , search == current else{
            return .Fail("Unexpected Token \(current ?? .Other("nil")) while we expect a \(search)")
        }
        return .Success(true)
    }
    
    //if the previous operation failed, the index is back to its start value
    func adjustIndexAndReturn<T>(startIndex:Int, ret:Either<T>) -> Either<T> {
        switch ret{
        case .Fail:
            self.index = startIndex
            return ret
        case .Success:
            return ret
        }
    }
    
    func debugTokens() {
        print(_tokens)
    }
    
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

/*
 M -> .LBracket T .RBracket
 T -> M .SemiColon T
 T -> T .SemiColon T
 T -> Val
 
 4 + (5i - 5) % 7 * var
 O -> O .Operator O
 O -> .LParenth O .RParenth
 O -> Val
 
 VarOrFunc -> .Identifier .LParenth .Identifier RParenth
 VarOrFunc -> .Identifier
 
 Val -> .Number
 Val -> M
 Val -> .Number .I
 Val -> .I
 Val -> VarOrFunc
 Val -> .Identifier .LParenth .Val RParenth
 
 Line -> VarOrFunc .Equal O
 Line -> .Identifier .LParenth .Identifier .RParenth .Equal O
 Line -> O .Equal .Intero
 */


