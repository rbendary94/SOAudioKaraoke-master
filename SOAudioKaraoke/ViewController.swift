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
    @IBOutlet weak var currentTrackTimeLabel: UILabel!
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
    
    var arrTracks =  "Adele - Skyfall Lyrics on screen"
    var timer = Timer()
    var timerSlider = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBackground.backgroundColor = UIColor(patternImage: UIImage(named: "musicBackround.jpg")!)
        btnStop.isEnabled = false

        customizeSlider()
        getUserInfoFromFB()
        
        self.prepareRecorder()
        self.initilizePlayer()
 
    }
    
    func customizeSlider(){
        
        let ratio : CGFloat = 0.4
        let thumbImage = UIImage(named: "slider-thumb")
        let size = CGSize(width: (thumbImage?.size.width)! * ratio , height: (thumbImage?.size.height)! * ratio)
        self.slider.setThumbImage(imageWithImage(image: thumbImage!, scaledToSize: size), for:  .normal)
        self.slider.setThumbImage(imageWithImage(image: thumbImage!, scaledToSize: size), for:  .highlighted)
        
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getUserInfoFromFB(){
        
        let userInfoDict =  UserDefaults.standard.dictionary(forKey: "userInfoDict")
        let name = (userInfoDict?["name"] as? String) ?? ""
        let url = (userInfoDict?["picUrlSmall"] as? String)
        
        userName.text = name
        print("YAYY ==> url ",url ?? "url fady")
        if((url) != nil){
            let url_image = URL(string: url!)
            let data = try? Data(contentsOf: url_image! as URL)
            userPic.image = UIImage(data: data!)
        }
        
        
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
        let strTrack = arrTracks
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
            btnPlay.isEnabled = false
            btnStop.isEnabled = true
            btnRecord.isEnabled = false
            
            audioPlayer.play()
            audioRecorder?.record()
            self.startTimer()
            self.startSliderTimer()
            
        }
    }

    //MARK: Start and Pause button action
    @IBAction func actionPlaySound(_ sender: UIButton) {
        
        //Nothing is playing
        if audioPlayer.isPlaying == false {
            var error : NSError?
            audioPlayer?.delegate = self
                
            if let err = error{
                print("audioPlayer error: \(err.localizedDescription)")
            }else{
                audioPlayer?.play()
                audioPlayerRecorded?.play()
            }
                
            btnPlay.setImage(#imageLiteral(resourceName: "icons8-Pause"), for: UIControlState())
            btnRecord.isEnabled = false
            self.startTimer()
            self.startSliderTimer()
        } else {
            audioPlayer.pause()
            if(audioPlayerRecorded != nil){
                 audioPlayerRecorded.pause()
            }
           
            btnPlay.setImage(#imageLiteral(resourceName: "icons8-Play"), for: UIControlState())
            btnRecord.isEnabled = false
            self.stopTimer()
        }

        btnStop.isEnabled = true
    }
    
    //MARK: Action for play previous track
    @IBAction func actionStop(_ sender: UIButton) {
       
        if audioRecorder != nil {
            self.audioRecorderDidFinishRecording(audioRecorder,successfully: true)
        }
        
        
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            self.initilizePlayer()
            audioRecorder?.stop()
            self.stopTimer()
    
        }
        btnStop.isEnabled = false
        btnPlay.isEnabled = true
        btnRecord.isEnabled = true
        
        btnPlay.setImage(#imageLiteral(resourceName: "icons8-Play"), for: UIControlState())
        slider.value = 0.0
        phraseLabel.text = ""
        currentTrackTimeLabel.text = "00:00"
    
    }
    
    func updateSlider(){
        
        slider.maximumValue = Float(audioPlayer.duration)
        slider.value = Float(audioPlayer.currentTime)
        let minutes = floor(audioPlayer.currentTime/60)
        let seconds = Int(round(audioPlayer.currentTime - minutes * 60))

        var minStr = ""
        if(minutes < 10){
            minStr = "0"
        }
        else{
            minStr = ""
        }
        var secondsStr = ""
        if(seconds < 10){
            secondsStr = "0"
        }
        else{
            secondsStr = ""
        }
       
        DispatchQueue.main.async {
            self.currentTrackTimeLabel.text = "\(minStr)\(Int(minutes)):\(secondsStr)\(seconds)"
        }
        
    }
    
    //MARK: Update slider
    func updateLyrics() {
        
        do{
            let lyricContent = try String(contentsOfFile: Bundle.main.path(forResource: "Adele - Skyfall Lyrics on screen", ofType: "lrc")!, encoding: String.Encoding.utf8)
            let lrcParser = DPBasicLRCParser()
            let lyricObject = lrcParser.parseLyricWithString(lyricContent)
            
            let myDouble = audioPlayer.currentTime
            let doubleStr = String(format: "%.2f", myDouble) // "3.14"
            
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
    
    //Mark: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            self.initilizePlayer()
            btnPlay.setImage(#imageLiteral(resourceName: "icons8-Play"), for: UIControlState())
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
        var error : NSError?
        do {
            audioPlayerRecorded = try AVAudioPlayer(contentsOf: (recorder.url))
            
        }
        catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        audioPlayerRecorded.stop()
        audioRecorder.stop()
        print("audio Recorder Did Finish Recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
    
    //MARK: Timer stop and start for update slider for time
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateLyrics), userInfo: nil, repeats: true)
    }
    func startSliderTimer(){
    
          timerSlider = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer.isValid == true {
            timer.invalidate()
        }
        if timerSlider.isValid == true {
            timerSlider.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

