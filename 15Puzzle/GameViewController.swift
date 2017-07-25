//
//  GameViewController.swift
//  FaceIt
//
//  Created by Adri on 22/05/17.

import UIKit
import Firebase
import FirebaseAuth
import AVFoundation

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var currentMove: UILabel!
    @IBOutlet weak var bestScoreTime: UILabel!
    @IBOutlet weak var bestScoreMove: UILabel!
    @IBOutlet weak var b0: UIButton!
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    @IBOutlet weak var b5: UIButton!
    @IBOutlet weak var b6: UIButton!
    @IBOutlet weak var b7: UIButton!
    @IBOutlet weak var b8: UIButton!
    @IBOutlet weak var b9: UIButton!
    @IBOutlet weak var b10: UIButton!
    @IBOutlet weak var b11: UIButton!
    @IBOutlet weak var b12: UIButton!
    @IBOutlet weak var b13: UIButton!
    @IBOutlet weak var b14: UIButton!
    @IBOutlet weak var b15: UIButton!
    
    private let dict : [Int: String] = [
        0: "./batman.png",
        1: "./foglia.png",
        2: "./munch.jpg",
        3: "fromUrl"
    ]
    
    var selectedImageFromPreferences = UserDefaultsManager.imageIndex
    
    var player: AVAudioPlayer?
    
    private var cellState : [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
   
    
    private weak var timer : Timer?
    private var minutes = 0
    private var seconds = 0
    private var fractioms = 0
    private var timerIsStarted = false
    private var move = 0
    
    let ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    private var gameStarted = false
    
    //current empty button
    var current = 16
    
    //number of random steps
    let nsteps = 15
    
    
    private func playSound() {
        let url = Bundle.main.url(forResource: "button", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    

    @IBAction func moveAction(_ sender: UIButton) {
        
        let clear = UIImage()
        let imageToCopy = sender.backgroundImage(for: .normal)
        let tagOfPressedButton = sender.tag
        let oldCurrentButton = self.view.viewWithTag(current) as? UIButton
        
        
        
         //if the empty button is the last batton on the right in his row and the the touched one is on the following line return
        if (tagOfPressedButton-1) % 4 == 0, (current-1) % 4 == 3 {
            return
        }
        
        //if the empty button is the last batton on the left in his row and the the touched one is on the previous line return
        if (tagOfPressedButton-1) % 4 == 3, (current-1) % 4 == 0 {
            return
        }
        
        
        //if the pressed button is a neighbour of the current go on
        if tagOfPressedButton == current-1 || tagOfPressedButton == current+1 || tagOfPressedButton == current-4 || tagOfPressedButton == current+4, tagOfPressedButton < 17 , tagOfPressedButton > 0 {
            
            //activate timer and start game
            if timerIsStarted == false, gameStarted {
                timerIsStarted = true
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    self.seconds += 1
                    if self.seconds == 60{
                        self.seconds = 0
                        self.minutes += 1
                    }
                    let secondsString = self.seconds > 9 ? "\(self.seconds)" : "0\(self.seconds)"
                    let minutesString = self.minutes > 9 ? "\(self.minutes)" : "0\(self.minutes)"
                    self.watchLabel.text = "\(minutesString):\(secondsString)"
                }
            }
            
            //change images
            oldCurrentButton?.setBackgroundImage(imageToCopy, for: .normal)
            sender.setBackgroundImage(clear, for: .normal)
        
            //update cellState
            swap(&cellState[tagOfPressedButton-1],&cellState[current-1])
            
            self.current = tagOfPressedButton
            
            if gameStarted {
                move += 1
                self.currentMove.text = "\(move)"
                if UserDefaultsManager.soundSwitchState {
                    self.playSound()
                }
            }
            
            if checkWin(), gameStarted {
            
                let previousTime = bestScoreTime.text!.components(separatedBy: ":")
                let currentTime = watchLabel.text!.components(separatedBy: ":")
                
                if bestScoreTime.text! == "-" || currentTime[0] < previousTime[0] || (currentTime[0] == previousTime[0] && currentTime[1] < previousTime[1] ) {
                    ref.child("usersRecord").child(userID!).updateChildValues(["score": watchLabel.text!])
                    if bestScoreMove.text! == "-" || move < (Int(bestScoreMove.text!) ?? 0)  {
                        ref.child("usersRecord").child(userID!).updateChildValues(["move": String(move)])
                    }
                    
                }
        
                let alertController = UIAlertController(title: "", message: "You win !", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            }
         
        }
    }
    
    func checkWin() -> Bool {
        for i in 0...15{
            if cellState[i] != i+1{
                return false
            }
        }
        timer?.invalidate()
        timerIsStarted = false
        return true
    }
 
    var getOnePossibleNeighbour : Int {
        get {
            let index = Int(arc4random_uniform(4))
            switch index{
            case 0:
                return current+1
            case 1:
                return current-1
            case 2:
                return current-4
            case 3:
                return current+4
            default:
                return current+1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedImageFromPreferences == 3
        {
            spinner.startAnimating();
            if let url = URL(string : UserDefaultsManager.imageUrl)
            {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContents = try? Data(contentsOf: url)
                    if let imageData = urlContents {
                        // UI stuff is done on the Main Queue...
                        DispatchQueue.main.async {
                            self?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
        else {
            self.image = UIImage(named: dict[selectedImageFromPreferences]!)
        }
    
        //update best score label
        if Auth.auth().currentUser != nil {
            ref.child("usersRecord").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let score = value?["score"] as? String ?? "-"
                let move = value?["move"] as? String ?? "-"
                self.bestScoreTime.text = score
                self.bestScoreMove.text = move
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    var image: UIImage?{
        didSet{
            var blockDimension = CGSize()
            spinner?.stopAnimating();

            if image != nil {
                let width = image!.size.width
                let height = image!.size.height
                blockDimension = CGSize(width: width/4, height: height/4)
            }
            
            let ib0 = image?.createBlock(fromRow: 0, FromColumn: 0, withSize: blockDimension)
            let ib1 = image?.createBlock(fromRow: 0, FromColumn: 1, withSize: blockDimension)
            let ib2 = image?.createBlock(fromRow: 0, FromColumn: 2, withSize: blockDimension)
            let ib3 = image?.createBlock(fromRow: 0, FromColumn: 3, withSize: blockDimension)
            
            let ib4 = image?.createBlock(fromRow: 1, FromColumn: 0, withSize: blockDimension)
            let ib5 = image?.createBlock(fromRow: 1, FromColumn: 1, withSize: blockDimension)
            let ib6 = image?.createBlock(fromRow: 1, FromColumn: 2, withSize: blockDimension)
            let ib7 = image?.createBlock(fromRow: 1, FromColumn: 3, withSize: blockDimension)
            
            let ib8 = image?.createBlock(fromRow: 2, FromColumn: 0, withSize: blockDimension)
            let ib9 = image?.createBlock(fromRow: 2, FromColumn: 1, withSize: blockDimension)
            let ib10 = image?.createBlock(fromRow: 2, FromColumn: 2, withSize: blockDimension)
            let ib11 = image?.createBlock(fromRow: 2, FromColumn: 3, withSize: blockDimension)
            
            let ib12 = image?.createBlock(fromRow: 3, FromColumn: 0, withSize: blockDimension)
            let ib13 = image?.createBlock(fromRow: 3, FromColumn: 1, withSize: blockDimension)
            let ib14 = image?.createBlock(fromRow: 3, FromColumn: 2, withSize: blockDimension)
            
            b0.setBackgroundImage(ib0, for: .normal)
            b1.setBackgroundImage(ib1, for: .normal)
            b2.setBackgroundImage(ib2, for: .normal)
            b3.setBackgroundImage(ib3, for: .normal)
            
            b4.setBackgroundImage(ib4, for: .normal)
            b5.setBackgroundImage(ib5, for: .normal)
            b6.setBackgroundImage(ib6, for: .normal)
            b7.setBackgroundImage(ib7, for: .normal)
            
            b8.setBackgroundImage(ib8, for: .normal)
            b9.setBackgroundImage(ib9, for: .normal)
            b10.setBackgroundImage(ib10, for: .normal)
            b11.setBackgroundImage(ib11, for: .normal)
            
            b12.setBackgroundImage(ib12, for: .normal)
            b13.setBackgroundImage(ib13, for: .normal)
            b14.setBackgroundImage(ib14, for: .normal)
            
            for _ in 0..<nsteps {
                let IdButtonTouched = getOnePossibleNeighbour
                let button = self.view.viewWithTag(IdButtonTouched) as? UIButton
                button?.sendActions(for: UIControlEvents.touchUpInside)
            }
            
            gameStarted = true
            timerIsStarted = false
            move = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        gameStarted = false
        timerIsStarted = false
    }
}

extension UIImage {
    
    var startingPointRow0: CGFloat {
        return CGFloat(0)
    }
    
    var startingPointRow1: CGFloat {
        return CGFloat(size.height-(size.height*3/4))

    }
    
    var startingPointRow2: CGFloat {
        return CGFloat(size.height-(size.height*2/4))
        
    }
    
    var startingPointRow3: CGFloat {
        return CGFloat(size.height-(size.height*1/4))
        
    }
    
    var startingPointColumn0: CGFloat {
        return CGFloat(0)
    }
    
    var startingPointColumn1: CGFloat {
        return CGFloat(size.width-(size.width*3/4))
        
    }
    
    var startingPointColumn2: CGFloat {
        return CGFloat(size.width-(size.width*2/4))
        
    }
    
    var startingPointColumn3: CGFloat {
        return CGFloat(size.width-(size.width*1/4))
        
    }
    
    func createBlock(fromRow row: Int, FromColumn col: Int, withSize s: CGSize) -> UIImage?{
        let x : CGFloat
        let y : CGFloat
        
        switch col{
        case 0 :
            x = startingPointColumn0
        case 1 :
            x = startingPointColumn1
        case 2 :
            x = startingPointColumn2
        case 3 :
            x = startingPointColumn3
        default :
            x = 0
        }
        
        switch row{
        case 0 :
            y = startingPointRow0
        case 1 :
            y = startingPointRow1
        case 2 :
            y = startingPointRow2
        case 3 :
            y = startingPointRow3
        default :
            y = 0
        }
        
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: x, y: y), size: s )) else {return nil}
        return UIImage(cgImage: image)
    }
    
}
