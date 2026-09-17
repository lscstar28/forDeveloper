# 쉘 스크립트 심화

[01-shell-basics.md](01-shell-basics.md)의 TODO를 이어서 정리한다. bash 기준.

## 1. 스크립트 기본 구조

```bash
#!/bin/bash
# 첫 줄 shebang: 이 파일을 어떤 인터프리터로 실행할지 지정

set -e    # 명령어 실패 시 즉시 스크립트 종료
set -u    # 정의되지 않은 변수 사용 시 에러
set -x    # 실행되는 명령어를 그대로 출력 (디버깅용)
set -euo pipefail  # 실무에서 관용적으로 묶어서 쓰는 조합
```

실행 방법:

```bash
chmod +x script.sh
./script.sh          # shebang대로 실행
bash script.sh        # 권한 없어도 실행 가능
```

`set -euo pipefail`에서 `pipefail`은 파이프(`|`)로 연결된 명령 중 하나라도 실패하면 전체를 실패로 처리한다. 기본값은 마지막 명령의 성공/실패만 본다.

### `-o`는 "옵션"이 아니라 옵션을 켜는 범용 메커니즘이다

`-o`와 `pipefail`이 항상 붙어 다녀서 하나의 세트처럼 보이지만, 실제로는 역할이 전혀 다른 두 가지다.

- **`-o`**: "다음에 오는 긴 이름의 옵션을 켜라"는 범용 스위치. `set -e`, `set -u`, `set -x` 같은 한 글자 옵션들은 전부 긴 이름을 갖고 있고, `-o 긴이름`으로도 똑같이 켤 수 있다.
- **`pipefail`**: 그 긴 이름들 중 하나일 뿐. 다만 `pipefail`은 **한 글자짜리 단축 옵션이 아예 없어서**, `-o pipefail` 형태로만 켤 수 있다.

| 짧은 옵션 | 긴 이름 (`-o`로 켜는 법) | 
|---|---|
| `-e` | `set -o errexit` |
| `-u` | `set -o nounset` |
| `-x` | `set -o xtrace` |
| *(없음)* | `set -o pipefail` ← 단축키가 없어서 `-o`가 유일한 방법 |

즉 `-o`와 `pipefail`이 항상 같이 보이는 이유는 "짝이라서"가 아니라, **pipefail을 켜는 방법이 `-o` 말고는 없기 때문**이다.

끄는 법도 대칭적이다: `-`가 켜기라면 `+`가 끄기이듯, `-o`로 켠 옵션은 `+o`로 끈다.

```bash
set -o pipefail     # pipefail 켜기
set +o pipefail     # pipefail 끄기
set -o              # 현재 켜져있는 모든 옵션 목록 보기
```

### `set -euo pipefail`을 실제로 어떻게 쪼개서 읽는가

이 한 줄은 사실 옵션 3개가 압축된 것이다. 짧은 옵션끼리는 붙여 쓸 수 있고, 마지막 `o`는 "다음 단어(`pipefail`)를 긴 이름으로 받는다"는 뜻이라 아래와 완전히 동일하다.

```bash
set -euo pipefail

# 풀어서 쓰면 이것과 같다:
set -e
set -u
set -o pipefail
```

`-e`와 `-u`를 묶어서 `-eu`까지만 썼어도 됐을 텐데 `-euo pipefail`처럼 `o`까지 붙인 이유는, `o`도 결국 "옵션 하나"이고 그 옵션의 값(`pipefail`)이 바로 뒤 단어로 따라오기 때문이다.

### `set -e` vs `set -u` — 둘 다 "스크립트 종료"지만 감지하는 대상이 다르다

결과만 보면 둘 다 "뭔가 잘못되면 스크립트를 멈춘다"라서 같아 보이지만, **무엇을 감시하는지가 완전히 다르다.**

