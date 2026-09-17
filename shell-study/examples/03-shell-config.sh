#!/bin/bash
# alias / source / PATH 실습 스크립트
# 실행법: bash 03-shell-config.sh

echo "===== 데모 1: alias 정의와 사용 ====="
echo "스크립트(비대화형 쉘)에서는 기본적으로 alias가 확장 안 된다."
echo "-> shopt -s expand_aliases 로 강제로 켜줘야 스크립트 안에서도 alias가 동작한다."
shopt -s expand_aliases

alias greet="echo 안녕하세요"
greet
echo "-> 'greet'를 쳤지만 실제로는 'echo 안녕하세요'가 실행된 것"
echo ""

echo "-- unalias로 해제하면 더 이상 안 먹힌다:"
unalias greet
greet 2>&1 || echo "-> greet: command not found (alias가 사라져서 명령어로 인식 안 됨)"
echo ""

echo "===== 데모 2: alias vs 함수 - 인자를 받을 수 있는가 ====="
alias sayHi="echo Hi,"
echo "-- alias는 뒤에 오는 인자를 그냥 그대로 이어붙일 뿐이다:"
sayHi "claude"
echo ""

mkcd_demo() {
    local dir="$1"
    echo "함수 안에서 인자 처리: '$dir' 라는 이름으로 폴더를 만들고 그 안으로 이동하는 로직을 짤 수 있음"
    mkdir -p "/tmp/$dir" && cd "/tmp/$dir" && pwd
    cd - > /dev/null
    rm -rf "/tmp/$dir"
}
echo "-- 함수는 인자를 받아서 조건/로직을 짤 수 있다:"
mkcd_demo "alias_vs_func_test"
echo ""

echo "===== 데모 3: source vs bash 실행 - 변수가 살아남는가 ====="
tmpfile="/tmp/source_demo_vars.sh"
cat > "$tmpfile" <<'EOF'
DEMO_VAR="설정파일에서 정의된 값"
EOF

echo "-- bash로 실행 (자식 프로세스, 별도 환경):"
unset DEMO_VAR
bash "$tmpfile"
echo "실행 후 현재 쉘의 DEMO_VAR = '$DEMO_VAR'   (비어있어야 정상, 자식 프로세스 안에서만 설정됐으므로)"
echo ""

echo "-- source로 실행 (지금 쉘 안에서 직접 실행):"
unset DEMO_VAR
source "$tmpfile"
echo "실행 후 현재 쉘의 DEMO_VAR = '$DEMO_VAR'   (값이 남아있어야 정상, 지금 쉘에 반영됐으므로)"
rm -f "$tmpfile"
echo ""

echo "===== 데모 4: PATH - 명령어를 어디서 찾는지 ====="
echo "현재 PATH (일부만): $(echo "$PATH" | cut -d: -f1-3)..."
echo ""

mkdir -p /tmp/mybin
cat > /tmp/mybin/hello_cmd <<'EOF'
#!/bin/bash
echo "PATH에 등록된 내 스크립트가 실행됨"
EOF
chmod +x /tmp/mybin/hello_cmd

echo "-- PATH에 없는 상태에서 명령어 이름만으로 실행 시도:"
hello_cmd 2>&1 || echo "-> hello_cmd: command not found (PATH에 없어서 못 찾음)"
echo ""

echo "-- PATH 맨 앞에 /tmp/mybin 추가 후 다시 시도:"
export PATH="/tmp/mybin:$PATH"
hello_cmd
echo "-> 이제 명령어 이름만으로 실행됨 (PATH에 그 폴더가 등록됐기 때문)"

rm -rf /tmp/mybin
