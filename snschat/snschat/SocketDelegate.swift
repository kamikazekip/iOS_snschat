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

    }
    
    func switchToChatCell(){
        self.servingChatCell = true
    }
    
    func switchToController(){
        self.servingChatCell = false
    }
    
    func receiveMessage(message: [AnyObject]){
        println("Message - \(self.servingChatCell)")
        if(self.servingChatCell){
            chatCell!.receiveMessage(message)
        } else {
            chatController!.receiveMessage(message)
        }
    }
    
    func receiveIsTyping(){
        println("IsTyping - \(self.servingChatCell)")
        if(self.servingChatCell){
            chatCell!.receiveIsTypingEvent()
        } else {
            chatController!.receiveIsTypingEvent()
        }
    }
    
    func receiveStoppedTyping(){
        println("StoppedTyping - \(self.servingChatCell)")
        if(servingChatCell){
            chatCell!.receiveStoppedTypingEvent()
        } else {
            chatController!.receiveStoppedTypingEvent()
        }
    }
}