# 타입스크립트 학습 프로젝트

타입스크립트를 기초부터 차근차근 공부하기 위한 프로젝트.
각 주제는 `src/` 아래 번호가 매겨진 폴더로 정리하고, 폴더마다 설명(`.md`)과 실습 코드(`.ts`)를 함께 둔다.

## 준비

```bash
npm install
```

## 실습 코드 실행

```bash
npm run run src/01-basics/01-variables-and-types.ts
```

## 타입 체크만 하기 (컴파일 없이)

```bash
npm run check
```

## 목차

- [01. 변수와 기본 타입](src/01-basics/01-variables-and-types.md)
- [02. 함수 타입과 유니온/리터럴 타입](src/02-functions-and-unions/02-functions-and-unions.md)

## 다음에 공부할 것 (TODO)

- [ ] 인터페이스 vs 타입 별칭, 인터페이스 확장, readonly
- [ ] 인터섹션 타입
- [ ] 타입 좁히기(narrowing) 심화: `in`, `instanceof`, 커스텀 타입 가드
- [ ] 제네릭 기초
- [ ] 클래스와 접근 제어자
- [ ] enum
