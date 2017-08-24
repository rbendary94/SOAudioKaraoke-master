//
//  DPBasicLRCParser.swift
//  DemoLrcParse
//
//  Created by baophan on 2015/07/22.
//  Copyright (c) 2015年 @baophan94. All rights reserved.
//

import UIKit

class DPBasicLRCParser: NSObject {
	
	func parseLyricWithString(_ lrcContent: String) -> DPLyricItem {
		let lyricItem: DPLyricItem = DPLyricItem()
		
		// Read lines of string to array
		let lyricsArray = lrcContent.components(separatedBy: CharacterSet.newlines)
		
      
        for phrase in lyricsArray {
            
            if phrase.hasPrefix("[") {
                if phrase.hasPrefix("[ti:") || phrase.hasPrefix("[ar:") || phrase.hasPrefix("[al:") || phrase.hasPrefix("[by:") {
                    
//                    var character = String(phrase.substring(to: phrase.index(phrase.startIndex, offsetBy: 4)))
//                    
//                    var character2 = String(phrase.substring(to: phrase.index(phrase.endIndex, offsetBy: -1)))
//                    
//                    
//                     var character3 = String(phrase.substring(to: phrase.index(phrase.startIndex, offsetBy: 1)))
//                    
//                    var character4 = String(phrase.substring(to: phrase.index(phrase.startIndex, offsetBy: 3)))
//                    
//                    var introText =
//                        phrase.substring(with: character!.startIndex..<(character2?.startIndex)!)
//                
                 
                    
//                    switch phrase.substring(with: (character3?.startIndex)!..<(character4?.startIndex)!) {
//                    case "ti":
//                        lyricItem.title		= introText
//                    case "ar":
//                        lyricItem.artist	= introText
//                    case "al":
//                        lyricItem.album		= introText
//                    case "by":
//                        lyricItem.by		= introText
//                    default:
//                        print()
//                    }
                }
                else {
                    let characterset = CharacterSet(charactersIn: "[]")
                    let result = phrase.components(separatedBy: characterset)
                    let time = convertTimeToDouble(result[1])
                    let text = result[2]
                    lyricItem.lyricContent[time] = text
                    print("---------------------------------------------------------------------")
                    print(time,text)
                    print("---------------------------------------------------------------------")

                }
            }

        }

		return lyricItem
	}
	
	fileprivate func convertTimeToDouble(_ string:String) -> Double {
		let timeArray = string.components(separatedBy: ":")
		if timeArray.count < 2 {
			return 0
		}
		let min = timeArray[0].floatValue
		let sec = timeArray[1].floatValue
		return (min * 60 + sec)
	}
	
}

class DPLyricItem {
	var title			= ""
	var artist			= ""
	var	by				= ""
	var album			= ""
	var lyricContent	= [Double: String]()
}

extension String {
	var floatValue: Double {
		return (self as NSString).doubleValue
	}
}
