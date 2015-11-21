//
//  GameScene.swift
//  OnDemandTest
//
//  Created by Justin on 11/20/15.
//  Copyright (c) 2015 Justin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var progressSceneKVOContext = 0
    
    override func didMoveToView(view: SKView) {

        let array = ["DemandTag"]
        
        preloadResourceWithTag(array)
        
        loadResourcesWithTag(array)
        

        
    }
    
    func preloadResourceWithTag(tagArray:Array<String>){
        let tags = NSSet(array: tagArray)
        
        let resourceRequest:NSBundleResourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        
        resourceRequest.beginAccessingResourcesWithCompletionHandler{(error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock{
                // error check type 1
                guard error == nil else{
                    print(error!)
                    return
                }
                print("Preloading on-demand resources")
            }
        }
    }
    
    func loadResourcesWithTag(tagArray:Array<String>){
        let tags = NSSet(array: tagArray)
        let resourceRequest:NSBundleResourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        
        resourceRequest.conditionallyBeginAccessingResourcesWithCompletionHandler{(resourcesAvailable: Bool) -> Void in
            
            if resourcesAvailable {
                print("On Demand resources already available")
                
                self.displayResources()
            }else {
                
                resourceRequest.progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.New, .Initial], context: &self.progressSceneKVOContext)
                
                
                if let progressLabel:SKLabelNode = self.childNodeWithName("Progress") as? SKLabelNode {
                    progressLabel.hidden = false
                }
                
                
                resourceRequest.beginAccessingResourcesWithCompletionHandler{ (err: NSError?) -> Void in
                    
                    // error check type 2
                    if let error = err{
                        print("Error: \(error)")
                        if let progressLabel:SKLabelNode = self.childNodeWithName("Progress") as? SKLabelNode {
                            progressLabel.hidden = false
                            progressLabel.text = "Loading Failed :-("
                        }

                    }else{
                        print("On demand resources downloaded, displaying now.")
                        resourceRequest.removeObserver(self, forKeyPath: "fractionCompleted", context: &self.progressSceneKVOContext)
                        
                        self.displayResources()
                    }
                }
            }
        }
    }
    
    func displayResources(){
        
        if let progressLabel:SKLabelNode = self.childNodeWithName("Progress") as? SKLabelNode {
            progressLabel.hidden = true
        }
        
        let image:SKSpriteNode = SKSpriteNode(imageNamed: "tshirt")
        addChild(image)
        image.position = (childNodeWithName("Placeholder")?.position)!
        
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // Check for correct KVO Notification
        if context == &progressSceneKVOContext && keyPath == "fractionCompleted" {
            // Update progress UI on main queue
            NSOperationQueue.mainQueue().addOperationWithBlock{
                
                print((object as! NSProgress).localizedDescription)
                
                if let progressLabel:SKLabelNode = self.childNodeWithName("Progress") as? SKLabelNode {
                    progressLabel.hidden = false
                    progressLabel.text = (object as! NSProgress).localizedDescription
                }
                
            }
        }else{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    
}