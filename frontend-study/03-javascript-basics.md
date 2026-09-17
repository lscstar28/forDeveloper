# JavaScript 기초

TypeScript는 결국 JavaScript 위에 타입을 얹은 것이므로, 이 문서는 순수 JS의 핵심 동작 원리에 집중한다. 타입 관련 내용은 [../typescript-study](../typescript-study) 참고.

## 1. 변수, 자료형, 제어문

```javascript
let count = 0;          // 재할당 가능
const name = "claude";  // 재할당 불가 (기본으로 const를 쓰고, 필요할 때만 let)
var old = "쓰지 않기";    // 함수 스코프 + 호이스팅 문제 → 사용 지양

// 원시 타입 (Primitive) — 값 자체가 복사됨
typeof 42;          // "number"
typeof "hi";         // "string"
typeof true;         // "boolean"
typeof undefined;    // "undefined" — 선언은 됐지만 값이 없음
typeof null;         // "object" (JS의 유명한 버그성 동작, null은 원래 값 없음을 의미)
typeof Symbol();     // "symbol"
typeof 10n;          // "bigint"

// 참조 타입 (Reference) — 메모리 주소(참조)가 복사됨
typeof {};           // "object"
typeof [];           // "object" (배열도 객체)
typeof function(){}; // "function"
```

```javascript
if (count > 0) {
  console.log("양수");
} else if (count === 0) {
  console.log("0");
} else {
  console.log("음수");
}

for (let i = 0; i < 3; i++) { /* ... */ }
for (const item of [1, 2, 3]) { /* 값을 순회 */ }
for (const key in { a: 1, b: 2 }) { /* 키를 순회 */ }

// == vs === : 항상 === (엄격한 비교, 타입까지 비교) 사용
0 == "0";   // true  (타입 강제 변환 후 비교 — 예측하기 어려움)
0 === "0";  // false (권장)
```

---

## 2. 함수와 배열/객체 메서드

```javascript
function add(a, b) { return a + b; }       // 함수 선언식 — 호이스팅됨 (선언 전에 호출 가능)
const add2 = (a, b) => a + b;              // 화살표 함수 — 호이스팅 안 됨, this를 바인딩하지 않음(아래 참고)

// 기본값, 나머지 매개변수
function greet(name = "손님", ...rest) {
  console.log(`안녕, ${name}`, rest);
}
```

### 배열 메서드 (실무에서 가장 많이 씀)

```javascript
const nums = [1, 2, 3, 4, 5];

nums.map(n => n * 2);              // [2,4,6,8,10] — 각 요소를 변환한 새 배열
nums.filter(n => n % 2 === 0);      // [2,4] — 조건을 만족하는 요소만
nums.reduce((acc, n) => acc + n, 0); // 15 — 누적값 계산 (합계, 그룹핑 등에 활용)
nums.find(n => n > 3);              // 4 — 조건을 만족하는 첫 요소
nums.some(n => n > 4);              // true — 하나라도 만족하면 true
nums.every(n => n > 0);             // true — 전부 만족해야 true
nums.includes(3);                   // true
[...nums].sort((a, b) => a - b);    // 원본 변경 없이 정렬 (sort는 원본을 바꾸므로 스프레드로 복사 후 사용)
```

> `map`/`filter`/`reduce`는 **원본 배열을 바꾸지 않고 새 배열을 반환**한다. 반면 `push`, `sort`, `splice`는 원본을 직접 변경(mutate)한다 — 이 차이가 React 등에서 상태 관리 버그의 흔한 원인이다.

### 객체 다루기

```javascript
const user = { name: "claude", age: 5 };

const { name, age } = user;               // 구조 분해 할당
const { name: userName } = user;          // 이름 바꿔서 꺼내기

const updated = { ...user, age: 6 };      // 스프레드로 불변성 유지하며 일부만 변경
Object.keys(user);                        // ["name", "age"]
Object.values(user);                      // ["claude", 5]
Object.entries(user);                     // [["name","claude"], ["age",5]]
```

---

## 3. 스코프, 클로저, this

### 스코프 (Scope)

```javascript
function outer() {
  const x = 1;
  if (true) {
    const y = 2;      // 블록 스코프 (let, const는 {} 안에서만 유효)
    console.log(x, y); // 1 2 — 접근 가능
  }
  console.log(y);       // ReferenceError — 블록 밖에서 접근 불가
}
```

