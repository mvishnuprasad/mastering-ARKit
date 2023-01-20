//
//  Coordinator.swift
//  HelloAR
//
//  Created by Mohammad Azam on 4/7/22.
//

import Foundation
import ARKit
import RealityKit
import Combine

class Coordinator: NSObject, ARSessionDelegate, UIGestureRecognizerDelegate {
    
    weak var view: ARView?
    var collisionSubscriptions = [Cancellable]()
    
    let boxGroup = CollisionGroup(rawValue: 1 << 0)
    let sphereGroup = CollisionGroup(rawValue: 1 << 1)
    
    var movableEntities = [ModelEntity]()
    
    func buildEnvironment() {
        
        guard let view = view else { return }
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        // create a floor
        let floor = ModelEntity(mesh: MeshResource.generatePlane(width: 0.9, depth: 0.9), materials: [SimpleMaterial(color: .green, isMetallic: true)])
        floor.generateCollisionShapes(recursive: true)
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        let box1 = ModelEntity(mesh: MeshResource.generateBox(size: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        box1.generateCollisionShapes(recursive: true)
        
        box1.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])], mode: .trigger, filter: .sensor)
        box1.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        box1.position.y = 0.3
        
        let box2 = ModelEntity(mesh: MeshResource.generateBox(size: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        box2.generateCollisionShapes(recursive: true)
        box2.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        box2.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])], mode: .trigger, filter: .sensor)
        box2.position.z = 0.3
        box2.position.y = 0.3
        
        let sphere1 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        sphere1.generateCollisionShapes(recursive: true)
        sphere1.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        sphere1.collision = CollisionComponent(shapes: [.generateSphere(radius: 0.2)], mode: .trigger, filter: .sensor)
        sphere1.position.x += 0.3
        sphere1.position.y = 0.3
        
        let sphere2 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        sphere2.generateCollisionShapes(recursive: true)
        sphere2.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        sphere2.collision = CollisionComponent(shapes: [.generateSphere(radius: 0.2)], mode: .trigger, filter: .sensor)
        sphere2.position.x -= 0.3
        sphere2.position.y = 0.3
        
        anchor.addChild(floor)
        anchor.addChild(box1)
        anchor.addChild(box2)
        anchor.addChild(sphere1)
        anchor.addChild(sphere2)
        
        movableEntities.append(box1)
        movableEntities.append(box2)
        movableEntities.append(sphere1)
        movableEntities.append(sphere2)
        
        view.scene.addAnchor(anchor)
        
        movableEntities.forEach {
            view.installGestures(.all, for: $0).forEach {
                $0.delegate = self
            }
        }
        
        setupGestures()
        
    }
    
    fileprivate func setupGestures() {
        
        guard let view = view else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            case .ended, .cancelled, .failed:
                // change the physics mode to dynamic
                movableEntities.compactMap { $0 }.forEach {
                    $0.physicsBody?.mode = .dynamic
                }
            default:
                return
        }
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let translationGesture = gestureRecognizer as? EntityTranslationGestureRecognizer,
              let entity = translationGesture.entity as? ModelEntity else {
            return true
        }
        
        entity.physicsBody?.mode = .kinematic
        return true
    }
    
}
