# C 언어 기초

## 1. C 언어란?

C는 1972년 데니스 리치가 만든 절차지향 언어로, 운영체제(유닉스, 리눅스 커널), 임베디드 시스템, 데이터베이스 엔진 등 시스템 프로그래밍의 근간이 되는 언어다.

특징:

- **컴파일 언어** — 소스 코드를 실행 전에 기계어로 미리 번역해야 한다 (파이썬/자바스크립트 같은 인터프리터 언어와 다름)
- **저수준 제어** — 메모리를 직접 다룬다 (포인터, 수동 메모리 할당/해제)
- **타입이 고정적** — 변수 선언 시 타입을 명시하고, 선언 후 타입이 바뀌지 않는다
- **표준 라이브러리가 작다** — 문자열, 파일 입출력 등도 라이브러리 함수를 직접 조합해서 써야 한다

> C를 배우면 "언어가 대신 처리해주던 것들"(가비지 컬렉션, 동적 배열, 문자열 타입 등)을 직접 다루게 되어, 다른 언어를 쓸 때도 내부 동작을 이해하는 데 도움이 된다.

---

## 2. 개발 환경 준비

C 코드는 컴파일러가 있어야 실행할 수 있다. Windows에서는 아래 중 하나를 선택한다.

| 방법 | 설명 |
|---|---|
| MinGW-w64 | Windows에 직접 gcc를 설치. `gcc` 명령어를 PowerShell/cmd에서 바로 사용 |
| WSL(리눅스) | WSL 안에 `sudo apt install gcc` 로 설치, 리눅스 환경과 동일하게 사용 |
| VS Code + C/C++ 확장 | 위 컴파일러 중 하나를 설치한 뒤 에디터에서 빌드/디버그 |

설치 확인:

```bash
gcc --version
```

컴파일 및 실행:

```bash
gcc hello.c -o hello     # hello.c를 컴파일해서 hello(.exe) 실행 파일 생성
./hello                  # 실행 (Windows cmd에서는 hello.exe)
```

---

## 3. 첫 프로그램

```c
#include <stdio.h>

int main(void) {
    printf("Hello, C!\n");
    return 0;
}
```

- `#include <stdio.h>` — 표준 입출력 함수(`printf`, `scanf` 등)를 쓰기 위해 헤더를 불러온다
- `int main(void)` — 프로그램의 시작점. 운영체제가 가장 먼저 호출하는 함수
- `return 0;` — 프로그램이 정상 종료했음을 OS에 알림 (0이 아니면 보통 에러 코드로 취급)

---

## 4. 기본 문법 구조

```c
// 한 줄 주석
/* 여러 줄
   주석 */

int main(void) {
    printf("문장 끝에는 세미콜론(;)\n");   // 문장 종결자
    {
        // 중괄호 {}로 코드 블록(함수, 조건문, 반복문의 범위)을 묶는다
    }
    return 0;
}
```

---

## 5. 변수와 자료형

```c
#include <stdio.h>

int main(void) {
    int age = 20;               // 정수
    float price = 1500.5f;      // 부동소수점 (float은 f 접미사 권장)
    double pi = 3.14159265;     // 배정밀도 부동소수점
    char grade = 'A';           // 문자 하나 (작은따옴표)
    int is_valid = 1;           // C에는 원래 bool이 없어 0/1로 참거짓을 표현 (C99부터 <stdbool.h>의 bool 사용 가능)

    printf("age=%d, price=%.1f, pi=%f, grade=%c\n", age, price, pi, grade);
    printf("int 크기: %zu bytes\n", sizeof(int));

    return 0;
}
```

주요 타입과 `printf` 서식 지정자:

| 타입 | 설명 | printf 서식 |
|---|---|---|
| `int` | 정수 | `%d` |
| `float` | 부동소수점 (4바이트) | `%f` |
| `double` | 부동소수점 (8바이트, 기본 실수형) | `%f` |
| `char` | 문자 1개 (1바이트) | `%c` |
| `long` | 큰 정수 | `%ld` |
| `unsigned int` | 음수 없는 정수 | `%u` |

