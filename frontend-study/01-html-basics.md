# HTML 기초

## 1. HTML이란?

HTML(HyperText Markup Language)은 웹 페이지의 **구조와 의미(semantic)**를 정의하는 마크업 언어다. "어떻게 보이는지"는 CSS, "어떻게 동작하는지"는 JavaScript가 담당하고, HTML은 "이게 뭔지"를 담당한다고 생각하면 된다.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>페이지 제목</title>
</head>
<body>
  <h1>안녕하세요</h1>
</body>
</html>
```

| 태그 | 역할 |
|---|---|
| `<!DOCTYPE html>` | HTML5 문서임을 브라우저에 선언 |
| `<html lang="ko">` | 문서의 언어 지정 (스크린리더, SEO에 영향) |
| `<meta charset="UTF-8">` | 문자 인코딩 지정 (한글 깨짐 방지) |
| `<meta name="viewport">` | 모바일 반응형의 기본 전제 조건 |

---

## 2. 시맨틱 태그 (Semantic HTML)

`<div>`만으로도 화면을 만들 순 있지만, **의미가 드러나는 태그**를 쓰면 검색엔진(SEO)과 스크린리더(접근성) 모두에게 "이 부분이 뭐 하는 곳인지"를 알려줄 수 있다.

```html
<body>
  <header>사이트 로고, 네비게이션</header>
  <nav>주요 메뉴 링크</nav>

  <main>
    <article>
      <h1>글 제목</h1>
      <section>
        <h2>소제목</h2>
        <p>본문 내용</p>
      </section>
    </article>

    <aside>사이드바, 관련 글 목록</aside>
  </main>

  <footer>저작권, 연락처</footer>
</body>
```

| 태그 | 의미 |
|---|---|
| `<header>` | 페이지 또는 섹션의 머리말 |
| `<nav>` | 내비게이션(메뉴) 영역 |
| `<main>` | 페이지의 핵심 콘텐츠 (문서당 1개만) |
| `<article>` | 독립적으로 의미를 갖는 콘텐츠 (블로그 글, 뉴스 기사 등) |
| `<section>` | 주제로 묶이는 구획 |
| `<aside>` | 본문과 간접적으로 관련된 부가 콘텐츠 |
| `<footer>` | 페이지 또는 섹션의 꼬리말 |
| `<div>` / `<span>` | 의미 없는 범용 컨테이너 (다른 시맨틱 태그가 없을 때만) |

> 판단 기준: "이 태그가 없어져도 콘텐츠의 의미가 그대로인가?" → 그렇다면 `div`로 충분. 의미를 잃는다면 시맨틱 태그를 쓴다.

---

## 3. 폼 (Form)

사용자 입력을 서버로 전송하는 표준 방법.

```html
<form action="/login" method="POST">
  <label for="email">이메일</label>
  <input type="email" id="email" name="email" required />

  <label for="password">비밀번호</label>
  <input type="password" id="password" name="password" required minlength="8" />

  <button type="submit">로그인</button>
</form>
```

| 속성 | 설명 |
|---|---|
| `action` | 제출 시 요청을 보낼 URL |
| `method` | `GET`(조회성) 또는 `POST`(생성/변경성) |
| `type="email"`, `type="password"` 등 | 브라우저가 기본 검증 UI를 제공 (모바일 키보드도 자동으로 맞춰짐) |
| `required` | 비어있으면 제출 막기 (HTML만으로 하는 기초 검증) |
| `<label for="...">` | 클릭 시 해당 input에 포커스 이동, **스크린리더가 이 필드가 뭔지 읽어주는 핵심 요소** |

실무에서는 React 등 프레임워크로 폼을 다룰 때도, 실제로 렌더링되는 결과는 결국 이 HTML 요소들이라는 걸 기억해두면 디버깅이 쉬워진다.

---

## 4. 접근성 (a11y) 기초

"a11y" = "a" + 11글자 + "y" (accessibility의 줄임말). 시각/청각/운동 장애가 있는 사용자, 또는 스크린리더·키보드만으로 조작하는 사용자도 문제없이 쓸 수 있게 만드는 것.

### 핵심 원칙

- **의미 있는 태그를 우선 사용** (`<button>` 대신 `<div onclick>` 쓰지 않기 — 키보드 포커스/Enter 동작이 기본 제공 안 됨)
- **이미지에는 항상 `alt`** — 스크린리더가 읽어줄 대체 텍스트

  ```html
  <img src="logo.png" alt="회사 로고" />
  <img src="decorative-line.png" alt="" />  <!-- 장식용 이미지는 빈 alt -->
  ```

- **폼 요소에는 `label` 연결** (위 3번 참고)
- **키보드만으로 모든 기능에 접근 가능해야 함** (Tab으로 이동, Enter/Space로 실행)
- **명도 대비(color contrast)** — 텍스트와 배경색 대비가 충분해야 함
- **ARIA 속성**은 시맨틱 태그로 해결 안 될 때 보조 수단으로 사용

  ```html
  <button aria-label="닫기" onclick="closeModal()">✕</button>
  <div role="alert">저장되었습니다</div>
  ```

> ARIA의 첫 번째 규칙: "적절한 시맨틱 HTML 태그가 있다면 ARIA보다 그걸 먼저 써라." ARIA는 HTML만으로 표현이 안 될 때의 보조 수단이다.

---

## 5. 자주 쓰는 태그 정리

```html
<!-- 텍스트 -->
<p>문단</p>
<strong>중요함 (의미상 굵게)</strong>
<em>강조 (의미상 기울임)</em>

<!-- 목록 -->
<ul><li>순서 없는 목록</li></ul>
<ol><li>순서 있는 목록</li></ol>

<!-- 링크/이미지 -->
<a href="/about" target="_blank" rel="noopener noreferrer">소개 페이지</a>
<img src="photo.jpg" alt="설명" width="300" height="200" />

<!-- 표 -->
<table>
  <thead><tr><th>이름</th><th>나이</th></tr></thead>
  <tbody><tr><td>철수</td><td>20</td></tr></tbody>
</table>
```

> `target="_blank"`로 새 탭을 열 때는 `rel="noopener noreferrer"`를 함께 써주는 게 보안상 권장된다 (새 탭이 원본 페이지의 `window.opener`를 악용하는 걸 방지).

---

## 다음에 공부할 것 (TODO)

- [ ] `<script>` 태그의 `defer`/`async` 차이와 로딩 성능
- [ ] 메타 태그로 SEO/공유 미리보기 설정 (Open Graph, `<meta name="description">`)
- [ ] `<template>`, `<slot>` 등 웹 컴포넌트 관련 태그
- [ ] 시맨틱/접근성 검사 도구 실습 (Lighthouse, axe)

→ 다음: [02-css-basics.md](./02-css-basics.md)
