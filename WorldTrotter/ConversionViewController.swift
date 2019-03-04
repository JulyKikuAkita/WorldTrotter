//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by July on 2/28/19.
//  Copyright © 2019 July. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var celsiusLabel: UILabel!
    @IBOutlet var textField: UITextField!
    var fahrenheitValue: Measurement<UnitTemperature>? {
        didSet {
            updateCelsiusLabel()
        }
    }
    
    let numberFormatter :NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var celsiusValue: Measurement<UnitTemperature>? { //this is computed property
        if let fahrenheitValue = fahrenheitValue {
            return fahrenheitValue.converted(to: .celsius)
        } else {
            return nil
        }
    }
    
    @IBAction func fahrenheitFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text, let number = numberFormatter.number(from: text) {
            fahrenheitValue = Measurement(value: number.doubleValue, unit: .fahrenheit)
        } else {
            fahrenheitValue = nil
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    func updateCelsiusLabel() {
        if let celsiusValue = celsiusValue {
            celsiusLabel.text = numberFormatter.string(from: NSNumber(value: celsiusValue.value))
        } else {
            celsiusLabel.text = "???"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ConversionViewController loaded its view")
        
        updateCelsiusLabel()
    }
    
    //show case of delegation
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // debug purpose
//        print("Current text: \(textField.text)")
//        print("Replacement text: \(string)")
        let currentLocale = Locale.current
        let decimalSeperator = currentLocale.decimalSeparator ?? "."
        
        let existingTextHasDEcimalSeparator = textField.text?.range(of: decimalSeperator)
        let replacementTextHasDecimalSeparator = string.range(of: decimalSeperator)
        
        // avoid more than one decimal point
        if existingTextHasDEcimalSeparator != nil, replacementTextHasDecimalSeparator != nil { return false }
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        
        if hour > 17 || hour < 6 {
            self.view.backgroundColor=UIColor.darkGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // get the hour component of the current time
        let calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        let currentHour = calendar.component(.hour, from: Date())
        
        // Utilize the CGFloat extension above to generate random floats
        var randomFloat: CGFloat {
            get {
                return CGFloat.random()
            }
        }
        
        // Define my colors, including the random color generator at dusk
        let darkColor = UIColor(red: 13/255.0, green: 61/255.0, blue: 91/255.0, alpha: 1.0)
        let morningColor = UIColor(red: 250/255.0, green: 150/255.0, blue: 12/255.0, alpha: 0.6)
        let noonColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 150/255.0, alpha: 1.0)
        let duskColor = UIColor(red: randomFloat, green: randomFloat, blue: randomFloat, alpha: 0.6)
        
        // Switch colors based on the hour of the day
        switch currentHour {
        case 7...10:
            view.backgroundColor = morningColor
        case 11...14:
            view.backgroundColor = noonColor
        case 15...19:
            view.backgroundColor = duskColor
        default:
            view.backgroundColor = darkColor
        }
        
    }
}

public extension CGFloat {
    /// SwiftRandom extension
    public static func random(lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}
