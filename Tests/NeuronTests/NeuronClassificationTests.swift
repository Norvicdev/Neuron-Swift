import XCTest
@testable import Neuron
import Combine

final class NeuronClassificationTests:  XCTestCase, BaseTestConfig, ModelBuilder {

  public lazy var brain: Brain? = {
    let bias: Float = 0.0001
    
    let brain = Brain(learningRate: 0.01,
                      epochs: 1000,
                      lossFunction: .crossEntropy,
                      lossThreshold: TestConstants.lossThreshold,
                      initializer: .xavierNormal,
                      descent: .mbgd(size: 16),
                      metrics: [.accuracy, .loss, .valLoss])
    
    brain.addInputs(TestConstants.inputs)
    
    for _ in 0..<TestConstants.numOfHiddenLayers {
      brain.add(NormalizedLobeModel(nodes: TestConstants.hidden,
                                    activation: .reLu,
                                    momentum: 0.9,
                                    normalizerLearningRate: 0.01))
    }
    
    brain.add(LobeModel(nodes: TestConstants.outputs, activation: .softmax, bias: bias)) //output layer
        
    brain.logLevel = .none
    
    return brain
  }()
  
  public var trainingData: [TrainingData] = []
  public var validationData: [TrainingData] = []
  
  override func setUp() {
    super.setUp()
    
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }

    if !brain.compiled {
      print("setting up")
      brain.compile()
      XCTAssertTrue(brain.compiled, "Brain not initialized")
      
      self.buildTrainingData()
    }
  }
  
  func buildTrainingData() {
    let num = 600

    for _ in 0..<num {
      trainingData.append(TrainingData(data: ColorType.red.color(), correct: ColorType.red.correctValues()))
      validationData.append(TrainingData(data: ColorType.red.color(), correct: ColorType.red.correctValues()))
      trainingData.append(TrainingData(data: ColorType.green.color(), correct: ColorType.green.correctValues()))
      validationData.append(TrainingData(data: ColorType.green.color(), correct: ColorType.green.correctValues()))
      trainingData.append(TrainingData(data: ColorType.blue.color(), correct: ColorType.blue.correctValues()))
      validationData.append(TrainingData(data: ColorType.blue.color(), correct: ColorType.blue.correctValues()))
    }
    
  }
  
  //MARK: I really dont think we need to test training this is more of a test when building new architecture into the framework
  /// Uncomment out if you want to run a test training with out integrating into an app
//  func testTraining() {
//    XCTAssertTrue(brain != nil, "Brain is empty")
//
//    guard let brain = brain else {
//      return
//    }
//
//    print("Training....")
//    let expectation = XCTestExpectation()
//    
//    let data = (self.trainingData.randomize(), self.validationData.randomize())
//
//    brain.train(dataset: data,
//                complete:  { (metrics) in
//      print(metrics.map { "\($0.key.rawValue): \($0.value)"})
//      expectation.fulfill()
//    })
//    
//    wait(for: [expectation], timeout: 40)
//
//    for i in 0..<ColorType.allCases.count {
//      let color = ColorType.allCases[i]
//
//      let out = brain.feed(input: color.color())
//      print("Guess \(color.string): \(out)")
//
//      XCTAssert(out.max() != nil, "No max value. Training failed")
//
//      let max = out.max
//      if let first = out.firstIndex(of: max) {
//        XCTAssert(max.isNaN == false, "Result was NaN")
//        XCTAssertTrue(first == i, "Color \(color.string) could not be identified")
//      } else {
//        XCTFail("No color to be found...")
//      }
//    }
//    
//    print(brain.exportModelURL())
//  }
//
  //executes in alphabetical order
  func testXport() {
    XCTAssertTrue(brain != nil, "Brain is empty")
    
    guard let brain = brain else {
      return
    }
      
    let url = brain.exportModelURL()
    print("📄 model: \(String(describing: url))")
    XCTAssertTrue(url != nil, "Could not build exported model")
  }
}
