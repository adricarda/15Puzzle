

import UIKit

class SettingsTableViewController: UITableViewController {
    
  //  @IBOutlet weak var Sound: UISwitch!
    
    @IBOutlet weak var imageSelection: UISegmentedControl!
    
    @IBOutlet weak var switchSound: UISwitch!
    
    @IBOutlet weak var labelUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSelection.selectedSegmentIndex = UserDefaultsManager.imageIndex
        switchSound.isOn = UserDefaultsManager.soundSwitchState
        labelUrl.text = UserDefaultsManager.imageUrl
    }
    
    @IBAction func urlTextField(_ sender: UITextField) {
        UserDefaultsManager.imageUrl = labelUrl.text!
        print(labelUrl.text!)
    }
    
    var selectedImage : Int {
        return imageSelection?.selectedSegmentIndex ?? 0
    }
    
    
    @IBAction func updateImage(_ sender: UISegmentedControl) {
        UserDefaultsManager.imageIndex = selectedImage
    }
  
    @IBAction func updateSwitchSound(_ sender: UISwitch) {
        UserDefaultsManager.soundSwitchState = sender.isOn
    }

}
