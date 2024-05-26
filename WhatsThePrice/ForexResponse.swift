//
//  ForexResponse.swift
//  WhatsThePrice
//
//  Created by Jannat Bedi on 26/5/24.
//

import Foundation

struct ForexResponse: Decodable {
    let conversion_rates: [String: Double]
}
