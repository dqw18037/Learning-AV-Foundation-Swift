//
//  MIT License
//
//  Copyright (c) 2016 Bob McCune http://bobmccune.com/
//  Copyright (c) 2016 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import CoreGraphics

class SampleDataFilter {

    let sampleData: Data

    init(sampleData: Data) {
        self.sampleData = sampleData
    }

    func filteredSamples(for size: CGSize) -> [Float] {

        var filteredSamples = [Float]()

        let sampleCount = sampleData.count / sizeof(Int16.self)
        let binSize = Int(sampleCount / Int(size.width))

        var bytes = [Int16](repeating: 0, count: sampleData.count)

        (sampleData as NSData).getBytes(&bytes, length:sampleData.count * sizeof(Int16.self))

        var maxSample: Int16 = 0

        for i in stride(from: 0, to: sampleCount - 1, by: binSize) {
            var sampleBin = [Int16](repeating: 0, count: binSize)
            for j in 0..<binSize {
                sampleBin[j] = bytes[i + j].littleEndian
            }
            let value = maxValue(in: sampleBin, ofSize: binSize)
            filteredSamples.append(Float(value))
            if value > maxSample {
                maxSample = value
            }
        }

        let scaleFactor = (size.height / 2.0) / CGFloat(maxSample)
        for i in 0..<filteredSamples.count {
            filteredSamples[i] = filteredSamples[i] * Float(scaleFactor)
        }

        return filteredSamples
    }

    func maxValue(in values: [Int16], ofSize size: Int) -> Int16 {
        var maxValue: Int16 = 0
        for i in 0..<size {
            if abs(values[i]) > maxValue {
                maxValue = abs(values[i])
            }
        }
        return maxValue
    }
}

