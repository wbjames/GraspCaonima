import SpriteKit

enum GameType:Int {
    case Gree=0, Orange, Player
}

protocol OnGetGameResult{
    func getGameResult() -> Bool
}


class CircleFactory:SKNode{
    var gameResult:Bool
    
    var delegate:OnGetGameResult?
    
    let ONELENGTH:Int = 32
    let ROW:Int
    let COL:Int
    var grid:[GameObjectNode]
    
    let dirction0:[(Int, Int)] = [(0, -1), (0, 1), (-1, -1), (-1, 0), (1, -1), (1, 0)]
    let dirction1:[(Int, Int)] = [(0, -1), (0, 1), (-1, 0), (-1, 1), (1, 0), (1, 1)]
    
    var playerNode:GameObjectNode = GameObjectNode()
    
    init(row:Int, col:Int){
        ROW = row
        COL = col
        grid = Array(count: ROW * COL, repeatedValue: GameObjectNode())
        gameResult = false
        
        super.init()
        
    }
    
    func indexIsValidForRow(row: Int, col:Int) -> Bool{
        return row >= 0 && row < ROW && col >= 0 && col < COL
    }
    
    subscript(row:Int, col:Int) -> GameObjectNode {
        get{
            assert(indexIsValidForRow(row, col: col), "index out of range")
            return grid[row*COL + col]
        }
        
        set{
            assert(indexIsValidForRow(row, col: col), "index out of range")
            grid[(row*COL) + col] = newValue
        }
    }
    
