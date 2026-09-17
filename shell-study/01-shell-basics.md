# 쉘(Shell) 기초

## 1. 쉘이란?

쉘(Shell)은 사용자가 입력한 명령어를 해석해서 운영체제(커널)에 전달하고, 그 결과를 다시 보여주는 프로그램이다.
즉, **사람과 OS 사이의 인터페이스** 역할을 한다.

대표적인 쉘 종류:

| 쉘 | 설명 |
|---|---|
| `bash` | Linux/Mac에서 가장 널리 쓰이는 기본 쉘 |
| `zsh` | macOS 기본 쉘 (Catalina 이후) |
| `sh` | POSIX 표준 쉘, 스크립트 호환성이 높음 |
| `PowerShell` | Windows용 쉘, 객체 기반 파이프라인 |
| `cmd.exe` | Windows의 전통적인 쉘 (기능이 제한적) |

이 학습 폴더에서는 **bash/POSIX 쉘 기준**으로 정리하고, Windows 환경 차이는 별도로 표시한다.

---

## 2. 기본 탐색 명령어

```bash
pwd                 # 현재 위치(경로) 출력
ls                  # 현재 폴더의 파일/폴더 목록
ls -la              # 숨김파일 포함, 상세 정보(권한, 크기, 날짜)
cd 경로              # 폴더 이동
cd ..               # 상위 폴더로 이동
cd ~                # 홈 디렉토리로 이동
cd -                # 바로 이전 위치로 이동
```

---

## 3. 파일/폴더 조작

```bash
mkdir 폴더명              # 폴더 생성
mkdir -p a/b/c            # 중간 경로까지 한번에 생성

touch 파일명               # 빈 파일 생성 (또는 수정시간 갱신)

cp 원본 대상               # 파일 복사
cp -r 원본폴더 대상폴더      # 폴더 전체 복사

mv 원본 대상               # 이동 또는 이름 변경

rm 파일명                 # 파일 삭제
rm -r 폴더명              # 폴더 삭제 (하위 포함)
rm -rf 폴더명             # 강제 삭제 (묻지 않음) → 주의해서 사용
```

> ⚠️ `rm -rf`는 되돌릴 수 없다. 삭제 전에 `ls`로 대상을 다시 확인하는 습관을 들이자.

---

## 4. 파일 내용 확인

```bash
cat 파일명            # 파일 전체 내용 출력
less 파일명           # 페이지 단위로 보기 (q로 종료)
head -n 10 파일명     # 앞 10줄
tail -n 10 파일명     # 뒤 10줄
tail -f 로그파일       # 실시간으로 추가되는 내용 계속 보기 (로그 확인에 유용)
wc -l 파일명          # 줄 수 세기
```

---

## 5. 검색

```bash
grep "찾을문자열" 파일명        # 파일 안에서 문자열 검색
grep -r "찾을문자열" 폴더명      # 폴더 전체를 재귀적으로 검색
grep -i "abc" 파일명           # 대소문자 무시
grep -n "abc" 파일명           # 줄번호 표시

find . -name "*.txt"          # 현재 위치부터 이름으로 파일 찾기
find . -type d -name "src"    # 폴더만 찾기
```

---

## 6. 파이프(`|`)와 리다이렉션(`>`, `>>`, `<`)

쉘의 핵심 개념. 명령어를 조합해서 하나의 처리 흐름을 만든다.

```bash
명령어1 | 명령어2      # 명령어1의 출력을 명령어2의 입력으로 전달 (파이프)

ls -la | grep ".md"   # 목록 중 .md 파일만 필터링

command > 파일         # 출력을 파일에 저장 (기존 내용 덮어쓰기)
command >> 파일        # 출력을 파일 끝에 추가
command < 파일         # 파일 내용을 입력으로 사용
command 2> 에러파일     # 에러(stderr)만 파일로 저장
command > out.txt 2>&1 # 표준출력 + 에러를 모두 같은 파일로
```

---

## 7. 변수와 환경변수

```bash
name="claude"          # 변수 선언 (= 양옆에 공백 없이!)
echo $name             # 변수 사용
echo "${name}_test"    # 중괄호로 변수 경계 명확히

export MY_VAR="value"  # 환경변수로 지정 (하위 프로세스에서도 접근 가능)
echo $PATH              # PATH 환경변수 확인
```

---

## 8. 실행 권한과 프로세스 (Linux/Mac 기준)

```bash
chmod +x script.sh      # 실행 권한 부여
./script.sh             # 현재 폴더의 스크립트 실행

ps aux                  # 실행 중인 프로세스 목록
kill PID                # 프로세스 종료
kill -9 PID             # 강제 종료
```

---

## 9. 자주 쓰는 조합 예시

```bash
# 현재 폴더에서 .log로 끝나는 파일 중 "ERROR" 포함된 줄만 찾기
grep "ERROR" *.log

# 파일 개수 세기
ls | wc -l

# 특정 문자열이 포함된 파일들만 찾아서 그 파일 이름 출력
grep -rl "TODO" .

# 명령어 실행 결과를 파일로 저장하면서 화면에도 보기
command | tee output.txt
```

---

## 10. 참고: PowerShell 대응 명령어 (Windows)

| bash | PowerShell | 설명 |
|---|---|---|
| `pwd` | `pwd` / `Get-Location` | 현재 경로 |
| `ls` | `ls` / `Get-ChildItem` | 목록 |
| `cat` | `cat` / `Get-Content` | 파일 내용 |
| `cp` | `Copy-Item` | 복사 |
| `mv` | `Move-Item` | 이동/이름변경 |
| `rm` | `Remove-Item` | 삭제 |
| `grep` | `Select-String` | 문자열 검색 |
| `export VAR=x` | `$env:VAR = "x"` | 환경변수 설정 |

---

## 다음에 공부할 것 (TODO)

- [ ] 쉘 스크립트 작성 (`#!/bin/bash`, 조건문, 반복문)
- [ ] 함수와 인자(`$1`, `$@`, `$#`)
- [ ] 프로세스 관리 (`&`, `jobs`, `fg`, `bg`)
- [ ] alias, `.bashrc` / `.zshrc` 설정
