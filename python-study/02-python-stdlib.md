# 파이썬 표준 라이브러리와 자주 쓰는 함수

`01-python-basics.md`에서 `print`, `len`, `range` 같은 몇 개를 이미 써봤다. 이 문서는 그 목록을 넓혀서,
**"파이썬 자체가 기본으로 들고 있는 도구들"**을 체계적으로 정리한다. 여기서도 특정 프로젝트 코드는 잊고,
일상적인 예시로만 설명한다.

---

## 1. 두 가지를 구분하자: "내장 함수" vs "표준 라이브러리"

| 구분 | 뜻 | 쓰는 방법 |
|---|---|---|
| **내장 함수(built-in)** | 아무 준비 없이 바로 쓸 수 있는 함수 | 그냥 호출 `print(...)` |
| **표준 라이브러리(standard library)** | 파이썬 설치 시 같이 들어있지만, 창고에서 "꺼내와야"(`import`) 쓸 수 있는 모듈 묶음 | `import os` 하고 `os.무언가()` |

**비유**: 내장 함수는 "손 뻗으면 바로 잡히는 물건"이고, 표준 라이브러리는 "같은 집(파이썬) 안에 있지만 창고(모듈)에서 꺼내와야 하는 물건"이다. 둘 다 "별도로 설치(`pip install`)할 필요는 없다"는 공통점이 있고, 이 점에서 `torch` 같은 외부 라이브러리와 다르다.

---

## 2. 내장 함수 더 넓게 보기

### 2-1. 형(type) 변환 — `int`, `float`, `str`, `bool`

```python
print(int("5"))       # "5"(문자열) -> 5(정수)
print(float("3.14"))   # "3.14"(문자열) -> 3.14(실수)
print(str(100))         # 100(정수) -> "100"(문자열)
print(bool(0))            # 0 -> False
print(bool(1))            # 1 -> True
```
실행 결과:
```
5
3.14
100
False
True
```

문자열로 받은 값(예: 사용자 입력, 파일에서 읽은 텍스트)을 숫자로 계산하려면 항상 `int()`/`float()`로 변환해야 한다. 이건 앞으로도 정말 자주 마주친다.

### 2-2. `round`, `abs`, `min`, `max`, `sum`

```python
print(round(3.14159, 2))    # 소수점 2자리까지 반올림
print(abs(-7))                # 절댓값
print(min(3, 1, 2))            # 가장 작은 값
print(max([3, 1, 2]))          # 리스트 중 가장 큰 값
print(sum([1, 2, 3, 4]))       # 합계
```
실행 결과:
```
3.14
7
1
3
10
```

**주의 — `min`/`max`/`sum`은 받는 방식이 다르다**:

| 함수 | 값을 나열: `f(1, 2, 3)` | 리스트 하나: `f([1, 2, 3])` |
|---|---|---|
| `min`, `max` | ✅ 가능 | ✅ 가능 |
| `sum` | ❌ 에러 | ✅ 가능 (두 번째 인자는 "합계 시작값": `sum([1,2,3], 10)` → `16`) |

`min(3, 1, 2)`의 `3, 1, 2`는 리스트가 아니라 **각각 독립된 인자 3개**다. `min`/`max`는 "값을 나열해서 줘도 되고, 리스트로 통째로 줘도 되는" 두 가지 방식을 모두 지원하도록 만들어진 함수이고, `sum`은 리스트(등 반복 가능한 자료구조) 하나만 받도록 만들어진 함수라서 그렇다.

### 2-3. `any`, `all` — 리스트 전체를 조건으로 검사

```python
scores = [80, 90, 40, 70]
print(any(s < 50 for s in scores))   # 하나라도 50 미만이 있는가?
print(all(s >= 50 for s in scores))  # 전부 50 이상인가?
```
실행 결과:
```
True
False
```

- `any(...)`: 조건을 만족하는 게 **하나라도** 있으면 `True`
- `all(...)`: **전부 다** 조건을 만족해야 `True`

### 2-4. `map`, `filter` — 리스트 전체에 함수 적용하기

`01-python-basics.md`에서 `for`문으로 직접 돌리며 처리했던 걸, `map`/`filter`는 함수 하나로 표현한다.

```python
numbers = [1, 2, 3]
doubled = list(map(lambda x: x * 2, numbers))
print(doubled)
```
실행 결과:
```
[2, 4, 6]
```
`map(함수, 리스트)`는 "리스트의 각 값에 함수를 적용한 새 결과"를 만든다. `for`문으로 풀어 쓰면:
```python
doubled = []
for x in numbers:
    doubled.append(x * 2)
```
완전히 같은 결과다. (실무에서는 `for`문이나 컴프리헨션을 더 자주 쓰지만, `map`도 종종 보이므로 알아두면 좋다.)

```python
nums = [1, 2, 3, 4, 5, 6]
evens = list(filter(lambda x: x % 2 == 0, nums))
print(evens)
```
실행 결과:
```
[2, 4, 6]
```
`filter(조건함수, 리스트)`는 "조건이 `True`인 값들만 남긴 새 결과"를 만든다.

### 2-5. `reversed` — 순서 뒤집기

```python
print(list(reversed([1, 2, 3])))
```
실행 결과:
```
[3, 2, 1]
```

### 2-6. `input` — 사용자로부터 값 받기