    func createPlayer(row: Int, col: Int) -> GameObjectNode{
        let cnmTextures:SKTextureAtlas = SKTextureAtlas(named: "cnm.atlas")
        var arrayFrame:[SKTexture] = [SKTexture]()
        
        for i in 0..<cnmTextures.textureNames.count {
            arrayFrame.append(SKTexture(imageNamed: String(format: "cnm%d", i)))
        }
        
        
        let node:GameObjectNode = GameObjectNode(imageNamed: "cnm0")
        node.rowIndex = row
        node.colIndex = col
        node.type = GameType.Player
        node.anchorPoint = CGPointMake(0.5, 0)
        node.position = grid[row * COL + col].position
        node.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(arrayFrame, timePerFrame: 0.1)) )
        return node
    }
    
    func makeMap(){
        println("row = \(ROW), col = \(COL)")
        
        for i in 0..<ROW{
            for j in 0..<COL {
                
                let random = arc4random()%2
                let circle = GameObjectNode(imageNamed: String(format: "circle%d", random) )
                circle.anchorPoint = CGPointMake(0.5, 0.5)
                
               // var circle:GameObjectNode = GameObjectNode()
                //circle.addChild(sprite)
                circle.position = CGPointMake( ( i%2==0 ? 25 : 40 ) + ONELENGTH * j, 60 + 30 * i)
               // println("i = \(( i%2==0 ? 25 : 40 ) + 32 * j);  j=\(60 + 30 * i)")
                circle.rowIndex = i;
                circle.colIndex = j;
                circle.type = GameType.fromRaw(Int(random))

                self.addChild(circle)
                
                grid[(i*COL) + j]  = circle
            }
        }
        
        playerNode = createPlayer((ROW-1)/2, col:(COL-1)/2)
        grid[(ROW-1)/2 * COL + (COL-1)/2].texture = SKTexture(imageNamed: "circle0")
        grid[(ROW-1)/2 * COL + (COL-1)/2].type = GameType.Gree
        //grid[(ROW-1)/2 * COL + (COL-1)/2].addChild(playerNode)
        self.addChild(playerNode)
    }
    
    func playerMove() -> Bool {
        if playerNode.rowIndex == 0 || playerNode.rowIndex! == ROW - 1 ||
            playerNode.colIndex == 0 || playerNode.colIndex! == COL - 1 {
                gameResult = true
                gameOver()
                return false
        }
        
        
        let nextNode = findNextNode(grid[playerNode.rowIndex! * COL + playerNode.colIndex!])
        println("player=\(playerNode.position); node=\(nextNode.position)")
        if (nextNode.position == playerNode.position ) {
            println("Game Over")
            gameOver()
            return false
        }
        println("row = \(nextNode.rowIndex!); col = \(nextNode.colIndex!); minstep = \(nextNode.minStep!)")
        //playerNode.position = nextNode.position
        playerNode.runAction(SKAction.moveTo(nextNode.position, duration: NSTimeInterval(0.1)))
        playerNode.position = nextNode.position
        playerNode.rowIndex = nextNode.rowIndex
        playerNode.colIndex = nextNode.colIndex
        println("player=\(playerNode.position); node=\(nextNode.position)")
        if checkIsGameOver(nextNode) {
            println("Game Over")
            gameOver()
            return false
        }
        
        return true
    }
    
    func setGridMinStep() {
        for node in grid{
            node.minStep = ROW * COL
            node.visit = false
            
        }
    }
    
    
    func depthSearch(node: GameObjectNode){
        node.visit = true
        
        if node.rowIndex == 0 || node.rowIndex! == ROW - 1 || node.colIndex! == 0 || node.colIndex! == COL - 1 {
            node.minStep = 1
            println("\(node.rowIndex!), \(node.colIndex!), minStep=\(node.minStep!)")
            return
        }
        
        if node.rowIndex!%2 == 0{ //偶数行
            for dir in dirction0 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                //println(x, y)
//                println("x=\(x), y=\(y) -- \(node.rowIndex!), \(node.colIndex!)")
                if indexIsValidForRow(x, col: y) && grid[x * COL + y].type == GameType.Gree {
                    if grid[x * COL + y].visit == false {
                        depthSearch(grid[x * COL + y])
                    }
                    node.minStep = min(node.minStep!, grid[x * COL + y].minStep! + 1)
                    
                }
            }
        }else { //奇数行
            for dir in dirction1 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                println(x, y)
                if indexIsValidForRow(x, col: y) && grid[x * COL + y].type == GameType.Gree {
                    if grid[x * COL + y].visit == false {
                        depthSearch(grid[x * COL + y])
                    }
                    node.minStep = min(node.minStep!, grid[x * COL + y].minStep! + 1)
                   // println("\(node.rowIndex!), \(node.colIndex!), minStep=\(node.minStep!)")
                }
            }
            
        }
        println("\(node.rowIndex!), \(node.colIndex!), minStep=\(node.minStep!)")
    }
    
    
    
    func findNextNode(node: GameObjectNode) -> GameObjectNode{
        setGridMinStep()
        depthSearch(node)
        
        var returnNode = node
        if node.rowIndex!%2 == 0{ //偶数行
            for dir in dirction0 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                if indexIsValidForRow(x, col: y) && grid[x * COL + y].type == GameType.Gree && node.minStep! >= min(grid[x * COL + y].minStep! + 1, ROW * COL){
                    returnNode = grid[x * COL + y]
                }
            }
        } else { //奇数行
            for dir in dirction1 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                if indexIsValidForRow(x, col: y) && grid[x * COL + y].type == GameType.Gree && node.minStep! >= min(grid[x * COL + y].minStep! + 1, ROW * COL){
                    returnNode = grid[x * COL + y]
                }
            }
        }
        return returnNode
    }
    
    
    func checkIsGameOver(node: GameObjectNode) -> Bool{
        if node.rowIndex!%2 == 0{ //偶数行
            for dir in dirction0 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                if !indexIsValidForRow(x, col: y) || grid[x * COL + y].type == GameType.Gree {
                    return false
                }
            }
        }else {
            for dir in dirction1 {
                let x = node.rowIndex! + dir.0
                let y = node.colIndex! + dir.1
                if !indexIsValidForRow(x, col: y) || grid[x * COL + y].type == GameType.Gree {
                    return false
                }
            }
            
        }
        return true
    }

    func gameOver() {
//        let gameOverNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
//        gameOverNode.fontSize = 40
//        gameOverNode.fontColor = SKColor.whiteColor()
//        gameOverNode.position = CGPointMake(160, 240)
//        gameOverNode.text = "Game Over"
//        self.addChild(gameOverNode)

    }
    
}