# 02. 함수 타입과 유니온/리터럴 타입

## 1. 함수의 매개변수/반환 타입

함수는 각 매개변수와 반환값에 타입을 표기할 수 있다.

```ts
function add(a: number, b: number): number {
  return a + b;
}
```

반환 타입은 대부분 추론이 가능해서 생략하는 경우가 많지만,
공개 API(다른 파일/모듈에서 가져다 쓰는 함수)라면 명시해주는 것이 안전하다.
반환 타입을 명시해두면, 실수로 다른 타입을 반환했을 때 함수 본문 안에서 바로 에러가 난다.

```ts
function greet(name: string): string {
  return `안녕, ${name}`;
}
```

화살표 함수도 동일하다.

```ts
const multiply = (a: number, b: number): number => a * b;
```

## 2. 옵셔널 매개변수 (`?`)

매개변수 이름 뒤에 `?`를 붙이면 "있어도 되고 없어도 되는" 매개변수가 된다.
옵셔널 매개변수는 **항상 필수 매개변수 뒤에** 와야 한다.

```ts
function log(message: string, prefix?: string): void {
  console.log(prefix ? `[${prefix}] ${message}` : message);
}

log("서버 시작");          // prefix 없이 호출 가능
log("서버 시작", "INFO");  // prefix 포함 호출도 가능
```

함수 내부에서 `prefix`의 타입은 `string | undefined`가 된다.

## 3. 기본값 매개변수

매개변수에 기본값을 주면, 호출 시 인자를 생략했을 때 그 기본값이 사용된다.
타입은 기본값으로부터 자동으로 추론된다.

```ts
function log2(message: string, prefix = "LOG") {
  console.log(`[${prefix}] ${message}`);
}

log2("작업 완료");            // [LOG] 작업 완료
log2("작업 완료", "DEBUG");   // [DEBUG] 작업 완료
```

옵셔널(`?`)과의 차이: 옵셔널은 값이 없으면 `undefined`가 들어가지만,
기본값 매개변수는 값이 없으면 지정한 기본값으로 자동 채워진다.

## 4. 나머지 매개변수 (Rest Parameters)

개수가 정해지지 않은 인자를 배열로 받고 싶을 때 사용한다. `...이름: 타입[]` 형태로 쓴다.

```ts
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0);
}

sum(1, 2, 3);       // 6
sum(1, 2, 3, 4, 5); // 15
```

## 5. 함수 타입 표현식 (함수를 값처럼 다루기)

함수 자체의 "모양(타입)"을 미리 정의해둘 수 있다. 콜백 함수를 받을 때 특히 유용하다.

```ts
type MathOperation = (a: number, b: number) => number;

const divide: MathOperation = (a, b) => a / b;

function calculate(a: number, b: number, operation: MathOperation): number {
  return operation(a, b);
}

calculate(10, 2, divide); // 5
```

## 6. 유니온 타입 (`A | B`)

"이 값은 A 타입이거나 B 타입일 수 있다"를 표현한다.

```ts
function printId(id: number | string) {
  console.log(`ID: ${id}`);
}

printId(123);
printId("abc-123");
```

유니온 타입 값을 안전하게 쓰려면, 실제로 어떤 타입인지 좁혀야(narrowing) 한다.

```ts
function formatId(id: number | string): string {
  if (typeof id === "number") {
    return id.toFixed(0); // 이 블록 안에서는 number로 확정됨
  }
  return id.toUpperCase(); // 이 블록 안에서는 string으로 확정됨
}
```

## 7. 리터럴 타입 (Literal Types)

특정 "값 그 자체"를 타입으로 쓸 수 있다. 보통 유니온과 함께 써서 "가능한 값의 목록"을 표현한다.

```ts
type Direction = "up" | "down" | "left" | "right";

function move(direction: Direction) {
  console.log(`이동: ${direction}`);
}

move("up");     // OK
// move("north"); // 컴파일 에러: "north"는 Direction에 없음
```

문자열뿐 아니라 숫자/불리언 리터럴도 가능하다.

```ts
type DiceRoll = 1 | 2 | 3 | 4 | 5 | 6;
```

## 8. 실습

같은 폴더의 [`02-functions-and-unions.ts`](./02-functions-and-unions.ts) 파일을 실행해보자.

```bash
npm run run src/02-functions-and-unions/02-functions-and-unions.ts
```

## 다음에 공부할 것 (TODO)

- [ ] 인터페이스 vs 타입 별칭 (`interface` vs `type`)
- [ ] 인터페이스 확장(extends), 선택적 프로퍼티, readonly
- [ ] 타입 좁히기(narrowing)를 더 깊게: `in`, `instanceof`, 커스텀 타입 가드
