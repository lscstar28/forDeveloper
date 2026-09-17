# 01. 변수와 기본 타입

## 1. 타입스크립트란?

타입스크립트(TypeScript)는 자바스크립트에 **정적 타입(static type)** 을 추가한 언어다.
브라우저나 Node.js는 타입스크립트를 직접 실행할 수 없고, 컴파일러(`tsc`)가 순수 자바스크립트로 변환한 뒤 실행한다.

핵심 장점:

- 코드를 실행하기 전에 타입 오류를 미리 잡을 수 있다.
- 에디터의 자동완성, 리팩토링 지원이 훨씬 좋아진다.
- 함수/객체의 "계약(contract)"이 명확해져서 협업이 쉬워진다.

## 2. 변수 선언

자바스크립트와 동일하게 `let`, `const`를 사용한다. (`var`는 스코프 문제로 잘 쓰지 않는다.)

```ts
let age = 20;        // 재할당 가능
const name = "claude"; // 재할당 불가능
```

## 3. 타입 표기(Type Annotation)

변수 뒤에 `: 타입`을 붙여서 명시적으로 타입을 지정할 수 있다.

```ts
let age: number = 20;
let userName: string = "claude";
let isDone: boolean = false;
```

하지만 대부분의 경우 타입스크립트가 초기값을 보고 **타입을 자동으로 추론(inference)** 하기 때문에,
지역 변수에는 타입을 생략하는 것이 일반적이다.

```ts
let age = 20; // number로 자동 추론됨
```

## 4. 기본 타입 목록

| 타입 | 설명 | 예시 |
|---|---|---|
| `string` | 문자열 | `"hello"` |
| `number` | 정수/실수 구분 없이 모든 숫자 | `1`, `3.14` |
| `boolean` | 참/거짓 | `true`, `false` |
| `null` | 값이 없음을 의도적으로 표현 | `null` |
| `undefined` | 값이 아직 할당되지 않음 | `undefined` |
| `any` | 타입 검사를 포기함 (최대한 피할 것) | 아무 값 |
| `unknown` | any처럼 아무 값이나 담지만, 사용 전 타입 검사를 강제함 | 아무 값 |
| `void` | 반환값이 없는 함수의 반환 타입 | - |
| `never` | 절대 발생하지 않는 값 (예: 항상 예외를 던지는 함수) | - |

## 5. 배열과 튜플

```ts
let numbers: number[] = [1, 2, 3];
let names: Array<string> = ["a", "b"]; // 위와 동일한 의미, 제네릭 문법

// 튜플: 길이와 각 위치의 타입이 고정된 배열
let person: [string, number] = ["claude", 5];
```

## 6. 객체 타입

```ts
let user: { name: string; age: number } = {
  name: "claude",
  age: 5,
};
```

객체 구조가 반복되면 `interface`나 `type`으로 이름을 붙이는데, 이는 다음 주제에서 다룬다.

## 7. any vs unknown (중요한 차이)

```ts
let a: any = 10;
a.toUpperCase(); // 컴파일 에러 없음! 하지만 런타임에는 에러 발생 (위험)

let b: unknown = 10;
b.toUpperCase(); // 컴파일 에러: 타입을 좁히기 전엔 사용 불가 (안전)

if (typeof b === "string") {
  b.toUpperCase(); // OK: 타입이 string으로 좁혀짐
}
```

`any`는 타입 검사를 완전히 꺼버리므로, 정말 필요한 경우가 아니면 `unknown`을 사용하는 것이 안전하다.

## 8. 실습

같은 폴더의 [`01-variables-and-types.ts`](./01-variables-and-types.ts) 파일을 실행해보자.

```bash
npm run run src/01-basics/01-variables-and-types.ts
```

## 다음에 공부할 것 (TODO)

- [ ] 함수의 매개변수/반환 타입
- [ ] 옵셔널(`?`)과 기본값
- [ ] 유니온 타입(`|`)과 리터럴 타입
