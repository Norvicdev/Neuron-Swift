//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/27/20.
//

import Foundation

public struct TrainingData: Equatable {
  public var data: [Float]
  public var correct: [Float]
  
  public init(data dat: [Float], correct cor: [Float]) {
    self.data = dat
    self.correct = cor
  }
}

public struct ConvTrainingData: Equatable {
  public var data: [[[Float]]]
  public var label: [Float]
  
  public init(data: [[[Float]]], label: [Float]) {
    self.data = data
    self.label = label
  }
}
