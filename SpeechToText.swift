//
//  SpeechToText.swift
//  FlashCards
//
//  Created by Sam Black on 9/19/23.
//

import Foundation
import UIKit
import Speech

class SpeechToText {
    
    static let shared = SpeechToText()
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Or your preferred locale
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                //switch authStatus {
               // case .authorized:
                    // Permission granted, you can start speech recognition
                //case .denied:
                    // User denied access to speech recognition
                //case .restricted:
                    // Speech recognition restricted on this device
                //case .notDetermined:
                    // Not determined, request not yet processed
                //@unknown default:
                    // Handle unknown cases
                //}
            }
        }
    }
    
    func startRecording() {
        if isRecording {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
        } else {
            recognitionTask?.cancel()
            recognitionTask = nil
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create request") }
            
            isRecording = true
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    // Handle the recognized text
                    let recognizedText = result.bestTranscription.formattedString
                    print(recognizedText)
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("There was an issue starting the audio engine.")
            }
        }
    }
    
}
