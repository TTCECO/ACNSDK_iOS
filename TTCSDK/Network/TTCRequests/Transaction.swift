// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct Transaction {
    let from: String        // from address
    let to: String          // to address
    let gasLimit: BigInt    // gas
    let gasPrice: BigInt    // gasPrice
    let value: BigInt       // value
    let nonce: BigInt       // nonce
    let data: Data          // data
    let chainID: BigInt     // version
}
