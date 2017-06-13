  //
//  main.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/21/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

var shouldQuit = false
let console = ConsoleIO()
console.writeMessage("welcome in computorV2, enter q to quit")
while (!shouldQuit) {
    let line = console.getInput()
    if (line == "q"){
        shouldQuit = true
    }
    else if (line != ""){
        let tokenizer = Tokenizer(input: line)
        tokenizer.debugTokens()
        let parser = Parser(tkn:tokenizer)
        let tree = parser.parseLine()
        /*print (parse)*/
    }
    
}
  


