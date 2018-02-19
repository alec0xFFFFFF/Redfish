//
//  ViewController.swift
//  Redfish
//
//  Created by Alexander K. White on 2/13/18.
//  Copyright © 2018 Alexander K. White. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    var spheres = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sceneView.delegate = self
        let scene = SCNScene()
        addCrossSign()
        registerGestureRecognizers()
        
        sceneView.scene = scene
    }
    
    private func addCrossSign() {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.textAlignment = .center
        label.center = self.sceneView.center
        
        self.sceneView.addSubview(label)
        
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = self.sceneView.center
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        if !hitTestResults.isEmpty {
            
            guard let hitTestResult = hitTestResults.first else {
                return
            }
            if self.spheres.count == 2 {
                //remove spheres and nodes
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
                    node.removeFromParentNode()
                }
                self.spheres.removeAll()
                for view in self.view.subviews {
                    if view is UILabel{
                        view.removeFromSuperview()
                    }
                }
                return
            }
            let sphere = SCNSphere(radius: 0.005)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            self.spheres.append(sphereNode)
            
            if self.spheres.count == 2 {
                
                let firstPoint = self.spheres.first!
                let secondPoint = self.spheres.last!
                
                let position = SCNVector3Make(secondPoint.position.x - firstPoint.position.x, secondPoint.position.y - firstPoint.position.y, secondPoint.position.z - firstPoint.position.z)
                
                let result = sqrt(position.x*position.x + position.y*position.y + position.z*position.z)

                display(distance: result)
                
            }
        }
        
    }
    
    private func display(distance: Float) {
        for view in self.view.subviews {
            if view is UILabel{
                view.removeFromSuperview()
            }
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "\(distance) m"
        self.view.addSubview(label)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}

