

import UIKit
import Firebase
import FirebaseAuth

class MasterViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var logInOutKey: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contents == self {
            if let gvc = secondaryViewController.contents as? GameViewController, gvc.image == nil {
                return true
            }
        }
        return false
    }
    
    @IBAction func loginLogoutTouched(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
}

extension UIViewController {
    var contents : UIViewController {
        if let navcon = self as? UINavigationController{
            return navcon.visibleViewController ?? self
        }
        else{
            return self
        }
    }
}


