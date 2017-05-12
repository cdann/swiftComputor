//
//  Parser.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/27/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

enum ParseError : Error {
    case UnexpectedToken(unexpected: Token)
}

class Tokenizer {
    var index = 0
    let tokens : [Token]
    
    init(ts:[Token]) {
        tokens = ts
    }
    
    func end() -> Bool {
        print ("\(tokens.count)   vs  \(self.index)")
        if (tokens.count < self.index) {
            return false
        }
        return true
    }
    
    func consume(len:Int = 1) -> Token? {
        if self.end() {
            return nil
        }
        let current = index
        self.index = self.index + len
        return tokens[current]
    }
    
    func expect(search:Token) -> Either<Bool> {
        let current = self.consume()
        guard current != nil , search == current else{
            return .Fail("Unexpected Token \(current) while we expect a \(search)")
        }
        return .Success(true)
    }
    
    func adjustIndexAndReturn<T>(startIndex:Int, ret:Either<T>) -> Either<T> {
        switch ret{
            case .Fail:
                self.index = startIndex
                return ret
            case .Success:
                return ret
        }
    }
    
}

let precedenceTab: [String : Int] = [
    "+" : 20,
    "-" : 20,
    "*" : 30,
    "/" : 30,
]





func parseLine(line:[Token]) -> Either<LineNode> {
    let tk = Tokenizer(ts:line)
    let  tmp  = parseAssignation(tk:tk)
    print("## \(tmp)")
    return tmp <|> parseComputation(tk:tk)
}

func parseAssignation(tk:Tokenizer) -> Either<LineNode> {
    // funA(x) = 2*x+1
    /*let (len,lhs) =
    tk.consume(len)
    tk.expect(search: Token.Equal)
    let rhs = parseOperation(tk:tk)
    
    return (LineNode(lhs:lhs, rhs:rhs))*/
    let startIndex = tk.index
    let lexpr : Either<ExprNode> = (parseFun(tk:tk) >>- ExprNode.self) <|> (parseVariable(tk:tk) >>- ExprNode.self)
    print("%% \(lexpr)")
    var ret : Either<LineNode>
    switch lexpr {
    case let .Fail(err):
        ret = Either.Fail(err)
    case let .Success(node):
        if (!tk.end()) {
            ret = .Fail ("Unexpected token \( tk.consume) at the end of the line")
        } else {
            ret = .Success(LineNode(lhs: node, rhs:nil))
        }
    }
    return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
}

func parseComputation(tk:Tokenizer) -> Either<LineNode> {
    return .Success(LineNode(lhs: NumberNode(val:23.5), rhs:nil))
}

func parseIdentifier(tk:Tokenizer) -> Either<String> {
    let r : Token? = tk.consume()
    var ret : Either<String>
    if let id = r, case let Token.Identifier(st) = id {
        ret = .Success(st)
    }
    else if r == nil {
        ret = .Fail("an Identifier is missing")
    }
    else {
        ret = .Fail("Unexpected Token \(r!) while we expect an Identifier")
    }
    return tk.adjustIndexAndReturn(startIndex: tk.index - 1, ret: ret)
}

func parseFun(tk:Tokenizer)  -> Either<FuncNode> {
    var ret : Either<FuncNode>
    let startIndex = tk.index
    
    let id = parseIdentifier(tk: tk)
    let variable = tk.expect(search: Token.LParenth) <+> parseVariable(tk: tk)
    let parenth = tk.expect(search: Token.RParenth)
    if case let .Success(st) = id , case let .Success(v) = variable, case .Success(true) = parenth{
        ret = .Success(FuncNode(name:st, variable: v))
    }
    else if case let .Fail(e) = (id <+> variable){
            ret = .Fail(e)
    }
    else {
            ret = .Fail("Unreachable")
    }
    return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
}




func parseVariable(tk:Tokenizer) -> Either<VarNode> {
    var ret : Either<VarNode>
    let startIndex = tk.index
    
    let id = parseIdentifier(tk: tk)
    switch id {
    case let .Success(node):
        ret = .Success(VarNode(name: node))
    case let .Fail(str):
        ret = .Fail(str)
    }
    return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
}

/*
 func parseValue(tk:Tokenizer) -> Either<ValueNode> {
 let ret = parseComplex(tk:tk) <|> parseNumber(tk:tk) <|> parseVariable(tk:tk) <|> parseFun(tk:tk) // <|> parseMatrice
 return ret
 }

func parseComplex(tk:Tokenizer) -> Either<ComplexNode> {
    let nbNode = parseNumber(tk: tk)
    let i = tk.expect(search: Token.I)
    switch (i , nbNode) {
    case let (.Success(_), .Success(nb)):
        let ret = ComplexNode(factor: nb.val)
        return .Success(ret)
    case (.Success(_), .Fail(_)):
        let ret = ComplexNode(factor: 1)
        return .Success(ret)
    case let (.Fail(e), .Fail(_)):
        return .Fail(e)
    }
    
}

func parseNumber(tk:Tokenizer) -> Either<NumberNode> {
    let r = tk.consume()
    guard case let .Number(n) = r else {
        return .Fail("Unexpected Token \(r) while we expect a Number")
    }
    return .Success(NumberNode(val: n))
}

func parseParenth(tk:Tokenizer) -> Either<ValueNode> {
    
    let r = tk.expect(search: Token.LParenth) <+> parseValue(tk: tk)
    let rp = tk.expect(search: Token.RParenth)
    return rp <+> r
}

func parseOperation(tk:Tokenizer) throws -> Either<OperationNode> {
    let lhs = try parseValue(tk: tk)
    while true{
        if (tk.index > 0) {
            guard case let Token.Operator(op) = tk.consume() else {
                throw ParseError.UnexpectedToken(unexpected: Token.Operator(""))
            }
            let rhs = parseValue(tk:tk) <|> parseParenth(tk:tk)
        }
    }
}
*/


/*
 class Parser {
 let tk : Tokensbrowser
 init(tks: Tokensbrowser) {
 tk = tks
 }
 
 func parseOperation() -> OperationNode {
 let lhs = parsePrimary()
 // ++
 
 if case let .Operator(op) = tk.consumeToken() {
 let precedence = precedenceTab[op]
 }
 
 
 
 }
 
 func parsePrimary() -> ExprNode? {
 if let ret = parseComplex() as? ExprNode{
 return ret
 }
 else {
 return parseNumber() as? ExprNode
 }
 }
 
 
 func parseNumber() -> NumberNode? {
 if case let .Number(a) = tk.consumeToken() {
 return NumberNode(val: a)
 }
 return nil
 }
 
 func parseComplex() -> ComplexNode?{
 let ret = parseNumber()?.val ?? 1.0
 if case .I = tk.consumeToken() {
 return ComplexNode (factor: ret)
 }
 return nil
 }
 
 /*func parseMatrice() -> [[Float]]? {
 
 return nil
 }*/
 }
 
 */

