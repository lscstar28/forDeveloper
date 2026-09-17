#include <stdio.h>

/* 3-3. 함수 프로토타입 선언 */
int add(int a, int b);
void greet(void);
void print_square(int n);
void try_change(int x);

int main(void) {
    /* 1. 함수 정의/호출, 매개변수/반환값 */
    printf("=== 함수 호출 ===\n");
    int result = add(3, 4);
    printf("add(3, 4) = %d\n\n", result);

    /* 2-1. 매개변수가 없는 함수 */
    greet();
    printf("\n");

    /* 2-2. 반환값이 없는 함수 */
    print_square(5);
    printf("\n");

    /* 2-3. 값에 의한 전달 (call by value) */
    printf("=== call by value ===\n");
    int num = 10;
    printf("호출 전 num=%d\n", num);
    try_change(num);
    printf("호출 후 num=%d (바뀌지 않음)\n", num);

    return 0;
}

/* 실제 정의는 main보다 아래에 있어도 프로토타입이 있어 문제없음 */
int add(int a, int b) {
    return a + b;
}

void greet(void) {
    printf("=== 매개변수 없는 함수 ===\n");
    printf("Hello!\n");
}

void print_square(int n) {
    printf("=== 반환값 없는 함수 ===\n");
    printf("%d의 제곱: %d\n", n, n * n);
}

void try_change(int x) {
    x = 100;   /* 복사본만 바뀜, 호출한 쪽의 원본에는 영향 없음 */
}
