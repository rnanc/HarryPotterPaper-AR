
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "PaperImages",
                                                                bundle: Bundle.main) {
            configuration.trackingImages = trackedImages
            
            configuration.maximumNumberOfTrackedImages = 1
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {return nil}
        let node = ConfigNode(imageAnchor: imageAnchor)

        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        if imageAnchor.isTracked,
           node.childNodes.isEmpty,
           let videoNode = ConfigNode(imageAnchor: imageAnchor) {
            node.addChildNode(videoNode)
        } else if !imageAnchor.isTracked,
                  node.childNodes.count == 1 {
            node.childNodes.first?.removeFromParentNode()
        }
    }
    
    func ConfigNode(imageAnchor: ARImageAnchor) -> SCNNode? {
        let node = SCNNode()
        guard let name = imageAnchor.referenceImage.name else {return nil}
        let videoNode = SKVideoNode(fileNamed: "\(name).mp4")
        videoNode.play()
        
        let videoScene = SKScene(size: CGSize(width: 640,
                                              height: 360))
        
        videoNode.position = CGPoint(x: videoScene.size.width/2,
                                     y: videoScene.size.height/2)
        
        videoNode.yScale = -1.0
        
        videoScene.addChild(videoNode)
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        
        plane.firstMaterial?.diffuse.contents = videoScene
        
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.eulerAngles.x = -.pi/2

        node.addChildNode(planeNode)
        
        return node
    }
}