| | `set -e` (errexit) | `set -u` (nounset) |
|---|---|---|
| 감시 대상 | **명령어의 종료코드(exit status)** | **변수 참조 그 자체** |
| 언제 걸리나 | 명령어가 다 실행되고 나서, 그 결과가 실패(0이 아님)일 때 | 명령을 실행하기도 전에, `$변수`를 값으로 바꿔치는(확장하는) 단계에서 |
| 잡아내는 실수 종류 | "명령이 실행됐는데 실패했다" (파일 없음, 권한 없음, grep 매칭 안됨 등) | "애초에 존재하지 않는 변수 이름을 불렀다" (변수명 오타, 초기화를 안 함) |
| 대표적으로 못 잡는 것 | 변수가 비어있는 채로 조용히 실행되는 것 (오타 등) | 명령어 자체가 실패하는 것 (`-u`는 명령 실행 결과엔 관심 없음) |

즉 `set -e`는 **"실행 결과가 실패냐"**를 보고, `set -u`는 **"참조하는 이름이 원래 존재하냐"**를 본다. 완전히 다른 층위의 검사다.

```bash
# set -e 가 잡는 경우: 명령어는 정상적으로 "실행됐지만" 결과가 실패(exit 1)
grep "없는문자열" file.txt
echo "이 줄까지 왔다면 set -e가 없거나, grep이 매칭에 실패해도 스크립트가 안 죽은 것"

# set -u 가 잡는 경우: 명령어(echo)는 원래 성공할 수 있는 명령이지만,
# 참조하는 변수($TYPO_VAR)가 아예 정의된 적이 없어서 "명령 실행 전"에 바로 에러
echo "$TYPO_VAR"
```

두 번째 예시가 핵심이다. `echo`는 실패할 이유가 없는 명령이다. 그런데 `set -u`가 켜져 있으면 `$TYPO_VAR`를 값으로 바꾸려는 순간(=명령을 실행하기도 전에) "이 변수는 정의된 적이 없다"며 그 자리에서 즉시 종료시킨다. `set -e`만 켜져 있었다면 이 줄은 `TYPO_VAR`가 빈 문자열로 조용히 치환되어 `echo`가 그냥 성공(exit 0)해버리고, 오타를 낸 사실을 아무도 알아채지 못한다.

정리하면:
- `set -e` = "실행한 명령이 실패로 끝나면 멈춰라" → **런타임 실패 감지**
- `set -u` = "정의도 안 된 변수를 부르려고 하면 멈춰라" → **오타/미초기화 감지 (명령 실행 여부와 무관)**

그래서 실무에서는 이 둘을 항상 같이 켠다. 서로 겹치지 않는, 서로 다른 종류의 실수를 잡아주기 때문이다.

[examples/02-set-options.sh](examples/02-set-options.sh) 를 실행하면 `-e`/`-u`/`-x`/`pipefail` 옵션들의 차이를 직접 눈으로 확인할 수 있다.

```bash
bash examples/02-set-options.sh
```

---

## 2. 인자(Arguments)

```bash
#!/bin/bash
echo "스크립트 이름: $0"
echo "첫 번째 인자: $1"
echo "두 번째 인자: $2"
echo "전체 인자 개수: $#"
echo "전체 인자 (단어 분리됨): $@"
echo "전체 인자 (하나의 문자열): $*"
echo "마지막 명령어 종료코드: $?"
echo "현재 프로세스 PID: $$"
```

`"$@"`와 `"$*"`의 차이는 실무에서 중요하다.
- `"$@"` → 인자를 각각 따로 유지 (공백 포함 인자도 안전하게 전달됨)
- `"$*"` → 인자를 전부 합쳐 하나의 문자열로

```bash
for arg in "$@"; do echo "$arg"; done   # 항상 이렇게 쓰는 게 안전
```

---

## 3. 조건문

```bash
if [ "$1" = "start" ]; then
    echo "시작"
elif [ "$1" = "stop" ]; then
    echo "정지"
else
    echo "알수없음"
fi
```

### `fi`는 왜 필요한가 — 블록을 "닫는" 키워드

bash는 파이썬처럼 들여쓰기로 블록 범위를 판단하지 않는다. `if`로 블록을 열었으면, **어디서 그 블록이 끝나는지 쉘에게 명시적으로 알려줘야** 하고, 그 역할을 하는 게 `fi`다. `fi`를 빼먹으면 "블록이 안 닫혔다"는 문법 에러가 난다.

같은 패턴이 반복문/분기문에도 있다 — 여는 키워드와 닫는 키워드가 항상 쌍으로 다닌다:

