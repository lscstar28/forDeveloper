# alias와 쉘 설정 파일 (.bashrc 등)

[02-shell-scripting.md](02-shell-scripting.md)에 이어서 정리한다. bash 기준.

---

## 1. alias — 명령어에 별명 붙이기

`alias`는 긴 명령어를 짧은 이름으로 줄여 쓰게 해주는 기능이다.

```bash
alias ll="ls -la"
alias gs="git status"
alias ..="cd .."

ll        # 실제로는 ls -la 가 실행됨
```

- 등록된 alias 목록 보기: `alias` (인자 없이)
- 특정 alias 해제: `unalias ll`
- **주의**: 이렇게 터미널에서 직접 친 `alias`는 그 세션에서만 유효하다. 터미널을 새로 열면 사라진다 → 영구적으로 쓰려면 아래 2번(`.bashrc`)에 적어야 한다.

### alias는 "인자를 받는 로직"을 못 짠다

alias는 그냥 문자열 치환에 가깝다. 조건 분기나 `$1` 같은 인자 처리가 필요하면 alias가 아니라 **함수**를 써야 한다.

```bash
# alias: 그냥 고정된 문자열 앞에 붙는 것 뿐
alias mkcd="mkdir -p"       # mkcd foo -> mkdir -p foo 는 되지만, 그 뒤에 cd까지 하고 싶으면 안 됨

# function: 인자를 받아서 로직을 짤 수 있음
mkcd() {
    mkdir -p "$1" && cd "$1"    # 폴더 만들고 그 안으로 즉시 이동
}
```

**정리: 단순 줄임말이면 alias, 인자를 받거나 여러 동작을 조합해야 하면 함수.**

---

## 2. 쉘 설정 파일 — 언제, 어떤 파일이 읽히는가

alias나 환경변수를 매번 새로 치기 귀찮으니, 쉘이 시작될 때 자동으로 읽는 설정 파일에 적어둔다. 문제는 **쉘이 어떻게 시작되었는지에 따라 읽는 파일이 다르다**는 것.

| 쉘 실행 방식 | bash가 읽는 파일 | 언제 해당하나 |
|---|---|---|
| 로그인 쉘 (login shell) | `~/.bash_profile` → 없으면 `~/.profile` | SSH 원격 접속, macOS 터미널.app(구버전), TTY 로그인 |
| 대화형 비로그인 쉘 (interactive non-login) | `~/.bashrc` | 이미 로그인된 상태에서 새 터미널 창/탭을 열 때 (가장 흔한 경우) |
| 비대화형 (스크립트 실행) | **아무것도 안 읽음** | `./script.sh` 실행, cron job 등 |

zsh는 파일 이름만 다르고 개념은 동일하다: `~/.zprofile`(로그인), `~/.zshrc`(대화형).

### 실무에서 흔한 패턴: `.bash_profile`이 `.bashrc`를 불러오게 하기

로그인 쉘에서도 alias가 똑같이 동작하길 원하면, `.bash_profile` 안에 아래처럼 적어서 `.bashrc`를 강제로 읽게 만드는 게 관용적인 방법이다.

```bash
# ~/.bash_profile 안에
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

### 왜 스크립트 실행할 땐 `.bashrc`가 하나도 안 먹히나

`./script.sh`는 "비대화형(non-interactive)" 쉘로 실행된다. 대화형 전용 설정(alias, 프롬프트 모양 등)까지 매번 로드하면 스크립트가 느려지고 예측 불가능해지므로, bash는 의도적으로 스크립트 실행 시 `.bashrc`를 읽지 않는다. 그래서 터미널에서 잘 되던 alias가 스크립트 안에서는 "명령어를 찾을 수 없음" 에러를 내는 경우가 흔하다.

---

## 3. `source` — 설정 파일을 "지금 이 쉘에" 즉시 적용하기

설정 파일(`.bashrc` 등)을 수정한 뒤, 터미널을 새로 열지 않고 지금 쉘에 바로 반영하고 싶으면 `source`를 쓴다.

```bash
source ~/.bashrc      # 정식 표기
. ~/.bashrc            # 위와 완전히 동일 (점 하나짜리 축약형, POSIX 표준)
```

`source`는 **파일을 새 프로세스로 실행하는 게 아니라, 지금 쉘 안에서 그 파일의 내용을 그대로 읽어서 실행**한다. 그래서 그 파일 안에서 정의한 변수/함수/alias가 지금 쉘에 그대로 남는다.

이게 `./script.sh`나 `bash script.sh`로 실행하는 것과 결정적으로 다른 점이다:

```bash
# other.sh 안에 x=100 이 있다고 하면

bash other.sh     # 새로운 자식 프로세스에서 실행됨 -> 끝나면 x=100은 사라짐 (부모 쉘엔 영향 없음)
source other.sh   # 지금 쉘 안에서 그대로 실행됨 -> x=100이 지금 쉘에 남음
```

이건 [00-syntax-basics.md](00-syntax-basics.md)에서 다룬 `( )` 서브쉘 vs `{ }` 그룹의 관계와 똑같은 원리다 — 새 프로세스(격리됨) vs 지금 프로세스(공유됨).

---

## 4. PATH — 명령어를 어디서 찾는지

`PATH`는 쉘이 명령어 이름(`ls`, `git` 등)을 입력받았을 때 **실제 실행 파일을 찾아볼 폴더 목록**을 담은 환경변수다. `:`로 구분된 경로 목록이다.

```bash
echo "$PATH"
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

내가 만든 스크립트를 어디서든 명령어처럼 부르고 싶으면, 그 스크립트가 있는 폴더를 PATH에 추가하면 된다. 보통 `.bashrc`에 적어서 영구적으로 만든다.

```bash
# ~/.bashrc 안에
export PATH="$HOME/bin:$PATH"
```

`$HOME/bin`을 맨 앞에 붙인 이유: PATH는 **앞에서부터 순서대로** 찾기 때문에, 같은 이름의 명령어가 시스템에도 있을 때 내가 만든 걸 우선시키려면 앞에 둬야 한다.

---

## 5. 실전 예시: `.bashrc`에 흔히 들어가는 내용

```bash
# ~/.bashrc

# --- alias ---
alias ll="ls -la"
alias gs="git status"
alias gp="git pull"
alias ..="cd .."
alias ...="cd ../.."

# --- 함수 (alias로는 안 되는 로직) ---
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# --- PATH 추가 ---
export PATH="$HOME/bin:$PATH"

# --- 환경변수 ---
export EDITOR="vim"

# --- 프롬프트 모양 바꾸기 (선택) ---
export PS1="\u@\h \W \$ "     # 사용자@호스트 현재폴더 $
```

---

## 6. 직접 실행해보는 예제

[examples/03-shell-config.sh](examples/03-shell-config.sh) 를 실행하면 alias/함수 차이, source vs bash 실행 차이를 직접 확인할 수 있다.

```bash
bash examples/03-shell-config.sh
```

---

## 다음에 공부할 것 (TODO)

- [ ] 정규표현식 심화 (`grep -E`, `sed -E`, capture group)
- [ ] `xargs`로 파이프 결과를 명령어 인자로 변환하기
- [ ] cron으로 스케줄링, systemd timer
- [ ] 여러 프로세스 동시 실행/제어 (`xargs -P`, `parallel`)
