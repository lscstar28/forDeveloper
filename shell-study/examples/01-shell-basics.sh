#!/bin/bash
# 쉘 기초 명령어 실습 스크립트
# 실행법: bash 01-shell-basics.sh
#
# 01-shell-basics.md 의 2~7번 챕터(탐색/파일조작/내용확인/검색/파이프/변수)를
# 실제로 실행해서 확인한다. 전부 /tmp 안 임시 폴더에서만 작업하고 끝나면 정리한다.

SANDBOX="/tmp/shell_basics_demo"
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"
cd "$SANDBOX" || exit 1

echo "===== 데모 1: 기본 탐색 (pwd, ls, cd) ====="
echo "현재 위치: $(pwd)"
mkdir -p sub1 sub2
touch sub1/a.txt sub2/b.txt
echo "-- ls (기본):"
ls
echo "-- ls -la (숨김파일 + 상세정보):"
ls -la | head -5
echo ""
echo "-- cd sub1 후 pwd, 그다음 cd - 로 이전 위치 복귀:"
cd sub1
pwd
cd - > /dev/null
pwd
echo ""

echo "===== 데모 2: 파일/폴더 조작 (mkdir, touch, cp, mv, rm) ====="
mkdir -p project/src
echo "-- mkdir -p project/src : 중간 경로까지 한 번에 생성됨"
ls -R project
echo ""

touch project/src/main.js
echo "-- cp로 복사:"
cp project/src/main.js project/src/main.backup.js
ls project/src
echo ""

echo "-- mv로 이름 변경:"
mv project/src/main.backup.js project/src/main.bak
ls project/src
echo ""

echo "-- rm으로 삭제:"
rm project/src/main.bak
ls project/src
echo ""

echo "===== 데모 3: 파일 내용 확인 (cat, head, tail, wc) ====="
seq 1 20 > numbers.txt
echo "-- cat numbers.txt (전체 출력):"
cat numbers.txt | tr '\n' ' '
echo ""
echo "-- head -n 3 numbers.txt (앞 3줄):"
head -n 3 numbers.txt
echo "-- tail -n 3 numbers.txt (뒤 3줄):"
tail -n 3 numbers.txt
echo "-- wc -l numbers.txt (줄 수 세기):"
wc -l numbers.txt
echo ""

echo "===== 데모 4: 검색 (grep, find) ====="
cat > log.txt <<'EOF'
INFO: server started
ERROR: connection refused
INFO: retrying
ERROR: timeout
EOF

echo "-- grep 'ERROR' log.txt (문자열 검색):"
grep "ERROR" log.txt
echo ""
echo "-- grep -n 'ERROR' log.txt (줄번호 포함):"
grep -n "ERROR" log.txt
echo ""
echo "-- grep -i 'error' log.txt (대소문자 무시):"
grep -i "error" log.txt
echo ""
echo "-- find . -name '*.txt' (이름으로 파일 찾기):"
find . -name "*.txt"
echo ""

echo "===== 데모 5: 파이프(|)와 리다이렉션(>, >>, <) ====="
echo "-- 파이프: ls -la project/src | grep '.js' 로 결과 필터링:"
ls -la project/src | grep ".js"
echo ""

echo "-- > : 출력을 파일로 저장 (덮어쓰기)"
echo "첫 줄" > redirect_test.txt
cat redirect_test.txt
echo ""

echo "-- >> : 파일 끝에 추가"
echo "두번째 줄" >> redirect_test.txt
cat redirect_test.txt
echo ""

echo "-- < : 파일 내용을 입력으로 사용 (wc -l < 파일)"
wc -l < numbers.txt
echo ""

echo "===== 데모 6: 변수와 환경변수 ====="
name="claude"
echo "-- 변수 선언 후 사용: echo \$name -> $name"
echo "-- 중괄호로 경계 명확히: echo \"\${name}_test\" -> ${name}_test"
echo ""

echo "-- export 전: 자식 프로세스(bash -c)에서 변수가 안 보임"
MY_VAR="hello"
bash -c 'echo "자식 프로세스의 MY_VAR = [$MY_VAR]"'
echo ""

echo "-- export 후: 자식 프로세스에서도 보임"
export MY_VAR
bash -c 'echo "자식 프로세스의 MY_VAR = [$MY_VAR]"'
echo ""

echo "===== 데모 7: 자주 쓰는 조합 ====="
echo "-- 파일 개수 세기: ls | wc -l"
ls | wc -l
echo ""
echo "-- ERROR가 포함된 파일 이름만 찾기: grep -rl 'ERROR' ."
grep -rl "ERROR" .
echo ""
echo "-- tee: 결과를 파일로 저장하면서 화면에도 보기"
echo "tee 테스트" | tee tee_output.txt
cat tee_output.txt

cd /tmp
rm -rf "$SANDBOX"
