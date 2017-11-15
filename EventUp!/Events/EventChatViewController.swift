//
//  EventChatViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/29/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import Photos

final class EventChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var event: Event!
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.edgesForExtendedLayout = []
        senderId = Auth.auth().currentUser!.uid
        senderDisplayName = Auth.auth().currentUser!.email!
        // Do any additional setup after loading the view.
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        EventUpClient.sharedInstance.sendMessage(event: event, message: messageItem, success: {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()
            self.isTyping = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func observeMessages() {
        EventUpClient.sharedInstance.getMessages(event: event, success: { (message) in
            if let id = message["senderId"] as? String, let name = message["senderName"] as? String, let text = message["text"] as? String, text.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private lazy var userIsTypingRef: DatabaseReference = Database.database().reference().child("chats").child(event.uid).child("typingIndicator").child(self.senderId)
    
    private lazy var usersTypingQuery: DatabaseQuery =
        Database.database().reference().child("chats").child(event.uid).child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        let typingIndicatorRef = Database.database().reference().child("chats").child(event.uid).child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
}
