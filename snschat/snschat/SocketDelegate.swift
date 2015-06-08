//
//  SocketDelegate.swift
//  snschat
//
//  Created by Erik Brandsma on 08/06/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation

class SocketDelegate {
    var servingChatCell: Bool = true
    var chatCell: ChatCell?
    var chatController: ChatController?
    
    init(){
        println("AANMAKEN VAN DIE SOCKETDELEGATE")
    }
    
    func switchToChatCell(){
        self.servingChatCell = true
        println("switchToChatCell - \(self.servingChatCell)")
    }
    
    func switchToController(){
        self.servingChatCell = false
        println("switchToController - \(self.servingChatCell)")
    }
    
    func receiveMessage(message: [AnyObject]){
        println("Message - \(self.servingChatCell)")
        if(self.servingChatCell){
            println("ReceivedMessage - ChatCell")
            chatCell!.receiveMessage(message)
        } else {
            println("ReceivedMessage - Controller")
            chatController!.receiveMessage(message)
        }
    }
    
    func receiveIsTyping(){
        println("IsTyping - \(self.servingChatCell)")
        if(self.servingChatCell){
            println("Is typing - ChatCell")
            chatCell!.receiveIsTypingEvent()
        } else {
            println("Is typing - Controller")
            chatController!.receiveIsTypingEvent()
        }
    }
    
    func receiveStoppedTyping(){
        println("StoppedTyping - \(self.servingChatCell)")
        if(servingChatCell){
            println("Stopped typing - ChatCell")
            chatCell!.receiveStoppedTypingEvent()
        } else {
            println("Stopped typing - Controller")
            chatController!.receiveStoppedTypingEvent()
        }
    }
}