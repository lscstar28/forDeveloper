#!/bin/bash
# set 옵션 실습 스크립트
#
# 실행법: bash 01-set-options.sh
#         (또는 chmod +x 01-set-options.sh 후 ./01-set-options.sh)
#
# set은 "쉘 자신의 동작 옵션을 켜고 끄는" 내장 명령어다.
#   set -옵션문자   → 옵션을 켠다 (- = on)
#   set +옵션문자   → 옵션을 끈다 (+ = off)
# 아래 각 데모를 하나씩 주석 풀어가며 눌러보면 동작 차이가 눈에 보인다.

echo "===== 데모 1: set 옵션이 없는 기본 상태 ====="
echo "아래 명령어는 존재하지 않는 파일을 cat 하려는 명령이다. 실패해도 스크립트는 안 멈춘다."
cat /no/such/file.txt
echo "-> 여기까지 실행됨 (기본값은 명령이 실패해도 다음 줄로 계속 진행)"
echo ""

echo "===== 데모 2: set -e (errexit) ====="
(
  set -e
  echo "set -e 켠 상태에서 실행 중..."
  cat /no/such/file.txt
  echo "-> 이 줄은 절대 출력되지 않는다. 위에서 실패한 순간 이 서브쉘이 즉시 종료됨"
)
echo "-> (괄호로 묶은 서브쉘이라 위에서 죽어도 메인 스크립트는 계속 진행됨)"
echo ""

echo "===== 데모 3: set -u (nounset) ====="
(
  set -u
  echo "set -u 켠 상태에서 정의 안 된 변수를 사용해본다."
  echo "값: $UNDEFINED_VAR"
  echo "-> 이 줄도 출력되지 않는다. 위에서 '변수가 정의되지 않았다'는 에러로 즉시 종료됨"
)
echo ""

echo "===== 데모 3-1: set -e 와 set -u 는 서로 다른 걸 감시한다 (직접 비교) ====="
echo "-- 케이스 A: 명령어 자체가 '정상적으로 실행됐지만 실패로 끝남' (grep이 매칭 못함)"
echo "   -> set -u 만 켜져 있으면 이건 절대 못 잡는다. u는 변수 참조만 감시하기 때문."
(
  set -u
  echo "set -u 만 켠 상태에서 grep 실패 명령 실행..."
  echo "hello world" | grep "ZZZ_NOT_FOUND_PATTERN_ZZZ"
  echo "-> 이 줄이 출력된다! grep이 실패(exit 1)했어도 set -u는 아무 반응 안 함"
)
echo ""

echo "-- 케이스 B: 명령어(echo) 자체는 실패할 이유가 없지만, 참조하는 변수가 원래 없음"
echo "   -> set -e 만 켜져 있으면 이건 절대 못 잡는다. e는 '명령 실행 결과'만 보기 때문."
(
  set -e
  echo "set -e 만 켠 상태에서 미정의 변수 참조..."
  echo "값: $TYPO_VAR"
  echo "-> 이 줄도 출력된다! \$TYPO_VAR가 빈 문자열로 조용히 치환되고 echo는 성공(exit 0)"
)
echo ""
echo "-> 결론: -e는 '실행 결과가 실패인가'를 보고, -u는 '참조하는 변수가 원래 존재하는가'를 본다."
echo "   서로 다른 종류의 실수를 잡기 때문에 보통 -eu를 같이 켠다."
echo ""

echo "===== 데모 4: set -x (xtrace, 디버깅용) ====="
echo "set +x 는 set -x 로 켠 추적을 다시 끄는 것 (+ = 옵션 끄기, - = 옵션 켜기)."
echo "실전에서는 의심 가는 구간만 -x ~ +x 로 감싸서 그 부분만 로그를 본다."
(
  set -x
  name="claude"
  count=$((1 + 2))
  echo "이름=$name, 합계=$count"
  set +x
)
echo "-> 켜져 있는 동안 실행되는 명령어가 '+ ' 접두어로 화면에 그대로 찍힌다."
echo "-> 'set +x' 자기 자신도 한 번 찍히는 이유: bash는 명령을 '실행하기 직전에' 찍는다."
echo "   -> 추적을 끄는 효과는 그 다음 명령부터 적용되므로, 끄는 명령 자신은 마지막으로 찍힘."
echo ""

echo "===== 데모 4-1: -o 는 '옵션을 이름으로 켜는' 범용 스위치일 뿐이다 ====="
echo "-e 와 -o errexit 가 완전히 같은 효과를 낸다는 걸 확인해본다."
(
  set -e
  cat /no/such/file.txt 2>/dev/null
  echo "-> 이 줄은 출력 안 됨 (set -e가 즉시 종료시킴)"
)
echo "위 서브쉘 종료코드: $?"
echo ""
(
  set -o errexit
  cat /no/such/file.txt 2>/dev/null
  echo "-> 이 줄도 출력 안 됨 (set -o errexit 는 set -e와 완전히 같은 옵션)"
)
echo "위 서브쉘 종료코드: $?   (-e 와 동일하게 동작했다)"
echo ""
echo "-- pipefail은 왜 항상 -o랑 같이 다니나: 한 글자짜리 단축키가 아예 없기 때문."
echo "   그래서 'set -p' 같은 건 없고, 'set -o pipefail'만 가능하다."
echo ""
echo "-- 현재 켜져있는 옵션 전체 목록 보기: set -o (인자 없이)"
set -o | grep -E "errexit|nounset|xtrace|pipefail"
echo ""

echo "===== 데모 5: pipefail (파이프 중간 실패 감지) ====="
echo "wc -l 은 입력이 없어도 그냥 '0줄'이라며 성공(exit 0)해버린다."
echo "즉 앞의 cat이 실패했다는 사실이 뒤의 wc 때문에 가려질 수 있는 상황이다."
echo ""
echo "-- pipefail 없이: 파이프의 종료코드는 '맨 마지막 명령(wc)' 것만 본다"
cat /no/such/file.txt | wc -l
echo "파이프 종료코드: $? (0 = 성공. cat이 실패했는데도 성공으로 잡힘)"
echo ""

echo "-- pipefail 켠 상태: 파이프 중 하나라도 실패하면 전체를 실패로 처리"
(
  set -o pipefail
  cat /no/such/file.txt | wc -l
  echo "파이프 종료코드: $? (0이 아니면 cat의 실패가 제대로 감지된 것)"
)
echo ""

echo "===== 데모 6: 실무에서 스크립트 맨 위에 관용적으로 쓰는 조합 ====="
echo 'set -euo pipefail'
echo "-> e: 실패 시 즉시 중단 / u: 미정의 변수 에러 / o pipefail: 파이프 중간 실패도 감지"
echo "   세 개를 합쳐서 '조용히 실패한 채 계속 진행되는' 상황을 최대한 막는 안전장치다."
