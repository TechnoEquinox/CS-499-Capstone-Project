//
//  JSON.swift
//  Inventory App
//
//  Created by Connor Bailey on 12/4/25.
//

import Foundation

public var jsonDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .useDefaultKeys
    return decoder
}

public var jsonEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .useDefaultKeys
    return encoder
}