> `sizeof(타입)`으로 해당 타입이 메모리를 몇 바이트 차지하는지 확인할 수 있다. 크기는 플랫폼/컴파일러마다 달라질 수 있다.

---

## 6. 입력받기 (scanf)

```c
#include <stdio.h>

int main(void) {
    int number;
    printf("숫자를 입력하세요: ");
    scanf("%d", &number);          // 변수 앞에 & (주소 연산자) 필수
    printf("입력한 값: %d\n", number);
    return 0;
}
```

`scanf`는 값을 저장할 변수의 **주소**를 요구한다. `&`를 빠뜨리면 컴파일 경고가 나거나, 최악의 경우 프로그램이 이상한 메모리를 건드려 오작동한다. (포인터 개념은 이후 문서에서 다룬다.)

---

## 7. 연산자

```c
int a = 7, b = 2;

a + b;   // 9   덧셈
a - b;   // 5   뺄셈
a * b;   // 14  곱셈
a / b;   // 3   나눗셈 (정수끼리 나누면 소수점 버림!)
a % b;   // 1   나머지

a == b;  // 0(거짓) 같다
a != b;  // 1(참) 다르다
a > b;   // 1(참)

a && b;  // 논리 AND
a || b;  // 논리 OR
!a;      // 논리 NOT

a++;     // 후위 증가 (a를 쓴 뒤 1 증가)
++a;     // 전위 증가 (1 증가한 뒤 a를 씀)
```

> **정수 나눗셈 주의**: `7 / 2`는 `3.5`가 아니라 `3`이다. 소수점 결과가 필요하면 `7 / 2.0` 처럼 피연산자 중 하나 이상을 실수로 만들어야 한다.

---

## 8. 조건문

```c
int score = 85;

if (score >= 90) {
    printf("A\n");
} else if (score >= 80) {
    printf("B\n");
} else {
    printf("C 이하\n");
}

switch (score / 10) {
    case 10:
    case 9:
        printf("A\n");
        break;
    case 8:
        printf("B\n");
        break;
    default:
        printf("C 이하\n");
        break;
}
```

> `switch`의 `case`는 `break`가 없으면 다음 `case`로 실행이 그대로 흘러 내려간다 (fall-through). 의도적으로 쓰는 경우(위 예시의 `case 10:`과 `case 9:`)가 아니라면 `break`를 꼭 넣어야 한다.

---

## 9. 반복문

```c
for (int i = 0; i < 5; i++) {
    printf("%d ", i);            // 0 1 2 3 4
}

int i = 0;
while (i < 5) {
    printf("%d ", i);
    i++;
}

int j = 0;
do {
    printf("%d ", j);            // 조건이 거짓이어도 최소 1번은 실행됨
    j++;
} while (j < 5);
```

- `break` — 반복문을 즉시 빠져나감
- `continue` — 현재 반복만 건너뛰고 다음 반복으로 넘어감

---

## 10. 직접 실행해보는 예제

[examples/01-c-basics.c](examples/01-c-basics.c) 에 이 문서의 변수/연산자/조건문/반복문 내용을 모아뒀다.

```bash
gcc examples/01-c-basics.c -o examples/01-c-basics
./examples/01-c-basics
```

---

## 다음에 공부할 것 (TODO)

- [ ] 함수 (선언/정의, 매개변수, 반환값, 선언 순서와 프로토타입)
- [ ] 배열과 문자열 (C 문자열은 `char` 배열 + `\0`)
- [ ] 포인터 기초 (`&`, `*`, 배열과의 관계)
- [ ] 구조체 (`struct`)
- [ ] 동적 메모리 할당 (`malloc`, `free`)와 메모리 누수
- [ ] 파일 입출력 (`fopen`, `fread`, `fwrite`, `fclose`)
