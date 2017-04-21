//
//  ConsoleIO.swift
//  PanagramTuto
//
//  Created by Celine DANNAPPE on 4/21/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation


class ConsoleIO {
    
    class func printUsage() {
        print ("Usage:")
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\u{001B}[;m\(message)")
        case .error:
            fputs("\u{001B}[0;31m\(message)\n", stderr)
        }
    }
    
    func prompt () {
        fputs("$>", stdout)
    }
    
    func getInput() -> String {
        
        prompt()
        let stdin = FileHandle.standardError
        let inputData = stdin.availableData
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!
        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }
}

enum OutputType {
    case error
    case standard
}
