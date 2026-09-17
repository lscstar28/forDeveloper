# C 언어 함수

[01-c-basics.md](01-c-basics.md)에 이어서, 함수의 선언/정의, 매개변수, 반환값, 선언 순서와 프로토타입을 정리한다.

---

## 1. 함수란?

반복되는 코드를 이름 붙여 묶어두고 필요할 때마다 호출해 쓰는 단위다. `main` 함수도 사실 프로그램이 시작될 때 OS가 호출하는 함수 중 하나다.

```c
반환타입 함수이름(매개변수1, 매개변수2, ...) {
    // 실행할 코드
    return 반환값;
}
```

```c
#include <stdio.h>

int add(int a, int b) {   // 정의: int를 2개 받아서 int를 반환
    return a + b;
}

int main(void) {
    int result = add(3, 4);   // 호출
    printf("result=%d\n", result);
    return 0;
}
```

- `int add(int a, int b)` — **함수 헤더**. 반환 타입(`int`), 함수 이름(`add`), 매개변수 목록(`int a, int b`)으로 구성
- `a`, `b` — **매개변수(parameter)**. 함수 안에서만 쓰이는 지역 변수
- `add(3, 4)`의 `3`, `4` — **인자(argument)**. 호출할 때 실제로 넘기는 값
- `return` — 함수를 종료하고 값을 호출한 쪽으로 돌려줌. 반환 타입이 `void`면 `return;`만 쓰거나 아예 생략 가능

---

## 2. 매개변수와 반환값

### 2-1. 매개변수가 없는 함수

```c
void greet(void) {          // 매개변수 없음을 명시할 땐 (void)
    printf("Hello!\n");
}
```

> `void greet()`처럼 괄호를 비워두면 "매개변수 개수를 알 수 없다"는 옛 C 방식으로 해석될 수 있다. **매개변수가 없으면 반드시 `(void)`라고 명시**하는 게 안전하다.

### 2-2. 반환값이 없는 함수

```c
void print_square(int n) {
    printf("%d의 제곱: %d\n", n, n * n);
    // return 문이 없어도 함수 끝에서 자동으로 종료됨
}
```

### 2-3. 값에 의한 전달 (call by value)

C에서 함수에 인자를 넘기면 **값이 복사**되어 전달된다. 함수 안에서 매개변수를 바꿔도 호출한 쪽의 원본 변수는 바뀌지 않는다.

```c
#include <stdio.h>

void try_change(int x) {
    x = 100;   // 복사본만 바뀜
}

int main(void) {
    int num = 10;
    try_change(num);
    printf("num=%d\n", num);   // 여전히 10
    return 0;
}
```

> 원본 값을 함수 안에서 바꾸고 싶다면 **포인터**로 주소를 넘겨야 한다 (다음 문서에서 다룰 예정). `scanf("%d", &number)`도 같은 원리다.

---

## 3. 함수 선언(프로토타입)과 정의

C 컴파일러는 코드를 **위에서 아래로** 읽으면서, 함수가 호출되는 시점에 그 함수의 존재를 이미 알고 있어야 한다. 그래서 순서가 중요하다.

### 3-1. 문제 상황: 정의가 호출보다 아래에 있는 경우

```c
#include <stdio.h>

int main(void) {
    int result = add(3, 4);   // 컴파일 에러/경고: add가 뭔지 아직 모름
    printf("%d\n", result);
    return 0;
}

int add(int a, int b) {       // main보다 아래에 정의됨
    return a + b;
}
```

### 3-2. 해결 1: 함수를 호출보다 먼저 정의

```c
int add(int a, int b) {
    return a + b;
}

int main(void) {
    int result = add(3, 4);   // 문제없음
    printf("%d\n", result);
    return 0;
}
```

### 3-3. 해결 2: 함수 프로토타입 선언 (실무에서 더 흔한 방식)

함수의 **헤더만 미리 선언**해두고, 실제 정의는 아래(또는 다른 파일)에 둘 수 있다. 프로토타입 끝에는 세미콜론(`;`)을 붙인다.

```c
#include <stdio.h>

int add(int a, int b);   // 프로토타입 선언 (헤더만, 세미콜론으로 끝남)

int main(void) {
    int result = add(3, 4);   // 프로토타입만 봐도 컴파일 가능
    printf("%d\n", result);
    return 0;
}

int add(int a, int b) {      // 실제 정의는 나중에 나와도 됨
    return a + b;
}
```

> 여러 개의 `.c` 파일로 프로젝트를 나눌 때는, 함수 정의는 각 `.c` 파일에 두고 프로토타입만 모아둔 `.h` 헤더 파일을 만들어 필요한 곳에서 `#include`하는 방식을 쓴다. 이렇게 하면 다른 파일에서도 그 함수를 호출할 수 있다.

---

## 4. 함수를 왜 나누는가

- **중복 제거** — 같은 로직을 여러 번 안 써도 됨
- **가독성** — `main`이 "무엇을 하는지"만 보이고, "어떻게 하는지"는 각 함수 안에 숨김
- **재사용** — 다른 프로그램에서도 같은 함수를 가져다 쓸 수 있음
- **테스트 용이성** — 함수 단위로 입력값을 바꿔가며 검증하기 쉬움

---

## 5. 직접 실행해보는 예제

[examples/02-c-functions.c](examples/02-c-functions.c) 에 이 문서의 함수 정의/호출/프로토타입 내용을 모아뒀다.

```bash
gcc examples/02-c-functions.c -o examples/02-c-functions
./examples/02-c-functions
```

---

## 다음에 공부할 것 (TODO)

- [ ] 배열과 문자열 (C 문자열은 `char` 배열 + `\0`)
- [ ] 포인터 기초 (`&`, `*`, 배열과의 관계)
- [ ] 구조체 (`struct`)
- [ ] 동적 메모리 할당 (`malloc`, `free`)와 메모리 누수
- [ ] 파일 입출력 (`fopen`, `fread`, `fwrite`, `fclose`)
