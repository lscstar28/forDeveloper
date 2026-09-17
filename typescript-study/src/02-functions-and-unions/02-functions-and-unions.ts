// 02. 함수 타입과 유니온/리터럴 타입 실습
// 설명은 02-functions-and-unions.md 참고

// 1) 매개변수/반환 타입
function add(a: number, b: number): number {
  return a + b;
}
console.log("add(2, 3) =", add(2, 3));

// 2) 옵셔널 매개변수
function log(message: string, prefix?: string): void {
  console.log(prefix ? `[${prefix}] ${message}` : message);
}
log("서버 시작");
log("서버 시작", "INFO");

// 3) 기본값 매개변수
function log2(message: string, prefix = "LOG") {
  console.log(`[${prefix}] ${message}`);
}
log2("작업 완료");
log2("작업 완료", "DEBUG");

// 4) 나머지 매개변수
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0);
}
console.log("sum(1,2,3) =", sum(1, 2, 3));
console.log("sum(1,2,3,4,5) =", sum(1, 2, 3, 4, 5));

// 5) 함수 타입 표현식
type MathOperation = (a: number, b: number) => number;

const divide: MathOperation = (a, b) => a / b;

function calculate(a: number, b: number, operation: MathOperation): number {
  return operation(a, b);
}
console.log("calculate(10, 2, divide) =", calculate(10, 2, divide));

// 6) 유니온 타입 + 타입 좁히기
function formatId(id: number | string): string {
  if (typeof id === "number") {
    return id.toFixed(0);
  }
  return id.toUpperCase();
}
console.log("formatId(123) =", formatId(123));
console.log("formatId('abc') =", formatId("abc"));

// 7) 리터럴 타입
type Direction = "up" | "down" | "left" | "right";

function move(direction: Direction) {
  console.log(`이동: ${direction}`);
}
move("up");
move("left");
// move("north"); // 이 줄의 주석을 풀면 컴파일 에러: "north"는 Direction에 없음

type DiceRoll = 1 | 2 | 3 | 4 | 5 | 6;
const roll: DiceRoll = 4;
console.log("주사위 결과:", roll);
