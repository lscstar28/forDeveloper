// 01. 변수와 기본 타입 실습
// 설명은 01-variables-and-types.md 참고

// 1) 타입 표기 vs 타입 추론
let age: number = 20;
let userName = "claude"; // string으로 자동 추론됨

console.log(`이름: ${userName}, 나이: ${age}`);

// 2) 기본 타입들
let isDone: boolean = false;
let numbers: number[] = [1, 2, 3];
let person: [string, number] = ["claude", 5]; // 튜플

console.log("숫자 배열:", numbers);
console.log("튜플(이름, 경력):", person);

// 3) 객체 타입
const user: { name: string; age: number } = {
  name: "claude",
  age: 5,
};

console.log("유저 객체:", user);

// 4) any vs unknown 비교
let anyValue: any = 10;
anyValue = "이제 문자열이어도 에러 없음"; // any는 타입 검사를 포기
console.log("any 값:", anyValue);

let unknownValue: unknown = 10;
// unknownValue.toString(); // 이 줄의 주석을 풀면 컴파일 에러 발생 (타입을 좁히기 전엔 사용 불가)

if (typeof unknownValue === "number") {
  console.log("unknown이지만 number로 좁혀짐:", unknownValue.toFixed(2));
}

// 5) 잘못된 타입 할당은 컴파일 시점에 바로 걸러진다
// age = "스무살"; // 이 줄의 주석을 풀면 컴파일 에러: Type 'string' is not assignable to type 'number'
