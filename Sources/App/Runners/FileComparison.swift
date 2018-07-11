//
//  FileComparison.swift
//  agrader
//
//  Created by Ant on 26/08/2017.
//
//

import Foundation

func trim(_ input: String) -> String {
    return input.trimmingCharacters(in: .whitespacesAndNewlines)
}

func standardiseNewlines(_ input: String) -> String {
    return input.replacingOccurrences(of: "\r\n", with: "\n")
}

func prepareOutput(_ string: String, ignoreWhitespace: Bool = false, ignoreNewlines: Bool = false) -> String {
    return trim(standardiseNewlines(string))
}

func isExactMatch(expected: String, actual: String) -> Bool {
    return expected == actual
}

func isEndsWithMatch(expected: String, actual: String) -> Bool {
    return actual.hasSuffix(expected)
}
