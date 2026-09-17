#include <stdio.h>

int main(void) {
    /* 5. 변수와 자료형 */
    int age = 20;
    float price = 1500.5f;
    double pi = 3.14159265;
    char grade = 'A';

    printf("=== 변수와 자료형 ===\n");
    printf("age=%d, price=%.1f, pi=%f, grade=%c\n", age, price, pi, grade);
    printf("int 크기: %zu bytes\n\n", sizeof(int));

    /* 7. 연산자 */
    int a = 7, b = 2;

    printf("=== 연산자 ===\n");
    printf("a + b = %d\n", a + b);
    printf("a - b = %d\n", a - b);
    printf("a * b = %d\n", a * b);
    printf("a / b = %d (정수 나눗셈, 소수점 버림)\n", a / b);
    printf("a %% b = %d\n", a % b);
    printf("a / (double)b = %f\n\n", a / (double)b);

    /* 8. 조건문 */
    int score = 85;

    printf("=== 조건문 ===\n");
    if (score >= 90) {
        printf("등급: A\n");
    } else if (score >= 80) {
        printf("등급: B\n");
    } else {
        printf("등급: C 이하\n");
    }
    printf("\n");

    /* 9. 반복문 */
    printf("=== for 반복문 ===\n");
    for (int i = 0; i < 5; i++) {
        printf("%d ", i);
    }
    printf("\n\n");

    printf("=== while 반복문 ===\n");
    int i = 0;
    while (i < 5) {
        printf("%d ", i);
        i++;
    }
    printf("\n\n");

    printf("=== do-while 반복문 ===\n");
    int j = 0;
    do {
        printf("%d ", j);
        j++;
    } while (j < 5);
    printf("\n");

    return 0;
}
