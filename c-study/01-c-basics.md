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

## 2. 개발 환경 준비 (Windows)

C 코드는 컴파일러가 있어야 실행할 수 있다. Windows에서 gcc를 준비하는 방법은 크게 세 가지다.

| 방법 | 장점 | 단점 |
|---|---|---|
| MSYS2 (MinGW-w64) | Windows에 직접 설치, 네이티브 `.exe` 생성 | 초기 설정(PATH 등)이 조금 번거로움 |
| WSL(리눅스) | 리눅스와 100% 동일한 환경, `apt`로 간편 설치 | 별도 리눅스 서브시스템이 필요, 파일 경로가 이원화됨 |
| VS Code + 확장 | 둘 중 하나를 설치한 뒤 에디터에서 빌드/디버그 | 컴파일러 자체는 위 두 방법 중 하나로 먼저 준비해야 함 |

처음 시작한다면 **WSL**이 설정이 가장 간단하고(리눅스 명령어를 그대로 씀), Windows 네이티브 프로그램(.exe)을 만들어야 한다면 **MSYS2**를 쓴다. 아래에서 두 방법을 모두 자세히 정리한다.

### 2-1. 방법 A: WSL + gcc (추천, 가장 간단)

1. **PowerShell을 관리자 권한으로 실행**한다 (시작 메뉴에서 PowerShell 검색 → 우클릭 → "관리자 권한으로 실행").
2. 아래 명령으로 WSL과 기본 배포판(Ubuntu)을 한 번에 설치한다.

   ```powershell
   wsl --install
   ```

3. 설치가 끝나면 **PC를 재부팅**한다. 재부팅 후 Ubuntu 터미널이 자동으로 열리며, 리눅스 사용자 이름과 비밀번호를 만들라고 물어본다 (원하는 값으로 입력).
4. Ubuntu 터미널에서 패키지 목록을 갱신하고 빌드 도구(gcc 포함)를 설치한다.

   ```bash
   sudo apt update
   sudo apt install build-essential -y
   ```

   `build-essential`에는 `gcc`, `g++`, `make` 등 C/C++ 빌드에 필요한 도구가 모두 포함되어 있다.
5. 설치 확인:

   ```bash
   gcc --version
   ```

6. 이후 Windows 터미널에서 `wsl`이라고 치면 언제든 이 리눅스 환경으로 들어갈 수 있다. Windows의 `C:\DEV\...` 경로는 WSL 안에서 `/mnt/c/DEV/...`로 접근한다.

### 2-2. 방법 B: MSYS2로 MinGW-w64 설치 (Windows 네이티브)

1. [https://www.msys2.org](https://www.msys2.org) 에서 설치 파일(`msys2-x86_64-*.exe`)을 내려받아 실행한다. 설치 경로는 기본값(`C:\msys64`)을 그대로 둔다.
2. 설치가 끝나면 시작 메뉴에서 **"MSYS2 MINGW64"** 터미널을 연다 (일반 "MSYS2" 터미널이 아니라 **MINGW64**로 표시된 것을 골라야 한다 — 64비트 Windows용 gcc가 이 환경에 연결되어 있다).
3. 이 터미널에서 gcc 도구 모음을 설치한다.

   ```bash
   pacman -Syu               # 패키지 데이터베이스/시스템 갱신 (완료 후 터미널이 닫히면 다시 열고 한 번 더 실행)
   pacman -S mingw-w64-x86_64-gcc
   ```

4. 설치된 gcc는 `C:\msys64\mingw64\bin\gcc.exe`에 있다. 이 경로를 **PowerShell/cmd에서도** 쓰려면 시스템 PATH에 등록해야 한다.
   - 시작 메뉴 → "환경 변수 편집" 검색 → "시스템 환경 변수 편집" 실행
   - "환경 변수" 버튼 → 사용자 변수(또는 시스템 변수)의 `Path` 선택 → "편집"
   - "새로 만들기" → `C:\msys64\mingw64\bin` 입력 → 확인 → 확인 (모든 창 닫기)
   - **새 PowerShell 창을 열어야** 변경된 PATH가 적용된다 (기존에 열려 있던 창은 반영 안 됨)
5. 새 PowerShell 창에서 설치 확인:

   ```powershell
   gcc --version
   ```

### 2-3. VS Code 연동 (선택, 둘 다에 적용 가능)

1. [VS Code](https://code.visualstudio.com/)를 설치한다.
2. VS Code 왼쪽 확장(Extensions) 탭에서 **"C/C++"** (Microsoft 제공) 확장을 설치한다.
3. WSL을 쓴다면 **"WSL"** 확장도 함께 설치하고, VS Code 좌측 하단의 파란색 `><` 아이콘 → "Reopen in WSL"을 눌러 WSL 안의 파일/터미널로 연결해서 작업한다.
4. 터미널(``Ctrl + ` ``)에서 `gcc` 명령이 바로 실행되면 설정 완료다. 별도의 `tasks.json` 없이도 통합 터미널에서 아래처럼 컴파일/실행하면 된다.

### 컴파일 및 실행 (공통)

컴파일러 준비가 끝났으면, 어떤 방법을 택했든 컴파일 명령은 동일하다.

```bash
gcc hello.c -o hello     # hello.c를 컴파일해서 hello(.exe) 실행 파일 생성
./hello                  # 실행 (WSL/MSYS2 터미널 기준. Windows cmd에서는 hello.exe)
```

> ⚠️ **자주 겪는 문제**: `gcc`를 설치했는데도 "명령을 찾을 수 없다"는 에러가 난다면, 대부분 PATH 등록 후 **터미널을 새로 열지 않아서**다. 새 터미널 창을 열어 `gcc --version`으로 먼저 확인하는 습관을 들이자.

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
