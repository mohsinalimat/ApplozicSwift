//
//  ALKChatBar.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Applozic

open class ALKChatBar: UIView, Localizable {

    var configuration: ALKConfiguration!

    public var isMicButtonHidden: Bool!

    public enum ButtonMode {
        case send
        case media
    }

    public enum ActionType {
        case sendText(UIButton,String)
        case chatBarTextBeginEdit()
        case chatBarTextChange(UIButton)
        case sendVoice(NSData)
        case startVideoRecord()
        case startVoiceRecord()
        case showImagePicker()
        case showLocation()
        case noVoiceRecordPermission()
        case mic(UIButton)
        case more(UIButton)
        case cameraButtonClicked(UIButton)
    }

    public var action: ((ActionType) -> ())?

    open var poweredByMessageLabel: ALHyperLabel = {
        let label = ALHyperLabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.darkGray
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy open var soundRec: ALKAudioRecorderView = {
        let view = ALKAudioRecorderView(frame: CGRect.zero, configuration: self.configuration)
        view.layer.masksToBounds = true
        return view
    }()

    /// A header view which will be present on top of the chat bar.
    /// Use this to add custom views on top. It's default height will be 0.
    /// Make sure to set the height using `headerViewHeight` property.
    open var headerView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        view.accessibilityIdentifier = "Header view"
        return view
    }()

    /// Use this to set `headerView`'s height. Default height is 0.
    open var headerViewHeight: Double = 0 {
        didSet {
            headerView.constraint(withIdentifier: ConstraintIdentifier.headerViewHeight.rawValue)?.constant = CGFloat(headerViewHeight)
        }
    }

