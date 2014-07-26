import SpriteKit

class GameScene: SKScene {
    
    var userStep:Int
    
    let circleFactory:CircleFactory = CircleFactory(row: 9, col: 9)
    
    init(size : CGSize) {
        userStep = 0
        super.init(size :size)
        
        let cnmSprite = SKSpriteNode(imageNamed: "caonima")
        cnmSprite.position = CGPointMake(0, self.size.height - cnmSprite.size.height)
        cnmSprite.anchorPoint = CGPointZero
        //self.addChild(cnmSprite)
        
        circleFactory.makeMap()
        self.addChild(circleFactory)
    }
    
    
    
    override func didMoveToView(view: SKView) {
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch:UITouch = touches.anyObject() as UITouch
        let positionInGameMap = touch.locationInNode(circleFactory)
        selectNodeForTouch(positionInGameMap)
    }
    
    func selectNodeForTouch(touchPosition: CGPoint) {
        let nodes = circleFactory.nodesAtPoint(touchPosition)
        // println(nodes)
        for node in nodes {
            let gameObject:GameObjectNode = node as GameObjectNode
            if gameObject.type == GameType.Gree {
                if distanceBetweenTowPoint(touchPosition, pointB: gameObject.position) <= gameObject.size.width / 2{
                    gameObject.texture = SKTexture(imageNamed: "circle1")
                    gameObject.type = GameType.Orange
                    //   println(gameObject)
                    
                    if circleFactory.playerMove() == false {
                        gameOver()
                    }
                    userStep++
                }
            }
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    func distanceBetweenTowPoint(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let vector = CGVectorMake(pointA.x - pointB.x, pointA.y - pointB.y)
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    
    func gameOver(){
        let endGameScene = EndGameScene(size: self.size, result: circleFactory.gameResult, userStep: userStep)
        let reveal = SKTransition.fadeWithDuration(0.5)
        self.view.presentScene(endGameScene, transition: reveal)

    }
}
