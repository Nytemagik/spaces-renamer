//
//  ViewController.swift
//  SpacesRenamer
//
//  Created by Alex Beals on 11/15/17.
//  Copyright © 2017 cvz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var updateButton: NSButton!

    var desktops: [String: NSTextField] = [String: NSTextField]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load in a list of all of the spaces
        guard let spacesDict = NSDictionary(contentsOfFile: Utils.spacesPath) else { return }
        let allSpaces = (spacesDict.value(forKeyPath: "SpacesDisplayConfiguration.Management Data.Monitors.Spaces") as! NSArray)[0] as! NSArray

        print(allSpaces.count)

        var prev: DesktopSnippet?

        for i in 1...allSpaces.count { // allSpaces.count
            let snippet = DesktopSnippet.instanceFromNib()
            snippet.label.stringValue = "Desktop \(i)"
            self.view.addSubview(snippet)

            let uuid = (allSpaces[i-1] as! [AnyHashable: Any])["uuid"] as! String

            desktops[uuid] = snippet.textField

            var verticalConstraint: NSLayoutConstraint?

            if (prev == nil) {
                verticalConstraint = NSLayoutConstraint(item: snippet, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
            } else {
                verticalConstraint = NSLayoutConstraint(item: snippet, attribute: .top, relatedBy: .equal, toItem: prev, attribute: .bottom, multiplier: 1.0, constant: 0)
            }

            self.view.addConstraints([verticalConstraint!])
            prev = snippet
        }

        let verticalConstraint = NSLayoutConstraint(item: updateButton, attribute: .top, relatedBy: .equal, toItem: prev!, attribute: .bottom, multiplier: 1.0, constant: 10)

        self.view.addConstraints([verticalConstraint])
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        print("Hello")
        // Update with the current names

        // snippet.textField.stringValue = "Desktop \(i)"
    }

    @IBAction func pressChangeName(_ sender: Any) {
        // Load from preferences the current mapping
        let preferencesDict = NSMutableDictionary(contentsOfFile: Utils.plistPath) ?? NSMutableDictionary()
        let currentMapping = (preferencesDict.value(forKey: "spaces_renaming") as? NSMutableDictionary) ?? NSMutableDictionary()

        // Update accordingly
        for (uuid, textField) in desktops {
            currentMapping.setValue(textField.stringValue, forKey: uuid)
        }
        print(currentMapping)
        preferencesDict.setValue(currentMapping, forKey: "spaces_renaming")

        // Resave
        preferencesDict.write(toFile: Utils.plistPath, atomically: true)
    }
}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "Popup")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