| 여는 키워드 | 닫는 키워드 | 용도 |
|---|---|---|
| `if` | `fi` | 조건문 |
| `for` / `while` / `until` | `done` | 반복문 (4번 챕터) |
| `case` | `esac` | 다중 분기 |

`fi`는 `if`를 거꾸로 쓴 것이고 `esac`도 `case`를 거꾸로 쓴 것 — 옛 Bourne 쉘 시절부터 내려온 관례로, 블록의 끝을 눈에 띄게 하기 위함이다 (`done`만 예외적으로 거꾸로가 아니다). 참고로 `{ }`로 그룹을 묶을 때는 [00-syntax-basics.md](00-syntax-basics.md)에서 다뤘듯 `{`와 `}`를 쓰고, `fi`/`done`/`esac` 같은 키워드는 안 쓴다 — 그건 그룹 명령 문법이지 조건/반복문 문법이 아니기 때문.

자주 쓰는 테스트 조건:

```bash
[ -f 파일 ]      # 파일이 존재하고 일반 파일인가
[ -d 폴더 ]      # 디렉토리가 존재하는가
[ -e 경로 ]      # 존재하는가 (파일/폴더 무관)
[ -z "$var" ]    # 문자열이 비어있는가
[ -n "$var" ]    # 문자열이 비어있지 않은가
[ "$a" = "$b" ]  # 문자열 같은가
[ "$a" -eq "$b" ]  # 숫자 같은가 (-ne, -gt, -lt, -ge, -le)

# [[ ]] 는 bash 확장 문법: 더 안전하고 && || 를 바로 쓸 수 있음
if [[ "$1" == "start" && -f "./config.yml" ]]; then
    echo "설정파일 있음, 시작 가능"
fi
```

> `[ ]`는 실제로 `test` 명령어다. `[[ ]]`는 bash 키워드라 변수에 따옴표 안 붙여도 덜 위험하지만, 습관적으로 따옴표는 항상 붙이는 게 좋다.

---

## 4. 반복문

```bash
# for - 리스트
for f in *.log; do
    echo "처리중: $f"
done

# for - 범위
for i in {1..5}; do
    echo "$i"
done

# for - C 스타일
for ((i=0; i<5; i++)); do
    echo "$i"
done

# while
count=0
while [ "$count" -lt 5 ]; do
    echo "$count"
    count=$((count + 1))
done

# until (조건이 참이 될 때까지)
until [ -f ready.flag ]; do
    sleep 1
done

# 파일을 한 줄씩 읽기 (가장 안전한 패턴)
while IFS= read -r line; do
    echo "라인: $line"
done < input.txt
```

`while read`에서 `IFS=`와 `-r`을 꼭 붙이는 이유: 앞뒤 공백/백슬래시가 있는 줄도 원본 그대로 읽기 위함.

---

## 5. 함수

```bash
greet() {
    local name="$1"          # local: 함수 안에서만 유효한 변수
    echo "안녕, $name"
    return 0                  # 종료코드 반환 (0=성공)
}

greet "claude"

# 함수 결과값을 "받아오려면" echo + command substitution 사용
get_sum() {
    echo $(( $1 + $2 ))
}
result=$(get_sum 3 4)
echo "$result"    # 7
```

- 함수는 값을 `return`할 수 없다 (종료코드 0~255만 가능). 데이터를 돌려주려면 `echo`로 출력하고 바깥에서 `$(...)`로 캡처한다.
- `local`을 안 쓰면 함수 안 변수가 전역을 덮어써버리니 항상 습관화.

---

## 6. 명령어 치환 & 산술 연산

```bash
today=$(date +%Y-%m-%d)      # 명령어 치환 (권장 문법)
today=`date +%Y-%m-%d`        # 옛 문법, 가독성/중첩 어려움 → 지양

total=$((3 + 4 * 2))          # 정수 산술 연산
echo "$total"                 # 11

# 부동소수점은 bash 기본으로 안 되므로 bc나 awk 사용
echo "scale=2; 10/3" | bc     # 3.33
```

---

## 7. 배열

```bash
arr=(apple banana cherry)
echo "${arr[0]}"        # apple
echo "${arr[@]}"        # 전체 요소
echo "${#arr[@]}"        # 요소 개수

arr+=(durian)            # 요소 추가

for item in "${arr[@]}"; do
    echo "$item"
done
```

---

