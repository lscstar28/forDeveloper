#!/bin/bash
# 쉘 문법 기초 실습 스크립트
# 실행법: bash 00-syntax-basics.sh
#
# 00-syntax-basics.md 의 각 챕터를 눈으로 직접 확인하기 위한 데모.
# 실패해도 스크립트가 멈추지 않도록 이 파일 자체는 set -e를 켜지 않는다.

echo "===== 데모 1: 세미콜론(;) = 줄바꿈과 동일 ====="
echo "A"; echo "B"
echo "-> 한 줄에 썼지만 두 개의 echo가 각각 실행됨 (위 두 줄과 동일한 효과)"
echo ""

echo "===== 데모 2: && 와 || 의 조건부 실행 ====="
true && echo "true 다음 && -> 이 줄은 실행됨"
false && echo "이 줄은 절대 출력되지 않음 (앞이 실패했으므로)"
false || echo "false 다음 || -> 이 줄은 실행됨 (앞이 실패했으므로)"
echo ""

echo "===== 데모 3: 백슬래시(\\)로 줄 이어쓰기 ====="
echo "이것은" \
     "한 줄로" \
     "취급된다"
echo ""

echo "===== 데모 4: word splitting - 공백 없는 변수는 위험 ====="
mkdir -p /tmp/word_split_demo && cd /tmp/word_split_demo || exit 1
rm -f -- *
file="my report.txt"

echo "-- 따옴표 없이 touch \$file 실행 (2개의 인자로 쪼개짐):"
touch $file
ls -1
rm -f -- *
echo ""

echo "-- 따옴표로 감싸서 touch \"\$file\" 실행 (1개의 인자로 전달됨):"
touch "$file"
ls -1
cd - > /dev/null
rm -rf /tmp/word_split_demo
echo ""

echo "===== 데모 5: 인용부호 3종 비교 ====="
name="World"
echo 'single quote: Hello $name'     # 그대로 문자로 출력
echo "double quote: Hello $name"     # 변수 확장됨
echo Hello\ $name                    # backslash로 공백만 escape
echo ""

echo "===== 데모 6: ( ) 서브쉘 vs { } 그룹 명령 ====="
x=1
( x=2 )
echo "서브쉘 ( x=2 ) 사용 후 바깥의 x = $x   (서브쉘 안 변경은 바깥에 영향 없음 → 그대로 1)"

x=1
{ x=2; }
echo "그룹 { x=2; } 사용 후 바깥의 x = $x   (같은 쉘이라 값이 바뀜 → 2)"
echo ""

echo "===== 데모 7: 산술 평가 (( )) 와 산술 치환 \$(( )) ====="
a=3
b=4
if (( a < b )); then
    echo "(( a < b )) 는 조건문으로도 쓸 수 있다: 3 < 4 는 참"
fi
result=$((a + b))
echo "결과값을 꺼내려면 \$(( )) 사용: a + b = $result"
echo ""

echo "===== 데모 8: [ ] vs [[ ]] ====="
a="hello"
if [ "$a" = "hello" ]; then
    echo "[ ] 사용: [ 는 사실 test 명령어라서 양쪽에 공백이 꼭 필요하다"
fi
if [[ $a == hello ]]; then
    echo "[[ ]] 사용: bash 확장 문법. 변수에 따옴표 없이도 비교적 안전하게 동작"
fi
echo ""

echo "===== 데모 9: 중괄호 확장 { } (glob이 아니라 '펼치기'다) ====="
echo file{a,b,c}.txt
echo num{1..5}
echo ""

echo "===== 데모 10: 인용부호가 glob(경로명 확장)을 막는다 ====="
mkdir -p /tmp/glob_demo && cd /tmp/glob_demo || exit 1
touch a.txt b.txt
echo "-- 따옴표 없이 echo *.txt (쉘이 실제 파일 목록으로 미리 펼침):"
echo *.txt
echo "-- 따옴표로 echo \"*.txt\" (펼쳐지지 않고 문자 그대로):"
echo "*.txt"
cd - > /dev/null
rm -rf /tmp/glob_demo
echo ""

echo "===== 데모 10-1: glob 패턴 종류 비교 (*, ?, [...]) ====="
mkdir -p /tmp/glob_patterns && cd /tmp/glob_patterns || exit 1
touch file1.txt file2.txt file10.txt fileA.txt report.md
echo "생성된 파일: $(ls)"
echo ""
echo "-- * : 아무 문자나 0개 이상 (길이 상관없음)"
echo "   file*.txt ->" file*.txt
echo ""
echo "-- ? : 아무 문자나 정확히 1개"
echo "   file?.txt -> (file10.txt는 숫자 2글자라 매칭 안 됨)"
echo "   file?.txt ->" file?.txt
echo ""
echo "-- [...] : 대괄호 안 문자 중 하나"
echo "   file[12].txt ->" file[12].txt
echo ""
echo "-- 매칭되는 파일이 하나도 없으면? 패턴 문자열 그대로 출력됨"
echo "   *.zzz ->" *.zzz
cd - > /dev/null
rm -rf /tmp/glob_patterns
echo ""

echo "===== 데모 11: exit - 종료코드를 남기고 즉시 종료 ====="
echo "exit는 스크립트를 즉시 끝내는 명령어다. 여기서는 서브쉘 안에서 실행해서"
echo "메인 스크립트는 안 죽게 하고, 종료코드(\$?)만 확인해본다."
(
    echo "서브쉘 진입. 지금 exit 3 으로 종료해본다."
    exit 3
)
echo "서브쉘의 종료코드: $?   (exit 3을 줬으니 3이 찍혀야 정상)"
echo ""
echo "-- cd 실패 시 exit 1로 멈추는 흔한 가드 패턴:"
(
    cd /no/such/dir 2>/dev/null || { echo "cd 실패 -> exit 1로 종료"; exit 1; }
    echo "이 줄은 절대 출력되지 않는다"
)
echo "서브쉘의 종료코드: $?   (cd가 실패해서 exit 1로 끝났어야 함)"
echo ""

echo "===== 데모 12: -- (end of options) - 옵션처럼 생긴 파일명 다루기 ====="
mkdir -p /tmp/dashdemo && cd /tmp/dashdemo || exit 1
rm -f -- *
touch -- -weird-file.txt
echo "생성된 파일 목록:"
ls -1

echo "-- '--' 없이 rm으로 지우면 어떻게 되는지 (rm이 옵션으로 착각해서 에러):"
rm -weird-file.txt 2>&1 || echo "-> 보다시피 실패함 (알 수 없는 옵션 취급됨)"

echo "-- '--'를 붙여서 지우면 (뒤에 오는 건 전부 파일명으로 처리됨):"
rm -- -weird-file.txt
echo "삭제 후 파일 목록:"
ls -1
echo "(비어있으면 -- 덕분에 정상적으로 삭제된 것)"

cd - > /dev/null
rm -rf /tmp/dashdemo
