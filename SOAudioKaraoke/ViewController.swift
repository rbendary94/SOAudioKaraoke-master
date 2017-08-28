//
//  ViewController.swift
//  SOAudioKaraoke
//
//  Created by Hitesh on 12/8/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import AVFoundation
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var audioRecorder:AVAudioRecorder!
    
    //Setting for recorder
    let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                          AVEncoderBitRateKey: 16,
                          AVNumberOfChannelsKey : 2,
                          AVSampleRateKey: 44100.0] as [String : Any]
    
    
    var audioPlayer:AVAudioPlayer!
    
    var audioPlayerRecorded:AVAudioPlayer!
    var currentTrack = 0
    
    var arrTracks = ["1", "2", "Adele - Skyfall Lyrics on screen", "3", "4", "5", "6", "7", "8", "9", "10"]
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBackground.backgroundColor = UIColor(patternImage: UIImage(named: "musicBackround.jpg")!)
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.isStatusBarHidden=false;
        btnStop.isEnabled = false
        
        self.prepareRecorder()
        self.initilizePlayer()
        
        let userInfoDict =  UserDefaults.standard.dictionary(forKey: "userInfoDict")
//        print("YAYYYY ===>" , UserDefaults.standard.dictionary(forKey: "userInfoDict"))
        let name = (userInfoDict?["name"] as? String) ?? ""
        let url = (userInfoDict?["picUrlSmall"] as? String) ?? ""
   
        userName.text = name
        
        print("YAYY ==>",url)
        
        let url_image = URL(string: url)
        let data = try? Data(contentsOf: url_image! as URL)
        userPic.image = UIImage(data: data!)
        
        userPic.layer.cornerRadius = userPic.frame.size.width * 0.5
        userPic.layer.borderWidth = 1.5
        userPic.layer.borderColor = UIColor.white.cgColor
        userPic.clipsToBounds = true
    }
  
    @IBAction func logoutFb(_ sender: Any) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        print("user logged out from facebook")
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        present(vc,animated: true,completion: nil)
    }
    func prepareRecorder() {
        // getting URL path for audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0]
        let soundFilePath = (docDir as NSString).appendingPathComponent("sound.caf")
        let soundFileURL = URL(fileURLWithPath: soundFilePath)
        print(soundFilePath)
        
        
        var error : NSError?
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            error = error1
        }
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }
        do {
            audioRecorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings as [String : AnyObject])
        } catch let error1 as NSError {
            error = error1
            audioRecorder = nil
        }
        
        print("audioRecorder.currentTime ", audioRecorder.currentTime)
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }else{
            audioRecorder?.prepareToRecord()
        }
    }
    
    //MARK: Audio player initilizer with some bundled audio files
    func initilizePlayer() {
        let strTrack = arrTracks[currentTrack] as String
        let audioFilePath = Bundle.main.path(forResource: strTrack, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = URL(fileURLWithPath: audioFilePath!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl, fileTypeHint: nil)

            } catch {
                print("????")
            }
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            
        } else {
            print("audio file is not found")
        }
    }
    

    //MARK: Start Recording
    @IBAction func actionStartRecord(_ sender: AnyObject) {
        if !audioRecorder.isRecording {
            btnPlay.isEnabled = true
            audioPlayer.play()
            audioRecorder?.record()
            btnRecord.setTitle("Stop", for: UIControlState())
        } else {
            //Stop audio
            btnPlay.isEnabled = true
            self.initilizePlayer()
            audioRecorder?.stop()
            btnRecord.setTitle("Record", for: UIControlState())
        }
    }
    

    
    
    //MARK: Start and Pause button action
    @IBAction func actionPlaySound(_ sender: UIButton) {
        
//        if audioRecorder?.isRecording == false {
            if audioPlayer.isPlaying == false {
                
                var error : NSError?
                
                do {
                    audioPlayerRecorded = try AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                } catch let error1 as NSError {
                    error = error1
                    audioPlayer = nil
                }
                
                audioPlayer?.delegate = self
                
                if let err = error{
                    print("audioPlayer error: \(err.localizedDescription)")
                }else{
                    audioPlayer?.play()
                    audioPlayerRecorded?.play()
                    //
                }
                
                btnPlay.setTitle("Pause", for: UIControlState())
                btnRecord.isEnabled = false
                self.startTimer()
            } else {
                audioPlayer.pause()
                btnPlay.setTitle("Play", for: UIControlState())
                btnRecord.isEnabled = true
                self.stopTimer()
            }
//        }
        
        btnStop.isEnabled = true
    }

    

    //MARK: Update slider
    func updateSlider() {
//        print("audioPlayer.currentTime", "audioPlayer.duration")
//        print(audioPlayer.currentTime, audioPlayer.duration)
        slider.maximumValue = Float(audioPlayer.duration)
        slider.value = Float(audioPlayer.currentTime)
        //slider.value = normalizedTime
        
        //get phrase at this second from dictionary
        //if !nill -> set text of phrase label
        //else -> keep as is
        
        do{
            let lyricContent = try String(contentsOfFile: Bundle.main.path(forResource: "Adele - Skyfall Lyrics on screen", ofType: "lrc")!, encoding: String.Encoding.utf8)
            let lrcParser = DPBasicLRCParser()
            let lyricObject = lrcParser.parseLyricWithString(lyricContent)
            
//             let newCurrentTime = Int(audioPlayer.currentTime * 100)
            
            let myDouble = audioPlayer.currentTime
            let doubleStr = String(format: "%.2f", myDouble) // "3.14"
            
            
            print("FORMATTED " ,doubleStr)
            
            if let phrase = lyricObject.lyricContent[doubleStr]{
                print("--------------")
                print(doubleStr,"   ",phrase)
                phraseLabel.text = phrase
                print("--------------")
            }
           
           
            
            
        }catch{
            print("error")
        }
        
        
    }
    
    
    //MARK: Action for play next track
    @IBAction func actionNextTrack(_ sender: UIButton) {
        self.playNextTrack()
    }
    
    
    func playNextTrack() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        
        currentTrack += 1
        if currentTrack >= arrTracks.count {
            currentTrack = 0
        }
        self.initilizePlayer()
        audioPlayer?.play()
    }
    
    //MARK: Action for play previous track
    @IBAction func actionPreviousTrack(_ sender: UIButton) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        currentTrack -= 1
        if currentTrack < 0 {
            currentTrack = arrTracks.count - 1
        }
        
        self.initilizePlayer()
        audioPlayer.play()
    }
    
    
    
    //MARK: Action for play previous track
    @IBAction func actionStop(_ sender: UIButton) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            self.stopTimer()
        }
        btnRecord.isEnabled = true
        btnPlay.setTitle("Play", for: UIControlState())
        btnStop.isEnabled = false
        slider.value = 0.0
    }
    
    
    //Mark: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            //can perform next action
            //self.playNextTrack()
            self.initilizePlayer()
            btnPlay.setTitle("Play", for: UIControlState())
            btnRecord.isEnabled = true
            btnStop.isEnabled = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        btnPlay.isEnabled = true
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        btnPlay.isEnabled = true
        print("audio Recorder Did Finish Recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
    
    
    //MARK: Timer stop and start for update slider for time
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer.isValid == true {
            timer.invalidate()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

