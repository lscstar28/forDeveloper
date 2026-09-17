# CSS 기초

## 1. CSS란?

CSS(Cascading Style Sheets)는 HTML 요소의 **시각적 표현**(색상, 크기, 배치 등)을 정의한다. "Cascading(계단식)"이라는 이름처럼, 여러 규칙이 충돌할 때 **우선순위**에 따라 적용된다.

```html
<link rel="stylesheet" href="style.css" />
```

```css
/* style.css */
h1 {
  color: navy;
  font-size: 2rem;
}
```

### 선택자(Selector) 우선순위 (간단히)

```
!important > 인라인 스타일(style="...") > id(#id) > class/속성/가상클래스(.class, [attr], :hover) > 태그(h1, div)
```

같은 우선순위면 **나중에 선언된 것**이 적용된다. 우선순위 싸움이 잦아지면 이미 CSS 구조에 문제가 있다는 신호 — 특정성(specificity)을 억지로 높이기보다 클래스 구조를 정리하는 게 낫다.

---

## 2. 박스 모델 (Box Model)

모든 HTML 요소는 아래와 같은 사각형 박스로 렌더링된다.

```
┌─────────────────────────────┐
│           margin              │  ← 요소 바깥 여백 (다른 요소와의 간격)
│  ┌───────────────────────┐  │
│  │        border           │  │  ← 테두리
│  │  ┌─────────────────┐  │  │
│  │  │     padding       │  │  │  ← 테두리 안쪽 여백
│  │  │  ┌───────────┐  │  │  │
│  │  │  │  content   │  │  │  │  ← 실제 내용 (텍스트, 이미지 등)
│  │  │  └───────────┘  │  │  │
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

```css
.box {
  width: 200px;
  padding: 16px;
  border: 1px solid #ccc;
  margin: 8px;
  box-sizing: border-box; /* 아래 설명 */
}
```

### `box-sizing`이 중요한 이유

기본값(`content-box`)에서는 `width`가 **content 영역만**의 너비다. 즉 실제 차지하는 너비는 `width + padding*2 + border*2`가 돼서 계산이 복잡해진다.

```css
* {
  box-sizing: border-box; /* width에 padding, border를 포함시켜 계산 → 실무에서 거의 항상 이렇게 설정 */
}
```

`border-box`로 설정하면 `width: 200px`가 padding/border를 포함한 **최종 너비**가 되어 레이아웃 계산이 훨씬 직관적이다. 대부분의 CSS 리셋(reset)/정규화(normalize) 스타일에 기본 포함되어 있다.

---

## 3. Display와 포지셔닝 기초

```css
display: block;        /* 한 줄 전체 차지, width/height 지정 가능 (div, p, h1 등 기본값) */
display: inline;       /* 내용 크기만큼만 차지, width/height 무시됨 (span, a 등 기본값) */
display: inline-block; /* inline처럼 흐르지만 width/height 지정 가능 */
display: none;         /* 렌더링 자체를 안 함 (공간도 차지 안 함) */

position: static;   /* 기본값, 문서 흐름대로 배치 */
position: relative;  /* 원래 위치를 기준으로 top/left 등으로 이동, 공간은 원래대로 차지 */
position: absolute;  /* 가장 가까운 relative(또는 absolute/fixed) 조상을 기준으로 배치, 문서 흐름에서 빠짐 */
position: fixed;     /* 뷰포트(화면) 기준 고정, 스크롤해도 안 움직임 */
position: sticky;    /* 스크롤하다가 특정 지점에서 fixed처럼 고정 */
```

> `absolute`를 쓸 때는 반드시 부모 중 하나에 `position: relative`를 걸어줘야 의도한 대로 위치가 잡힌다. 이걸 빼먹는 게 초보자가 가장 흔히 하는 실수.

---

## 4. Flexbox — 1차원 레이아웃

한 줄(가로) 또는 한 열(세로)로 요소를 배치할 때 사용. 메뉴바, 카드 정렬, 요소 중앙 정렬에 가장 많이 쓰인다.

```css
.container {
  display: flex;
  flex-direction: row;        /* row(기본, 가로) | column(세로) */
  justify-content: center;    /* 주축(main axis) 정렬: flex-start | center | space-between | space-around */
  align-items: center;        /* 교차축(cross axis) 정렬: flex-start | center | stretch */
  gap: 16px;                  /* 요소 사이 간격 (margin보다 훨씬 편함) */
  flex-wrap: wrap;            /* 넘치면 다음 줄로 */
}