## 8. 문자열 다루기

```bash
str="Hello_World.txt"

echo "${str%.txt}"       # Hello_World      (뒤에서 매칭 제거, 최소매칭)
echo "${str%%.*}"        # Hello_World      (뒤에서 매칭 제거, 최대매칭)
echo "${str#Hello_}"     # World.txt        (앞에서 매칭 제거)
echo "${str/World/Test}" # Hello_Test.txt   (첫번째 치환)
echo "${str//l/L}"       # HeLLo_WorLd.txt  (전체 치환)
echo "${#str}"           # 문자열 길이
echo "${str,,}"          # 소문자로
echo "${str^^}"          # 대문자로

: "${VAR:=default}"      # VAR가 비어있으면 default로 설정 (설정값 기본값 패턴)
```

---

## 9. Heredoc (여러 줄 입력)

### `EOF`는 예약어가 아니라 그냥 "내가 정한 끝 표식"이다

Heredoc(here document)은 **여러 줄짜리 텍스트를 명령어의 표준입력(stdin)으로 그대로 흘려보내는 문법**이다. 파일을 따로 만들지 않고 스크립트 안에 텍스트 블록을 박아넣을 때 쓴다.

```bash
cat <<EOF
1번째 줄
2번째 줄
EOF
```

여기서 `EOF`는 bash 문법이 아니라 **사용자가 마음대로 정하는 이름표**다. "End Of File"의 약자라서 관례적으로 `EOF`를 많이 쓸 뿐, `END`나 `그만` 같은 아무 단어를 써도 똑같이 동작한다.

```bash
cat <<끝
안녕
끝
```

동작 원리를 순서대로 보면:

1. `<<EOF`를 만나면 쉘은 "다음 줄부터, `EOF`라는 글자만 단독으로 있는 줄이 나올 때까지가 전부 텍스트 블록이다"라고 인식한다.
2. 그 사이의 모든 줄을 그대로 모아서, `<<EOF` 앞에 있는 명령어의 **표준입력**으로 던져준다.
3. 닫는 `EOF`(여는 것과 글자가 정확히 같아야 함)를 만나면 블록이 끝난다.

> 주의: 닫는 쪽 `EOF`는 그 줄에 **그 글자만 딱** 있어야 한다. 앞에 공백이 있으면(`  EOF`처럼) 기본적으로는 인식이 안 된다. 들여쓰기를 허용하려면 `<<-EOF`처럼 하이픈을 붙이면 되는데, 이때는 앞의 **탭(tab)만** 무시된다 (스페이스는 안 됨).

### 안에서 변수가 치환되는지 여부: 여는 쪽 `EOF`에 따옴표를 붙이느냐

```bash
ENVIRONMENT="production"

# 따옴표 없는 EOF: 안의 $변수, $(명령치환) 이 전부 확장된다
cat <<EOF
env: $ENVIRONMENT
EOF
# 출력: env: production

# 따옴표 붙인 'EOF': 안의 내용이 전부 글자 그대로(literal), 확장이 하나도 안 일어난다
cat <<'EOF'
env: $ENVIRONMENT
EOF
# 출력: env: $ENVIRONMENT   (문자 그대로 출력됨)
```

이건 [00-syntax-basics.md](00-syntax-basics.md)에서 다룬 `"..."` vs `'...'` 인용부호 규칙과 완전히 같은 원리다. `<<EOF`(따옴표 없음)는 `"안"`처럼 확장이 되고, `<<'EOF'`(따옴표 있음)는 `'안'`처럼 글자 그대로 취급된다.

### 파일에 저장하기: `cat > 파일 <<'EOF'` 패턴

`cat`은 원래 "받은 입력을 그대로 출력하는" 명령어다. 여기에 `>` 리다이렉션([01-shell-basics.md](01-shell-basics.md) 6번 챕터)을 붙이면, "heredoc으로 받은 텍스트를 화면 대신 파일에 쓰기"가 된다 — **파일을 안 만들고도 여러 줄짜리 파일을 스크립트 안에서 즉석으로 생성하는** 실무 관용구다.

```bash
cat > config.yml <<'EOF'
name: myapp
env: production
EOF
# config.yml 이라는 파일이 위 두 줄 내용으로 새로 생성됨 (덮어쓰기)
```