### 클로저 (Closure)

함수가 **자신이 선언될 당시의 외부 변수를 기억**하는 현상. 함수형 프로그래밍과 모듈 패턴의 핵심 원리다.

```javascript
function createCounter() {
  let count = 0;              // 이 변수는 counter 함수 안에 "갇혀서" 보호됨
  return function counter() {
    count += 1;
    return count;
  };
}

const counter = createCounter();
counter(); // 1
counter(); // 2 — count가 매번 초기화되지 않고 기억됨
```

**활용 예**: React의 `useState`가 값을 유지하는 방식, 이벤트 핸들러가 특정 데이터를 "기억"하게 만드는 패턴, private 변수 흉내내기 등.

### this

`this`는 **함수가 호출되는 방식**에 따라 가리키는 대상이 달라진다 (선언 위치가 아님).

```javascript
const obj = {
  name: "claude",
  sayHi() {
    console.log(this.name); // "claude" — obj.sayHi()로 호출됐으므로 this === obj
  },
  sayHiArrow: () => {
    console.log(this.name); // undefined — 화살표 함수는 자신만의 this가 없고, 선언될 때의 바깥 this를 그대로 씀
  },
};

const fn = obj.sayHi;
fn(); // this가 obj가 아니게 됨 (일반 함수 호출 시 this는 undefined 또는 전역객체) — "this를 잃어버렸다"고 표현
```

| 호출 방식 | this |
|---|---|
| `obj.method()` | `obj` |
| 그냥 `fn()` | `undefined` (strict mode) |
| 화살표 함수 | 선언될 당시 바깥 스코프의 `this` (자기 자신은 this가 없음) |
| `fn.call(obj)` / `fn.apply(obj)` | 명시적으로 지정한 `obj` |
| `new Fn()` | 새로 생성되는 인스턴스 |

> React 컴포넌트에서 이벤트 핸들러를 화살표 함수로 많이 쓰는 이유도 이 `this`(또는 클로저) 문제를 피하기 위해서다.

---

## 4. 비동기 처리

JS는 기본적으로 **싱글 스레드**로 동작하지만, 시간이 걸리는 작업(네트워크 요청 등)을 기다리는 동안 다른 코드를 막지 않기 위해 비동기 처리를 사용한다.

### 콜백 → Promise → async/await (발전 순서)

```javascript
// 1. 콜백 방식 (콜백 지옥 문제)
getUser(id, (user) => {
  getPosts(user.id, (posts) => {
    getComments(posts[0].id, (comments) => {
      console.log(comments); // 들여쓰기가 계속 깊어짐
    });
  });
});

// 2. Promise 방식 (.then 체이닝으로 개선)
getUser(id)
  .then(user => getPosts(user.id))
  .then(posts => getComments(posts[0].id))
  .then(comments => console.log(comments))
  .catch(err => console.error(err));

// 3. async/await 방식 (동기 코드처럼 읽힘, 현재 표준)
async function loadComments(id) {
  try {
    const user = await getUser(id);
    const posts = await getPosts(user.id);
    const comments = await getComments(posts[0].id);
    console.log(comments);
  } catch (err) {
    console.error(err);
  }
}
```

### Promise 조합

```javascript
// 여러 비동기 작업을 동시에(병렬로) 실행하고 전부 끝나길 기다림
const [user, posts] = await Promise.all([getUser(id), getPosts(id)]);

// 하나라도 실패하면 즉시 실패하는 Promise.all과 달리, 성공/실패 여부와 무관하게 전부 결과를 받고 싶을 때
const results = await Promise.allSettled([getUser(id), getPosts(id)]);
```

### 이벤트 루프 (감으로 이해하기)

```javascript
console.log("1");
setTimeout(() => console.log("2"), 0);
Promise.resolve().then(() => console.log("3"));
console.log("4");

// 출력 순서: 1, 4, 3, 2
```

- 동기 코드(`console.log("1")`, `"4"`)가 먼저 전부 실행됨
- 그 다음 **마이크로태스크**(Promise의 `.then`) 처리
- 그 다음 **매크로태스크**(`setTimeout` 등) 처리

→ "비동기 코드는 지금 당장이 아니라, 현재 실행 중인 동기 코드가 끝난 뒤 처리된다"는 감각이 핵심.