.item {
  flex: 1;   /* 남은 공간을 비율대로 나눠 가짐 (= flex-grow: 1) */
}
```

**"요소를 완벽하게 중앙 정렬하고 싶다"** → 가장 흔한 CSS 질문의 답:

```css
.center {
  display: flex;
  justify-content: center; /* 가로 중앙 */
  align-items: center;     /* 세로 중앙 */
}
```

---

## 5. Grid — 2차원 레이아웃

행과 열을 동시에 다뤄야 할 때(전체 페이지 레이아웃, 카드 그리드 등) 사용. Flexbox는 한 방향, Grid는 격자 전체를 다룬다는 차이가 핵심.

```css
.container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);  /* 동일한 비율로 3칸 */
  grid-template-columns: 200px 1fr 1fr;   /* 첫 칸은 고정, 나머지는 비율 */
  gap: 16px;
}

.item.wide {
  grid-column: span 2; /* 2칸 차지 */
}
```

```css
/* 전형적인 페이지 레이아웃 예시 */
.layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  grid-template-areas:
    "sidebar header"
    "sidebar main";
}
.sidebar { grid-area: sidebar; }
.header  { grid-area: header; }
.main    { grid-area: main; }
```

**Flexbox vs Grid 선택 기준**: 한 방향으로 나열(네비게이션, 버튼 그룹) → Flexbox. 행/열이 동시에 의미 있는 전체 레이아웃(대시보드, 갤러리) → Grid.

---

## 6. 반응형 디자인 (미디어 쿼리)

화면 크기에 따라 다른 스타일을 적용.

```css
/* 모바일 우선(Mobile First) 설계 — 기본 스타일은 작은 화면 기준으로 작성 */
.container {
  display: block;
}

@media (min-width: 768px) {
  /* 태블릿 이상 */
  .container {
    display: flex;
  }
}

@media (min-width: 1024px) {
  /* 데스크탑 이상 */
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

| 접근 방식 | 설명 |
|---|---|
| Mobile First | `min-width`로 작은 화면부터 큰 화면으로 점점 스타일 추가 (요즘 표준) |
| Desktop First | `max-width`로 큰 화면부터 작은 화면으로 스타일 재정의 |

`rem`(루트 요소 기준 상대 단위), `%`, `vw`/`vh`(뷰포트 기준) 같은 상대 단위를 활용하면 고정 픽셀(`px`)보다 반응형에 유리하다.

---

## 7. CSS 전처리기 / 유틸리티 프레임워크

순수 CSS만으로는 변수, 중첩, 재사용이 불편해서 아래 두 부류의 도구를 많이 쓴다.

### Sass/SCSS (전처리기 방식)

```scss
$primary-color: #3b82f6;

.card {
  padding: 16px;
  &:hover {          // 중첩 문법 (.card:hover)
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }
  .title {            // .card .title
    color: $primary-color;
  }
}
```

- 변수, 중첩, mixin(함수처럼 스타일 재사용), `@import`로 파일 분리 등을 지원
- 컴파일 과정을 거쳐 일반 CSS로 변환됨

### Tailwind CSS (유틸리티-퍼스트 방식)

```html
<div class="flex items-center gap-4 rounded-lg bg-blue-500 p-4 text-white hover:bg-blue-600">
  버튼
</div>
```

- 미리 정의된 작은 단위 클래스(`flex`, `p-4`, `text-white` 등)를 조합해서 스타일링
- 별도 CSS 파일을 거의 안 쓰고 HTML/JSX 안에서 바로 스타일 작성 → 클래스명 고민이 줄고, 안 쓰는 CSS가 안 쌓임(빌드 시 사용된 클래스만 추출)
- 최근 React/Next.js 프로젝트에서 특히 많이 채택됨

**선택 기준**: 팀/프로젝트 컨벤션을 따르는 게 우선이지만, 처음 시작이라면 **Tailwind**로 빠르게 결과물을 만들어보고, CSS 자체의 동작 원리(캐스케이딩, 박스 모델 등)는 순수 CSS로 따로 익혀두는 걸 추천한다.

---

## 다음에 공부할 것 (TODO)

- [ ] CSS 변수(`--my-color`)와 `var()` — 프레임워크 없이도 재사용 가능
- [ ] `transition`/`animation`으로 애니메이션 기초
- [ ] CSS-in-JS (styled-components, Emotion 등) 개념
- [ ] CSS Modules (React/Next.js에서 클래스 이름 충돌 방지)
- [ ] 브라우저 개발자도구로 실제 박스 모델/레이아웃 디버깅 실습

→ 다음: [03-javascript-basics.md](./03-javascript-basics.md)
