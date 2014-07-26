import SpriteKit

class EndGameScene:SKScene {
    
    init(size: CGSize, result:Bool, userStep:Int){
        super.init(size: size)
        let cnmSprite = SKSpriteNode(imageNamed: "caonima")
        cnmSprite.position = CGPointMake(0, self.size.height - cnmSprite.size.height)
        cnmSprite.anchorPoint = CGPointZero
        self.addChild(cnmSprite)
        
        
        let lblGameOver:SKLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblGameOver.fontSize = 10
        lblGameOver.fontColor = SKColor.whiteColor()
        lblGameOver.position = CGPointMake(self.size.width/2, self.size.height/2)
        lblGameOver.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        if result {
            lblGameOver.text = "让草泥马跑回大草原了!!"
        }else {
            lblGameOver.text = "我用了 \(userStep) 步围住草泥马，\n击败 \(100-userStep)% 的人，你能超过我吗？"
        }
        self.addChild(lblGameOver)
        
        let lblTapAgain:SKLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTapAgain.fontSize = 30
        lblTapAgain.fontColor = SKColor.whiteColor()
        lblTapAgain.position = CGPointMake(self.size.width/2, 160)
        lblTapAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTapAgain.text = "点击再玩一次"
        self.addChild(lblTapAgain)

        

    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let gameScene = GameScene(size: self.size)
        let reveal = SKTransition.fadeWithDuration(0.5)
        self.view.presentScene(gameScene, transition: reveal)
    }
    
}