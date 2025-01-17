//
//  File.swift
//  
//
//  Created by William Vabrinskas on 1/21/21.
//

import XCTest
@testable import Neuron


final class NeuronBaseTests: XCTestCase, BaseTestConfig {
  static var allTests = [
    ("testWeightsAndInputsCountIsEqual", testWeightsAndInputsCountIsEqual),
    ("testWeightNumbers", testWeightNumbers),
    ("testNumberOfLobesMatches", testNumberOfLobesMatches),
    ("testFeedIsntSame", testFeedIsntSame)
  ]
  
  public lazy var brain: Brain? = {
    let bias: Float = 0.001
    
    let brain = Brain(learningRate: 0.01,
                      epochs: 200,
                      lossFunction: .crossEntropy,
                      lossThreshold: TestConstants.lossThreshold,
                      initializer: .xavierNormal)
    
    brain.addInputs(TestConstants.inputs) //input layer
    
    for _ in 0..<TestConstants.numOfHiddenLayers {
      brain.add(LobeModel(nodes: TestConstants.hidden, activation: .reLu, bias: bias)) //hidden layer
    }
    
    brain.add(LobeModel(nodes: TestConstants.outputs, activation: .softmax, bias: bias)) //output layer //need an activation function here other wise outputs will all be the same
    
    brain.logLevel = .none
    
    brain.compile()
    
    return brain
  }()
  
  func testBrainWeights() {
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }
    
    var brainWeights = brain.layerWeights
        
    if let brainFirst = brainWeights.first {
      let replace = [[Float]].init(repeating: [1.0], count: brainFirst.count)
      brainWeights[0] = replace
      
      brain.replaceWeights(weights: brainWeights)
      
      XCTAssert(brain.layerWeights[0] == replace, "Weights did not replace properly")
    }
  
  }
  
  func testFeedIsntSame() {
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }
    
    var previous: [Float] = [Float](repeating: 0.0, count: TestConstants.inputs)
    
    for i in 0..<10 {
      var inputs: [Float] = []
      for _ in 0..<TestConstants.inputs {
        inputs.append(Float.random(in: 0...1))
      }
      
      let out = brain.feed(input: inputs)
      
      print("Feed \(i): \(out)")
      XCTAssertTrue(previous != out, "Result is the same check code...")
      previous = out
    }
    
  }
  

  func testWeightsAndInputsCountIsEqual() {
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }
    
    brain.lobes.forEach { (lobe) in
      lobe.neurons.forEach { (neuron) in
        XCTAssertTrue(neuron.inputValues.count == neuron.weights.count, "Inputs and weights out of sync")
      }
    }
  }
  
  func testNumberOfLobesMatches() {
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }
    
    let inputLayer = brain.lobes.filter({ $0.layer == .input })
    let hiddenLayers = brain.lobes.filter({ $0.layer == .hidden })
    let outputLayer = brain.lobes.filter({ $0.layer == .output })

    XCTAssertTrue(inputLayer.count == 1, "Should only have 1 first layer")

    if let first = inputLayer.first {
      XCTAssertTrue(first.neurons.count == TestConstants.inputs, "Input layer count does not match model")
    }
    
    XCTAssertTrue(hiddenLayers.count == TestConstants.numOfHiddenLayers, "Number of hidden layers does not match model")
    
    hiddenLayers.forEach { (layer) in
      XCTAssertTrue(layer.neurons.count == TestConstants.hidden, "Hidden layer count does not match model")
    }
    
    XCTAssertTrue(outputLayer.count == 1, "Should only have 1 first layer")

    if let first = outputLayer.first {
      XCTAssertTrue(first.neurons.count == TestConstants.outputs, "Output layer count does not match model")
    }
    
  }
  
  func testWeightNumbers() {
    var expected = TestConstants.inputs

    for n in 0..<TestConstants.numOfHiddenLayers {
      if n == 0 {
        expected += (TestConstants.inputs * TestConstants.hidden)
      } else {
        expected += (TestConstants.hidden * TestConstants.hidden)
      }
    }
    
    expected += (TestConstants.hidden * TestConstants.outputs)
    
    let flattenedWeightsArray = flattenedWeights()
    
    XCTAssertTrue(flattenedWeightsArray.count == expected,
                  "got: \(flattenedWeightsArray.count) expected: \(expected)")
  }
  
}
