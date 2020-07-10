//
//  Axon.swift
//  Neuron
//
//  Created by William Vabrinskas on 7/8/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit

public struct Nucleus {
  public var learningRate: CGFloat = 0.1
  public var bias: CGFloat = 0.1
  public var activationType: Activation = .reLu
  
  public init(learningRate: CGFloat,
              bias: CGFloat,
              activationType: Activation) {
    self.learningRate = learningRate
    self.bias = bias
    self.activationType = activationType
  }
}