```python
name = input("이름을 입력하세요: ")
print("안녕하세요,", name)
```
터미널에서 실행하면 입력을 기다리다가, 타이핑한 값이 `name`에 문자열로 들어간다. (숫자를 입력받아도 항상 문자열이므로 계산하려면 `int(input(...))`처럼 변환 필요.)

---

## 3. 표준 라이브러리 — 자주 쓰는 모듈 6가지

모두 `import 모듈이름` 한 줄만 있으면 바로 쓸 수 있다 (설치 불필요, 파이썬에 이미 포함됨).

### 3-1. `os` — 파일 경로, 폴더 다루기

```python
import os

path = os.path.join("data", "input.txt")
print(path)
```
실행 결과 (Windows):
```
data\input.txt
```
`os.path.join`은 폴더 이름과 파일 이름을 OS에 맞는 구분자(Windows는 `\`, Mac/Linux는 `/`)로 이어붙여준다. 직접 문자열로 `"data" + "\\" + "input.txt"`라고 쓰면 다른 OS에서 깨지니, 항상 `os.path.join`을 쓰는 게 안전하다.

자주 쓰는 다른 기능:
```python
os.makedirs("새폴더", exist_ok=True)   # 폴더 생성 (이미 있어도 에러 안 남)
os.path.exists("data/input.txt")        # 파일/폴더가 존재하는지 True/False
os.listdir(".")                          # 현재 폴더의 파일 목록
os.getcwd()                               # 현재 작업 폴더 경로
```

### 3-2. `sys` — 프로그램 실행 환경, 커맨드라인 인자

```python
import sys
print(sys.argv)     # 터미널에서 넘긴 인자 목록
sys.exit()            # 프로그램을 즉시 종료
```
커맨드라인에서 스크립트를 실행할 때 넘긴 값을 읽을 때 자주 쓰인다 (예: `sys.argv[1]`, `sys.argv[2]`).

### 3-3. `math` — 수학 함수

```python
import math

print(math.sqrt(16))      # 제곱근
print(math.pi)              # 원주율 상수
print(math.floor(3.7))       # 내림 (소수점 버림)
print(math.ceil(3.2))        # 올림
```
실행 결과:
```
4.0
3.141592653589793
3
4
```

### 3-4. `random` — 무작위 값 만들기

```python
import random

random.seed(42)              # 매번 같은 "무작위" 결과가 나오게 고정 (재현/디버깅용)
print(random.randint(1, 10))   # 1~10 사이 무작위 정수 (10 포함)
print(random.choice(["rock", "paper", "scissors"]))  # 리스트 중 하나를 무작위로 선택
```
실행 결과 (seed를 42로 고정했을 때):
```
2
rock
```
`random.seed(42)`를 안 넣으면 실행할 때마다 다른 결과가 나온다. (머신러닝 코드에서 자주 보는 `torch.manual_seed(...)`도 원리가 같다 — 무작위성을 고정해서 같은 실행 결과를 재현 가능하게 만드는 것.)

### 3-5. `datetime` — 날짜와 시간

```python
import datetime

now = datetime.datetime(2026, 9, 16, 10, 30)   # 연,월,일,시,분을 직접 지정
print(now.year, now.month, now.day)
print(now.strftime("%Y-%m-%d"))                  # 원하는 형식으로 문자열 변환
```
실행 결과:
```
2026 9 16
2026-09-16
```
실제 "지금 이 순간"을 얻고 싶으면 `datetime.datetime.now()`를 쓴다.

### 3-6. `json` — 데이터를 텍스트로 저장/불러오기

```python
import json

data = {"name": "Alice", "age": 30}
text = json.dumps(data)       # 딕셔너리 -> JSON 문자열
print(text)

parsed = json.loads(text)      # JSON 문자열 -> 딕셔너리
print(parsed["name"])
```
실행 결과:
```
{"name": "Alice", "age": 30}
Alice
```
API 서버 응답, 설정 파일, 로그 등 실무에서 데이터를 주고받을 때 JSON을 정말 많이 쓴다. 파이썬 딕셔너리와 JSON은 구조가 거의 똑같아서 `json` 모듈로 쉽게 왔다갔다 할 수 있다.

---

## 4. 요약 표

| 이름 | 종류 | import 필요? | 대표 용도 |
|---|---|---|---|
| `print`, `len`, `int`, `range`, `sorted`, `map`, `filter` 등 | 내장 함수 | ❌ | 언제나 바로 사용 |
| `os` | 표준 라이브러리 | ✅ `import os` | 파일/폴더 경로 |
| `sys` | 표준 라이브러리 | ✅ `import sys` | 실행 환경, 커맨드라인 인자 |
| `math` | 표준 라이브러리 | ✅ `import math` | 수학 계산 |
| `random` | 표준 라이브러리 | ✅ `import random` | 무작위 값 |
| `datetime` | 표준 라이브러리 | ✅ `import datetime` | 날짜/시간 |
| `json` | 표준 라이브러리 | ✅ `import json` | 데이터 저장/전송 형식 |
| `torch` 같은 것들 | **외부** 라이브러리 (표준 아님!) | ✅ `import torch` + `pip install` 필요 | 예: AI 모델 연산 |

`torch` 같은 외부 라이브러리는 표준 라이브러리가 아니라 **`pip install`로 따로 설치해야 하는 것**이라는 점을 구분해두자.

---

## 정리

여기까지가 자주 쓰는 내장 함수와 표준 라이브러리다. 필요할 때마다 이 문서를 참고하면서
실습하면 자연스럽게 익숙해진다.
