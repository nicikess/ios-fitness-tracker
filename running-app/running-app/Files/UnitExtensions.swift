import Foundation

//Diese Klasse ändert die Einheit "Speed (distance per unit time)" in die Einheit "Pace (time per unit distance)"
//siehe extension unten!


/*Warum braucht es das? Aus der Doku zititert: "Before you can extend UnitSpeed to convert to and from a pace measurement,
 you must create a UnitConverter that can handle the math. Subclassing UnitConverter requires that you implement
 baseUnitValue(fromValue:) and value(fromBaseUnitValue:)."*/

class UnitConverterPace: UnitConverter {
  private let coefficient: Double
  
  init(coefficient: Double) {
    self.coefficient = coefficient
  }
  
  override func baseUnitValue(fromValue value: Double) -> Double {
    return reciprocal(value * coefficient)
  }
  
  override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
    return reciprocal(baseUnitValue * coefficient)
  }
  
  private func reciprocal(_ value: Double) -> Double {
    guard value != 0 else { return 0 }
    return 1.0 / value
  }
  
}

//Hier wird die tatsächliche umrechnung der Einheiten gemacht mit UnitSpeed
extension UnitSpeed {
  class var secondsPerMeter: UnitSpeed {
    return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
  }
  
  class var minutesPerKilometer: UnitSpeed {
    return UnitSpeed(symbol: "min/km", converter: UnitConverterPace(coefficient: 60.0 / 1000.0))
  }
  
  class var minutesPerMile: UnitSpeed {
    return UnitSpeed(symbol: "min/mi", converter: UnitConverterPace(coefficient: 60.0 / 1609.34))
  }
}
