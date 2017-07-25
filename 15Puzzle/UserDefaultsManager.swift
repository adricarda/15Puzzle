
//  Created by Adri on 23/05/17.


import Foundation

class UserDefaultsManager {

    private static let selectedImage = "selectedImage"
    private static let stateSwitchSound = "stateSwitchSound"
    private static let urlOfTheImage = "urlOfTheImage"
    
    static var imageIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: selectedImage)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedImage)
        }
    }
    
    static var soundSwitchState: Bool {
        get {
            return UserDefaults.standard.bool(forKey: stateSwitchSound)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: stateSwitchSound)
        }
    }
    
    static var imageUrl: String {
        get {
            return UserDefaults.standard.string(forKey: urlOfTheImage) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: urlOfTheImage)
        }
    }
    
    
}

