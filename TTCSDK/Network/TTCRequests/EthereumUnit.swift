// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum EthereumUnit: Int64 {
    case wei = 1
    case kwei = 1_000
    case gwei = 1_000_000_000
    case ether = 1_000_000_000_000_000_000
}

extension EthereumUnit {
    var name: String {
        switch self {
        case .wei: return "Wei"
        case .kwei: return "Kwei"
        case .gwei: return "Gwei"
        case .ether: return "Ether"
        }
    }
}

struct UnitConfiguration {
    static let gasPriceUnit: EthereumUnit = .gwei
    static let gasFeeUnit: EthereumUnit = .ether
}

//https://github.com/ethereumjs/ethereumjs-units/blob/master/units.json
