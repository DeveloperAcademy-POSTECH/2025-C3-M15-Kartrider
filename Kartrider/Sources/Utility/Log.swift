//
//  Log.swift
//  Kartrider
//
//  Created by J on 12/22/25.
//

import Foundation

enum Level: String {
    case debug = "🟦 DEBUG"
    case info = "🟩 INFO"
    case warning = "🟨 WARNING"
    case error = "🟥 ERROR"
}

struct Log {
    
    static func debug() {
        
    }
    
    static func info() {
        
    }
    
    static func warning() {
        
    }
    
    static func error() {
        
    }
    
    private static func log(
        _ message: String,
        level: Level,
        file: String,
        function: String,
        line: Int
    ) {
        
    }
}