    open let textView: ALKChatBarTextView = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let tv = ALKChatBarTextView()
        tv.setBackgroundColor(UIColor.color(.none))
        tv.scrollsToTop = false
        tv.autocapitalizationType = .sentences
        tv.accessibilityIdentifier = "chatTextView"
        tv.typingAttributes = [NSAttributedStringKey.paragraphStyle.rawValue: style, NSAttributedStringKey.font.rawValue: UIFont.font(.normal(size: 16.0))]
        return tv
    }()

    open var frameView: UIImageView = {

        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = false
        return view
    }()

    open var grayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy open var placeHolder: UITextView = {

        let view = UITextView()
        view.setFont(UIFont.font(.normal(size: 14)))
        view.setTextColor(.color(Color.Text.gray9B))
        view.text = localizedString(forKey: "ChatHere", withDefaultValue: SystemMessage.Information.ChatHere, fileName: configuration.localizedStringFileName)
        view.isUserInteractionEnabled = false
        view.isScrollEnabled = false
        view.scrollsToTop = false
        view.setBackgroundColor(.color(.none))
        return view
    }()

    open var micButton: AudioRecordButton = {
        let button = AudioRecordButton(frame: CGRect())
        button.layer.masksToBounds = true
        button.accessibilityIdentifier = "MicButton"
        return button
    }()

    open var photoButton: UIButton = {

        let bt = UIButton(type: .custom)
        var image = UIImage(named: "photo", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    open var galleryButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "gallery", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        return button
    }()

    open var plusButton: UIButton = {

        let bt = UIButton(type: .custom)
        var image = UIImage(named: "icon_more_menu", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    open var locationButton: UIButton = {

        let bt = UIButton(type: .custom)
        var image = UIImage(named: "location_new", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    open var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "showKeyboard", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()

    open var lineImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "line", in: Bundle.applozic, compatibleWith: nil))
        return imageView
    }()

    lazy open var sendButton: UIButton = {
        let bt = UIButton(type: .custom)
        var image = configuration.sendMessageIcon
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        bt.accessibilityIdentifier = "sendButton"

        return bt
    }()

    open var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        return view
    }()

    open var bottomGrayView: UIView = {
        let view = UIView()
        view.setBackgroundColor(.background(.grayEF))
        view.isUserInteractionEnabled = false
        return view
    }()

    open var videoButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "video", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        return button
    }()

    private enum ConstraintIdentifier: String {
        case mediaBackgroudViewHeight = "mediaBackgroudViewHeight"
        case poweredByMessageHeight = "poweredByMessageHeight"
        case headerViewHeight = "headerViewHeight"
    }

    @objc func tapped(button: UIButton) {
        switch button {
        case sendButton:
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.lengthOfBytes(using: .utf8) > 0 {
                action?(.sendText(button,text))
            }
            break
        case plusButton:
            action?(.more(button))
            break
        case photoButton:
            action?(.cameraButtonClicked(button))
            break

        case videoButton:
            action?(.startVideoRecord())
            break
        case galleryButton:
            action?(.showImagePicker())
            break
        case locationButton:
            action?(.showLocation())
        case chatButton:
            textView.becomeFirstResponder()

        default: break

        }
    }

    fileprivate func toggleKeyboardType(textView: UITextView) {

        textView.keyboardType = .asciiCapable
        textView.reloadInputViews()
        textView.keyboardType = .default;
        textView.reloadInputViews()
    }

    private weak var comingSoonDelegate: UIView?

    var chatIdentifier: String?

    private func initializeView(){
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            textView.textAlignment = .right
        }

        micButton.setAudioRecDelegate(recorderDelegate: self)
        soundRec.setAudioRecViewDelegate(recorderDelegate: self)
        textView.delegate = self
        backgroundColor = .background(.grayEF)
        translatesAutoresizingMaskIntoConstraints = false

        plusButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)

        setupConstraints()

        if configuration.hideLineImageFromChatBar {
            lineImageView.isHidden = true
        }
    }

    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }

    open func clear() {
        textView.text = ""
        clearTextInTextView()
        toggleKeyboardType(textView: textView)
    }

    func hideMicButton() {
        self.isMicButtonHidden = true
        self.micButton.isHidden = true
        self.sendButton.isHidden = false
    }

    required public init(frame: CGRect, configuration: ALKConfiguration){
        super.init(frame: frame)
        self.configuration = configuration
        self.isMicButtonHidden = configuration.hideAudioOptionInChatBar
        initializeView()
    }

    deinit {
        plusButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        videoButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        galleryButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        chatButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
    }

    private var isNeedInitText = true

    open override func layoutSubviews() {
        super.layoutSubviews()

        if isNeedInitText {

            guard chatIdentifier != nil else {
                return
            }

            isNeedInitText = false
        }

    }

    fileprivate var textViewHeighConstrain: NSLayoutConstraint?
    fileprivate let textViewHeigh: CGFloat = 40.0
    fileprivate let textViewHeighMax: CGFloat = 102.2 + 8.0

    fileprivate var textViewTrailingWithSend: NSLayoutConstraint?
    fileprivate var textViewTrailingWithMic: NSLayoutConstraint?

    private func setupConstraints(
        maxLength: CGFloat = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)) {
        plusButton.isHidden = true

        var bottomAnchor: NSLayoutYAxisAnchor {
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide.bottomAnchor
            } else {
                return self.bottomAnchor
            }
        }

        var buttonSpacing: CGFloat = 30
        if maxLength <= 568.0 { buttonSpacing = 20 } // For iPhone 5
        addViewsForAutolayout(views: [headerView, bottomGrayView, plusButton, photoButton, grayView,  textView, sendButton, micButton, lineImageView, videoButton, galleryButton,locationButton, chatButton, lineView, frameView, placeHolder,soundRec, poweredByMessageLabel])

        lineView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.headerViewHeight.rawValue).isActive = true

        chatButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        chatButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        chatButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        chatButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        photoButton.leadingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: buttonSpacing).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        photoButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        videoButton.leadingAnchor.constraint(equalTo: galleryButton.trailingAnchor, constant: buttonSpacing).isActive = true
        videoButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        videoButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        videoButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        galleryButton.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: buttonSpacing).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        galleryButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        locationButton.leadingAnchor.constraint(equalTo: videoButton.trailingAnchor, constant: buttonSpacing).isActive = true
        locationButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        locationButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        lineImageView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -15).isActive = true
        lineImageView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        lineImageView.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10).isActive = true
        lineImageView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10).isActive = true

        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10).isActive = true

        micButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        micButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        micButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        micButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10).isActive = true

        if isMicButtonHidden {
            micButton.isHidden = true
        }else{
            sendButton.isHidden = true
        }

        textView.topAnchor.constraint(equalTo: poweredByMessageLabel.bottomAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomGrayView.topAnchor, constant: 0).isActive = true
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3).isActive = true
        poweredByMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        poweredByMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        poweredByMessageLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.poweredByMessageHeight.rawValue).isActive = true
        poweredByMessageLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        textView.trailingAnchor.constraint(equalTo: lineImageView.leadingAnchor).isActive = true

        textViewHeighConstrain = textView.heightAnchor.constraint(equalToConstant: textViewHeigh)
        textViewHeighConstrain?.isActive = true

        placeHolder.heightAnchor.constraint(equalToConstant: 35).isActive = true
        placeHolder.centerYAnchor.constraint(equalTo: textView.centerYAnchor, constant: 0).isActive = true
        placeHolder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0).isActive = true
        placeHolder.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0).isActive = true

        soundRec.isHidden = true
        soundRec.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        soundRec.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        soundRec.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0).isActive = true
        soundRec.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0).isActive = true

        frameView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        frameView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0).isActive = true
        frameView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4).isActive = true
        frameView.rightAnchor.constraint(equalTo: rightAnchor, constant: 2).isActive = true

        grayView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 0).isActive = true
        grayView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 0).isActive = true
        grayView.leftAnchor.constraint(equalTo: frameView.leftAnchor, constant: 0).isActive = true
        grayView.rightAnchor.constraint(equalTo: frameView.rightAnchor, constant: 0).isActive = true

        bottomGrayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        bottomGrayView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.mediaBackgroudViewHeight.rawValue).isActive = true
        bottomGrayView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        bottomGrayView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        bringSubview(toFront: frameView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func hideMediaView() {
        bottomGrayView.constraint(withIdentifier: ConstraintIdentifier.mediaBackgroudViewHeight.rawValue)?.constant = 0
        galleryButton.isHidden = true
        locationButton.isHidden = true
        hideAudioOptionInChatBar()
        photoButton.isHidden = true
        chatButton.isHidden = true
        videoButton.isHidden = true
    }

    public func showMediaView() {
        bottomGrayView.constraint(withIdentifier: ConstraintIdentifier.mediaBackgroudViewHeight.rawValue)?.constant = 45
        galleryButton.isHidden = false
        locationButton.isHidden = false
        hideAudioOptionInChatBar()
        photoButton.isHidden = false
        chatButton.isHidden = false
        videoButton.isHidden = false
    }

    public func showPoweredByMessage() {
        poweredByMessageLabel.constraint(withIdentifier: ConstraintIdentifier.poweredByMessageHeight.rawValue)?.constant = 20
    }

    private func changeButton(){
        if soundRec.isHidden {
            soundRec.isHidden = false
            placeHolder.text = nil
            if placeHolder.isFirstResponder {
                placeHolder.resignFirstResponder()
            } else if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
        } else {
            micButton.isSelected = false
            soundRec.isHidden = true
            placeHolder.text = localizedString(forKey: "ChatHere", withDefaultValue: SystemMessage.Information.ChatHere, fileName: configuration.localizedStringFileName)
        }
    }

    func stopRecording() {
        soundRec.userDidStopRecording()
        micButton.isSelected = false
        soundRec.isHidden = true
        placeHolder.text = localizedString(forKey: "ChatHere", withDefaultValue: SystemMessage.Information.ChatHere, fileName: configuration.localizedStringFileName)
    }

    func hideAudioOptionInChatBar(){
        if isMicButtonHidden{
            micButton.isHidden = true
        }else{
            micButton.isHidden = false
        }
    }

    func toggleButtonInChatBar(hide: Bool){
        if !isMicButtonHidden{
            self.sendButton.isHidden = hide
            self.micButton.isHidden = !hide
        }
    }

    func toggleUserInteractionForViews(enabled: Bool){
        micButton.isUserInteractionEnabled = enabled
        sendButton.isUserInteractionEnabled = enabled
        soundRec.isUserInteractionEnabled = enabled
        photoButton.isUserInteractionEnabled = enabled
        videoButton.isUserInteractionEnabled = enabled
        locationButton.isUserInteractionEnabled = enabled
        galleryButton.isUserInteractionEnabled = enabled
        plusButton.isUserInteractionEnabled = enabled
        chatButton.isUserInteractionEnabled = enabled
        textView.isUserInteractionEnabled = enabled
    }

    func disableChat() {
        toggleUserInteractionForViews(enabled: false)

        //change text from "chat here" to "you are not allowed to chat"
        placeHolder.text = localizedString(forKey: "NotPartOfGroup", withDefaultValue: SystemMessage.Information.NotPartOfGroup, fileName: configuration.localizedStringFileName)
    }

    func enableChat() {
        toggleUserInteractionForViews(enabled: true)

        //change text from "you are not allowed to chat" to "chat here"
        placeHolder.text = NSLocalizedString("ChatHere", value: SystemMessage.Information.ChatHere, comment: "")
    }
}