읽는 순서: `cat`을 실행하는데, 출력은 `config.yml`로 보내고(`>`), 입력은 heredoc 블록으로 받는다(`<<'EOF'`). `'EOF'`처럼 따옴표를 붙인 이유는 안의 내용을 스크립트 실행 시점에 확장하지 않고 글자 그대로 파일에 쓰고 싶어서다 (예: 안에 `$변수`라는 글자를 진짜로 남기고 싶을 때).

```bash
# 스크립트 템플릿을 만들 때: $1이 지금 당장 치환되면 안 되고, 나중에 그 스크립트가
# 실행될 때 치환돼야 하므로 반드시 따옴표 붙은 'EOF'를 써야 한다
cat <<'EOF' > script_template.sh
echo "$1은 실행 시점에 치환됨"
EOF
```

---

## 10. 프로세스 제어

```bash
long_task &        # 백그라운드로 실행
echo "PID: $!"      # 방금 백그라운드로 던진 프로세스의 PID

jobs                # 현재 쉘의 백그라운드 작업 목록
fg %1                # 1번 작업을 포그라운드로
bg %1                # 1번 작업을 다시 백그라운드로

wait                 # 모든 백그라운드 작업이 끝날 때까지 대기
wait $!               # 특정 PID가 끝날 때까지 대기

trap 'echo "종료 신호 받음"; exit 1' SIGINT SIGTERM   # 시그널 핸들링
trap 'rm -f "$tmpfile"' EXIT     # 스크립트 종료 시 항상 정리(cleanup) 실행 - 매우 실무적인 패턴
```

---

## 11. sed / awk 맛보기

```bash
# sed: 텍스트 치환/삭제
sed 's/foo/bar/' file.txt          # 첫 매칭만 치환 (출력만, 파일은 안 바뀜)
sed 's/foo/bar/g' file.txt         # 전체 치환
sed -i 's/foo/bar/g' file.txt      # 파일 자체를 수정 (-i)
sed '/^#/d' file.txt                # #으로 시작하는 줄(주석) 삭제

# awk: 컬럼 기반 처리
awk '{print $1}' file.txt          # 첫 번째 컬럼(공백 기준) 출력
awk -F',' '{print $2}' file.csv    # 구분자를 ,로 지정 후 두번째 컬럼
awk '$3 > 100 {print $0}' data.txt # 세번째 컬럼이 100 초과인 줄만
```

---

## 12. 실전 스크립트 예시: 로그 백업

```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/myapp"
BACKUP_DIR="/var/backup/myapp"
DATE=$(date +%Y%m%d)

mkdir -p "$BACKUP_DIR"

if [ ! -d "$LOG_DIR" ]; then
    echo "에러: 로그 디렉토리가 없습니다: $LOG_DIR" >&2
    exit 1
fi

tar -czf "${BACKUP_DIR}/log_${DATE}.tar.gz" -C "$LOG_DIR" .
echo "백업 완료: ${BACKUP_DIR}/log_${DATE}.tar.gz"

# 7일 지난 백업 삭제
find "$BACKUP_DIR" -name "log_*.tar.gz" -mtime +7 -delete
```

이 예시에서 실무 패턴들: `set -euo pipefail`, 사전 조건 체크 후 `exit 1`, 에러는 `>&2`(stderr)로 출력, 변수는 항상 `"$VAR"`처럼 따옴표로 감싸기, 정리 로직(오래된 파일 삭제)까지 포함.

---

## 13. 디버깅 팁

```bash
bash -x script.sh          # 실행하면서 각 라인을 그대로 출력
bash -n script.sh           # 문법 체크만 (실행 안 함)
shellcheck script.sh        # 정적 분석 도구 (설치 필요) - 실무에서 거의 필수
```

---

## 다음에 공부할 것 (TODO)

이어서 [03-shell-config.md](03-shell-config.md)에서 `alias`와 `.bashrc` 설정을 다룬다.

- [ ] 정규표현식 심화 (`grep -E`, `sed -E`, capture group)
- [ ] `xargs`로 파이프 결과를 명령어 인자로 변환하기
- [ ] cron으로 스케줄링, systemd timer
- [ ] 여러 프로세스 동시 실행/제어 (`xargs -P`, `parallel`)
