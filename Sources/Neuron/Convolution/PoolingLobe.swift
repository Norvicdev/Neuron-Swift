//
//  File.swift
//  
//
//  Created by William Vabrinskas on 2/18/22.
//

import Foundation
import NumSwift

public class PoolingLobe: ConvolutionalSupportedLobe {
  
  public var neurons: [[Neuron]] = [] //pooling lobes dont need neurons
  public var layer: LayerType = .hidden
  public let activation: Activation = .none
  
  private var inputSize: TensorSize
  private var forwardPooledMaxIndicies: [[(r: Int, c: Int)]] = []
  private var forwardInputs: [[[Float]]] = []
  private var poolingGradients: [[[Float]]] = []
  public var outputSize: TensorSize {
    //pooling will cut the size in half
    return (inputSize.rows / 2, inputSize.columns / 2, inputSize.depth)
  }

  public init(model: PoolingLobeModel) {
    self.inputSize = model.inputSize
  }

  public func feed(inputs: [[[Float]]], training: Bool) -> [[[Float]]] {
    if training {
      forwardPooledMaxIndicies.removeAll()
      forwardInputs = inputs
    }

    let inputShape = inputs.shape
    
    if let r = inputShape[safe: 1],
       let c = inputShape[safe: 0],
       let d = inputShape[safe: 2] {
      inputSize = (r, c, d)
    }
    
    let results = inputs.map { pool(input: $0) }
    return results
  }
  
  public func calculateGradients(with deltas: [[[Float]]]) -> [[[Float]]] {
    poolingGradients.removeAll(keepingCapacity: true)
    
    for i in 0..<deltas.count {
      let delta = deltas[i].flatMap { $0 }
      var modifiableDeltas = delta
      
      var pooledGradients = [Float].init(repeating: 0,
                                         count: inputSize.rows * inputSize.columns).reshape(columns: inputSize.columns)
          
      let indicies = forwardPooledMaxIndicies[i]
      
      indicies.forEach { index in
        pooledGradients[index.r][index.c] = modifiableDeltas.removeFirst()
      }
      
      poolingGradients.append(pooledGradients)
    }
    
    return poolingGradients
  }
  
  public func clear() {
    self.forwardPooledMaxIndicies.removeAll(keepingCapacity: true)
    self.poolingGradients.removeAll(keepingCapacity: true)
    self.neurons.forEach { $0.forEach { $0.clear() } }
  }
  
  public func zeroGradients() {
    self.forwardPooledMaxIndicies.removeAll(keepingCapacity: true)
    self.poolingGradients.removeAll(keepingCapacity: true)
    self.neurons.forEach { $0.forEach { $0.zeroGradients() } }
  }
  
  public func adjustWeights(batchSize: Int) {
    //no op on pooling layer
  }
  
  internal func pool(input: [[Float]]) -> [[Float]] {
    var rowResults: [Float] = []
    var results: [[Float]] = []
    var pooledIndicies: [(r: Int, c: Int)] = []
        
    let rows = inputSize.rows
    let columns = inputSize.columns
        
    for r in stride(from: 0, through: rows, by: 2) {
      guard r < input.count else {
        continue
      }
      rowResults = []
      
      for c in stride(from: 0, through: columns, by: 2) {
        guard c < input[r].count else {
          continue
        }
        let current = input[r][c]
        let right = input[r + 1][c]
        let bottom = input[r][c + 1]
        let diag = input[r + 1][c + 1]
        
        let indiciesToCheck = [(current, r,c),
                               (right ,r + 1, c),
                               (bottom, r, c + 1),
                               (diag, r + 1, c + 1)]
        
        let max = max(max(max(current, right), bottom), diag)
        if let firstIndicies = indiciesToCheck.first(where: { $0.0 == max }) {
          pooledIndicies.append((r: firstIndicies.1, c: firstIndicies.2))
        }
        rowResults.append(max)
      }
      
      results.append(rowResults)
    }
    
    forwardPooledMaxIndicies.append(pooledIndicies)
        
    return results
  }
}