extension ALKChatBar: UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        guard var text = textView.text as NSString? else {
            return true
        }

        text = text.replacingCharacters(in: range, with: string) as NSString

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let font = textView.font ?? UIFont.font(.normal(size: 14.0))
        let attributes = [NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.font: font]
        let tv = UITextView(frame: textView.frame)
        tv.attributedText = NSAttributedString(string: text as String, attributes:attributes)

        let fixedWidth = textView.frame.size.width
        let size = tv.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        if let textViewHeighConstrain = self.textViewHeighConstrain, size.height != textViewHeighConstrain.constant  {

            if size.height < self.textViewHeighMax {
                textViewHeighConstrain.constant = size.height > self.textViewHeigh ? size.height : self.textViewHeigh
            } else if textViewHeighConstrain.constant != self.textViewHeighMax {
                textViewHeighConstrain.constant = self.textViewHeighMax
            }

            textView.layoutIfNeeded()
        }

        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.placeHolder.isHidden = !textView.text.isEmpty
        self.placeHolder.alpha = textView.text.isEmpty ? 1.0 : 0.0

        toggleButtonInChatBar(hide: textView.text.isEmpty)
        if let selectedTextRange = textView.selectedTextRange {
            let line = textView.caretRect(for: selectedTextRange.start)
            let overflow = line.origin.y + line.size.height  - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top )

            if overflow > 0 {
                var offset = textView.contentOffset;
                offset.y += overflow + 8.2 // leave 8.2 pixels margin

                textView.setContentOffset(offset, animated: false)
            }
        }
        action?(.chatBarTextChange(photoButton))
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        action?(.chatBarTextBeginEdit())
    }

    public func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text.isEmpty {
            toggleButtonInChatBar(hide: true)
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0

                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }

                    weakSelf.textViewHeighConstrain?.constant = weakSelf.textViewHeigh
                    UIView.animate(withDuration: 0.15) {
                        weakSelf.layoutIfNeeded()
                    }
                }
            }
        }

        //clear inputview of textview
        textView.inputView = nil
        textView.reloadInputViews()
    }

    fileprivate func clearTextInTextView() {
        if textView.text.isEmpty {
            toggleButtonInChatBar(hide: true)
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0

                textViewHeighConstrain?.constant = textViewHeigh
                layoutIfNeeded()
            }
        }
        textView.inputView = nil
        textView.reloadInputViews()
    }
}

extension ALKChatBar: ALKAudioRecorderProtocol {

    public func startRecordingAudio() {
        changeButton()
        action?(.startVoiceRecord())
        soundRec.userDidStartRecording()
    }

    public func finishRecordingAudio(soundData: NSData) {
        textView.resignFirstResponder()
        if soundRec.isRecordingTimeSufficient(){
            action?(.sendVoice(soundData))
        }
        stopRecording()
    }

    public func cancelRecordingAudio() {
        stopRecording()
    }

    public func permissionNotGrant() {
        action?(.noVoiceRecordPermission())
    }

    public func moveButton(location: CGPoint) {
        soundRec.moveView(location: location)
    }

}

extension ALKChatBar: ALKAudioRecorderViewProtocol {

    public func cancelAudioRecording() {
        micButton.cancelAudioRecord()
        stopRecording()
    }
}