---

## 5. DOM 조작과 이벤트

DOM(Document Object Model)은 HTML 문서를 JS가 다룰 수 있는 트리 구조 객체로 표현한 것. React 등 프레임워크를 쓰면 직접 다룰 일은 줄지만, 내부적으로 결국 이 API 위에서 동작한다.

```javascript
const el = document.querySelector(".card");        // CSS 선택자로 하나 찾기
const els = document.querySelectorAll(".item");    // 여러 개 찾기 (NodeList 반환)

el.textContent = "새 텍스트";      // 텍스트만 변경 (HTML 파싱 안 함, 더 안전)
el.innerHTML = "<b>굵게</b>";      // HTML로 해석해서 삽입 (사용자 입력을 그대로 넣으면 XSS 위험!)

el.classList.add("active");
el.classList.remove("active");
el.classList.toggle("active");

const div = document.createElement("div");
div.textContent = "새 요소";
document.body.appendChild(div);
```

### 이벤트 처리

```javascript
el.addEventListener("click", (event) => {
  console.log("클릭됨", event.target); // event.target: 실제 이벤트가 발생한 요소
});

// 이벤트 버블링: 자식 → 부모 순으로 이벤트가 전파됨
// 이벤트 위임(delegation): 부모 하나에만 리스너를 달아 자식 여러 개를 효율적으로 처리
document.querySelector(".list").addEventListener("click", (event) => {
  if (event.target.matches("li")) {
    console.log("li 클릭:", event.target.textContent);
  }
});
```

> `innerHTML`에 사용자가 입력한 값을 그대로 넣으면 **XSS(크로스 사이트 스크립팅)** 취약점이 생길 수 있다. 텍스트만 넣을 땐 `textContent`를 쓰는 게 기본.

---

## 6. fetch API로 네트워크 요청

브라우저에서 서버로 HTTP 요청을 보내는 표준 API (→ [../network-study](../network-study) 참고).

```javascript
// GET 요청
const res = await fetch("https://api.example.com/users");
if (!res.ok) throw new Error(`요청 실패: ${res.status}`); // fetch는 4xx/5xx여도 reject하지 않음! 직접 확인 필요
const data = await res.json();

// POST 요청
const res2 = await fetch("https://api.example.com/users", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ name: "claude" }),
});
```

> **자주 하는 실수**: `fetch`는 네트워크 자체가 실패했을 때만 reject되고, 서버가 `404`/`500`을 응답해도 **성공으로 처리**한다. 그래서 `res.ok`(또는 `res.status`)를 직접 확인해야 한다.

---

## 7. ES6+ 모듈 시스템

파일 단위로 코드를 나누고, 필요한 것만 가져다 쓰는 표준 방식.

```javascript
// math.js
export function add(a, b) { return a + b; }   // named export — 여러 개 가능
export default function multiply(a, b) { return a * b; } // default export — 파일당 1개

// main.js
import multiply, { add } from "./math.js";     // default는 이름 자유롭게, named는 { } 안에 정확한 이름
import * as math from "./math.js";             // 전체를 하나의 객체로 가져오기
```

| | CommonJS (Node.js 구버전) | ES Modules (표준) |
|---|---|---|
| 내보내기 | `module.exports = ...` | `export`, `export default` |
| 가져오기 | `require("...")` | `import ... from "..."` |
| 로딩 방식 | 동기적 | 정적 분석 가능 (트리쉐이킹에 유리) |

최근 Node.js/브라우저/번들러 모두 ES Modules가 표준이고, `package.json`에 `"type": "module"`을 설정하면 Node.js에서도 바로 `import`/`export`를 쓸 수 있다.

---

## 다음에 공부할 것 (TODO)

- [ ] 프로토타입 기반 상속, `class` 문법과의 관계
- [ ] `Map`/`Set` 자료구조 (객체/배열과의 차이)
- [ ] 이벤트 루프 심화 (Node.js의 마이크로/매크로태스크 순서 차이)
- [ ] 디바운스(debounce)/쓰로틀(throttle) 패턴
- [ ] React 등 프레임워크로 넘어가기 (→ [../web-fullstack-roadmap/02-frontend-advanced.md](../web-fullstack-roadmap/02-frontend-advanced.md))
