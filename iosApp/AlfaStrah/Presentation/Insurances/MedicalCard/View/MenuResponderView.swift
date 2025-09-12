//
//  MenuResponderView.swift
//  AlfaStrah
//
//  Created by vit on 16.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class MenuResponderView: UIView {
    enum ActionType {
        case rename
        case moreAbout
        case download
        case remove
        case select
        case cancelLoading
        case retryUpload
    }
    
    struct Action {
        let type: ActionType
        let callback: () -> Void
    }
    
    enum ContextMenuAppearance {
        case empty
        case full
        case selectionOnly
        case selectionAndRemoval
        case retryAndRemoval
    }
        
    var actions: [Action] = []
    
    func getActionMenuItems() -> [UIMenuItem] {
        var menuItems: [UIMenuItem] = []
        
        for action in actions {
            switch action.type {
                case .retryUpload:
                    menuItems.append(UIMenuItem(
                         title: NSLocalizedString("medical_card_files_context_menu_retry_upload", comment: ""),
                         action: #selector(retryUpload)
                     ))
                case .select:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_select", comment: ""),
                        action: #selector(selection)
                    ))
                case .rename:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_rename", comment: ""),
                        action: #selector(rename)
                    ))
                case .remove:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_remove", comment: ""),
                        action: #selector(remove)
                    ))
                case .moreAbout:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_more_about", comment: ""),
                        action: #selector(moreAbout)
                    ))
                
                case .download:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_download", comment: ""),
                        action: #selector(moreAbout)
                    ))
                case .cancelLoading:
                    menuItems.append(UIMenuItem(
                        title: NSLocalizedString("medical_card_files_context_menu_cancel_loading", comment: ""),
                        action: #selector(cancelLoading)
                    ))
                
            }
        }
        
        return menuItems
    }

    // MARK: - UIResponder
    override var canBecomeFirstResponder: Bool {
        true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
            case #selector(remove):
                return actions.contains(where: { $0.type == .remove })
            case #selector(rename):
                return actions.contains(where: { $0.type == .rename })
            case #selector(moreAbout):
                return actions.contains(where: { $0.type == .moreAbout })
            case #selector(download):
                return actions.contains(where: { $0.type == .download })
            case #selector(selection):
                return actions.contains(where: { $0.type == .select })
            case #selector(retryUpload):
                return actions.contains(where: { $0.type == .retryUpload })
            case #selector(cancelLoading):
                return actions.contains(where: { $0.type == .cancelLoading })
            default:
                return false
        }
    }

    // MARK: - UIResponderStandardEditActions
    @objc func selection() {
        actions.first(where: { $0.type == .select })?.callback()
    }
    
    @objc func moreAbout() {
        actions.first(where: { $0.type == .moreAbout })?.callback()
    }
    
    @objc func download() {
        actions.first(where: { $0.type == .download })?.callback()
    }

    @objc func rename() {
        actions.first(where: { $0.type == .rename })?.callback()
    }
    
    @objc func cancelLoading() {
        actions.first(where: { $0.type == .cancelLoading })?.callback()
    }

    @objc func remove() {
        actions.first(where: { $0.type == .remove })?.callback()
    }
    
    @objc func retryUpload() {
        actions.first(where: { $0.type == .retryUpload })?.callback()
    }
    
    func showContextMenu() {
        guard  let superview = self.superview
        else { return }

       _ = self.becomeFirstResponder()

        UIMenuController.shared.menuItems = self.getActionMenuItems()

        UIMenuController.shared.setTargetRect(self.frame, in: superview)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    func hideContextMenu() {
        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
    }
}
