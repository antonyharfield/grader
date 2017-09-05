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

func isExactMatch(expected: String, actual: String) -> Bool {
    return trim(expected) == trim(actual)
}

func isEndsWithMatch(expected: String, actual: String) -> Bool {
    return trim(actual).hasSuffix(trim(expected))
}
