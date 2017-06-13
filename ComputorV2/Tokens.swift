//
//  Tokens.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/26/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

enum Token : Equatable {
    case Number(Float)
    case I
    case LBracket
    case RBracket
    case LParenth
    case RParenth
    case Comma
    case SemiColon
    case Intero
    case Identifier(String)
    case Operator(String)
    case Equal
    case Other(String)
}

func ==(lhs : Token, rhs : Token) -> Bool{
    switch (lhs, rhs){
    case (.LBracket, .LBracket):
        return true
    case (.RBracket, .RBracket):
        return true
    case (.LParenth, .LParenth):
        return true
    case (.RParenth, .RParenth):
        return true
    case (.Comma, .Comma):
        return true
    case (.SemiColon, .SemiColon):
        return true
    case (.Intero, .Intero):
        return true
    case (.Equal, .Equal):
        return true
    case (.I, .I):
        return true
    case let (.Number(n), .Number(m)):
        return n == m
    case let (.Identifier(s), .Identifier(t)):
        return s == t
    case let (.Operator(s), .Operator(t)):
        return s == t
    default:
        return false
    }
}

func createRegex (pattern :String) -> NSRegularExpression{
        return try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
}

typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] = [
    ("^[ \t\n]", { _ in nil }),
    ("^[a-zA-Z][a-zA-Z0-9]*", {$0 == "i" ? .I : .Identifier($0) }),
    ("^[0-9]+(\\.[0-9]+)?", { (r: String) in .Number((r as NSString).floatValue) }),
    ("^[+\\*/\\-%\\^]|\\*\\*", {.Operator($0)}),
    ("^\\(", { _ in .LParenth }),
    ("^\\)", { _ in .RParenth }),
    ("^\\[", { _ in .LBracket }),
    ("^\\]", { _ in .RBracket }),
    ("^,", { _ in .Comma }),
    ("^\\?", { _ in .Intero }),
    ("^;", { _ in .SemiColon }),
    ("^=", { _ in .Equal }),
]
