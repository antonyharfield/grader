import Foundation
import Vapor

protocol ViewContextRepresentable {
    var common: Future<CommonViewContext>? { get set }
}

typealias ViewContext = ViewContextRepresentable & Encodable
