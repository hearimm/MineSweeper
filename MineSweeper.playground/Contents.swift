//: Playground - noun: a place where people can play

import Foundation

class Board {
    let sizeX:Int
    let sizeY:Int
    let maxMine:Int
    
    // 지뢰가지고 있는 field 중복 제거 위해 Set으로 선언
    var mineFields = Set<Field>()
    // 보드에 들어갈 필드들 [][] 이중배열 선언
    var fields:[[Field]] = []
    
    init(x:Int, y:Int, maxMine:Int) {
        self.sizeX = x
        self.sizeY = y
        self.maxMine = maxMine
        
        //잘못된 동작 방어코드
        if(x * y < maxMine) { print("지뢰 갯수가 보드 크기보다 많을 수 없습니다."); return }
        
        createBoard() // 보드 만들기
        createMine() // 지뢰 만들기
        nearMineCountAdd() // 지뢰 주변 카운트
    }
    
    // 보드만들기 for loop 2번으로 이중배열 추가
    func createBoard() {
        for row in 0 ..< self.sizeX {
            var fieldRow:[Field] = []
            for col in 0 ..< self.sizeY {
                let field = Field(x: row, y: col)
                fieldRow.append(field)
            }
            self.fields.append(fieldRow)
        }
    }
    
    // 지뢰만들기 x, y 랜덤으로 가져옴
    func createMine() {
        // while 루프로 쓴 이유는 중복되는 위치에 지뢰가 생성될 수 있어서
        while mineFields.count < maxMine {
            let x = Int(arc4random_uniform(UInt32(self.sizeX)))
            let y = Int(arc4random_uniform(UInt32(self.sizeY)))
            
            fields[x][y].isMine = true // 지뢰여부 변환 true
            mineFields.insert(fields[x][y]) // 지뢰필드Set에 추가 Set은 중복 불가
        }
    }
    
    // 지뢰 근처 필드들에 숫자 증가
    func nearMineCountAdd() {
        //주변 구하기 튜플
        let offsets =
            [(-1,-1),(0,-1),(1,-1),
             (-1,0),(1,0),
             (-1,1),(0,1),(1,1)]
        // 주변 튜플 for loop
        for (row,col) in offsets {
            // 처음부터 전부 for loop 을 돌리지 않고, 지뢰 주변에 있는 필드만 찾아서 증가시킴
            for mineField in mineFields {
                // optianl로 out of index 될 수 있는 배열 nil로 return
                let optionalField:Field? = getNearField(row: row+mineField.x, col: col+mineField.y)
                // optional chain 꺼내서 주변지뢰 숫자 증가
                if let field = optionalField {
                    field.nearMine += 1
                }
            }
        }
    }
    
    // 주변 필드 구하기 optional로 out of index 될 배열 nil로 return
    func getNearField(row:Int, col:Int) -> Field?{
        if row >= 0 && row < self.sizeX && col >= 0 && col < self.sizeY {
            return fields[row][col]
        } else {
            return nil
        }
    }
    
    // 이중배열 풀어서 Field 클래스 toString 실행
    func toString() -> String {
        var result = ""
        for fieldRow in fields {
            for field in fieldRow {
                result = result + field.toString()
            }
            result = result + "\n"
        }
        return result
    }
}

class Field {
    let x:Int
    let y:Int
    var isMine = false // 지뢰여부
    var nearMine = 0 // 주변지뢰갯수
    
    // 초기화함수
    init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
    // 지뢰일 땐 * 표시 아닐땐, 주변 마인 갯수 표시
    func toString() -> String {
        return isMine == true ? "*" : "\(nearMine)"
    }
}

// 필드를 Set에 담으려면 Hashable 프로토콜이 종속되어야 함. (중복인지 아닌지 체크하기 위함)
extension Field: Hashable {
    var hashValue: Int {
        return x.hashValue ^ y.hashValue &* 16777619
    }
    
    static func == (lhs: Field, rhs: Field) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// 수행 부분
var x = Board(x: 10, y: 10, maxMine: 10)

// 결과 프린트
print(x.toString())



// 테스트 부분
print("지뢰 필드 갯수 확인: " + "\(x.mineFields.count)," + "\(x.maxMine)," + "\(x.mineFields.count == x.maxMine)")

func test() {
    //주변 오프셋 선언
    let offsets =
        [(-1,-1),(0,-1),(1,-1),
         (-1,0),(1,0),
         (-1,1),(0,1),(1,1)]
    
    for row in x.fields {
        for field in row {
            var nearMineCnt = 0 //주변에 지뢰 갯수
            for (row,col) in offsets {
                // 주변 필드 구하기 optional로 out of index 될 배열 nil로 return
                let optionalField:Field? = getTestNearField(row: row, col: col, field: field, board: x)
                // optional chain 꺼내서 주변지뢰 숫자 증가
                if let unWrapField = optionalField {
                    if unWrapField.isMine { //주변이 지뢰이면, 1증가
                        nearMineCnt += 1
                    }
                }
            }
            if nearMineCnt != field.nearMine { // 주변 지뢰 갯수와 해당 필드의 값이 다를때, break
                print(field.x, field.y , nearMineCnt , field.nearMine)
                return
            }
        }
    }
    print("All Passed")
}

// 주변 필드 구하기 optional로 out of index 될 배열 nil로 return
func getTestNearField(row:Int, col:Int, field: Field, board: Board) -> Field?{
    let r = row + field.x
    let c = col + field.y
    if r >= 0 && r < board.sizeX && c >= 0 && c < board.sizeY {
        return board.fields[r][c]
    } else {
        return nil
    }
}

test()


