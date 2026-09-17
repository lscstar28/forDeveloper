# Git 심화

[01-git-basics.md](./01-git-basics.md)에서 다루지 않은 심화 명령어와, 실무에서 쓰이는 협업 워크플로를 정리한다.

---

## 1. Rebase

`merge`가 두 브랜치의 이력을 그대로 합치는(부모가 2개인 커밋을 만드는) 방식이라면, `rebase`는 **내 브랜치의 커밋들을 다른 브랜치 끝에 다시 쌓아서** 이력을 일직선으로 만드는 방식이다.

```bash
git switch feature/login
git rebase main                # main의 최신 커밋 위에 feature/login의 커밋들을 재적용
```

### merge vs rebase

| | merge | rebase |
|---|---|---|
| 이력 모양 | 브랜치가 갈라졌다 합쳐지는 그래프 유지 | 일직선(linear)으로 정리됨 |
| 새 커밋 | merge 커밋 1개 추가 | 기존 커밋들을 새 커밋으로 재작성 (해시가 바뀜) |
| 충돌 처리 | 병합 시점에 한 번에 처리 | 재적용되는 커밋마다 순서대로 처리해야 할 수 있음 |
| 안전성 | 기존 커밋을 건드리지 않음 | **커밋 해시가 바뀌므로, 이미 push해서 남이 받아간 브랜치에서는 금지** |

> ⚠️ **황금률**: 이미 원격에 push되어 다른 사람이 pull 받았을 수도 있는 브랜치(특히 `main`)는 **절대 rebase하지 않는다.** 개인 작업 브랜치(아직 아무도 안 받아간)에서만 사용한다.

### 대화형 rebase (interactive rebase)

커밋을 합치거나, 순서를 바꾸거나, 메시지를 수정할 때 사용. PR 올리기 전에 "지저분한 커밋 이력을 정리"하는 용도로 가장 많이 쓴다.

```bash
git rebase -i HEAD~3            # 최근 3개 커밋을 대화형으로 편집
```

에디터가 열리면 각 커밋 앞에 명령어를 적어서 처리한다.

```
pick a1b2c3 로그인 폼 작성
pick d4e5f6 오타 수정
pick g7h8i9 콘솔 로그 제거
```

| 명령어 | 동작 |
|---|---|
| `pick` | 그대로 유지 |
| `reword` | 커밋은 유지, 메시지만 수정 |
| `edit` | 해당 커밋에서 멈춰서 내용 수정 가능 |
| `squash` | 바로 이전 커밋과 합치되, 메시지도 합쳐서 편집 |
| `fixup` | 바로 이전 커밋과 합치고, 메시지는 버림 (조용히 합치기) |
| `drop` | 커밋 삭제 |

```bash
# 예: "오타 수정", "콘솔 로그 제거" 커밋을 첫 커밋에 합쳐서 깔끔한 커밋 1개로 만들기
pick a1b2c3 로그인 폼 작성
fixup d4e5f6 오타 수정
fixup g7h8i9 콘솔 로그 제거
```

충돌 발생 시:

```bash
git rebase --continue           # 충돌 해결 후 계속 진행
git rebase --skip               # 해당 커밋 건너뛰기
git rebase --abort              # rebase 전체 취소, 원래 상태로 복구
```

---

## 2. Cherry-pick

다른 브랜치의 **특정 커밋 하나만** 현재 브랜치로 가져올 때 사용.

```bash
git cherry-pick <커밋해시>        # 해당 커밋만 현재 브랜치에 적용
git cherry-pick <해시1> <해시2>   # 여러 개도 가능
git cherry-pick --continue       # 충돌 해결 후 계속
git cherry-pick --abort          # 취소
```

**용도**: 예를 들어 `feature` 브랜치에서 만든 버그 수정 커밋 하나를, 이미 배포된 `hotfix` 브랜치에도 똑같이 반영하고 싶을 때 브랜치 전체를 merge하지 않고 그 커밋만 가져올 수 있다.

---

## 3. Stash (상세)

작업 중이던 변경사항을 커밋하지 않고 잠시 치워둘 때 사용.

```bash
git stash                        # 변경사항을 스택에 저장, 워킹 디렉토리는 깨끗해짐
git stash save "메시지"           # 설명을 붙여서 저장
git stash list                   # 저장된 stash 목록 확인
git stash show -p stash@{0}      # 특정 stash의 상세 diff 확인

git stash pop                    # 가장 최근 stash를 적용하고 스택에서 제거
git stash apply stash@{1}        # 특정 stash를 적용 (스택에는 남겨둠)
git stash drop stash@{1}         # 특정 stash 삭제
git stash clear                  # 전체 삭제

git stash -u                     # 추적되지 않은(untracked) 새 파일까지 포함해서 저장
git stash branch 새브랜치명        # stash 내용으로 새 브랜치를 만들어 적용 (충돌 위험 클 때 유용)
```

**전형적인 상황**: 급한 버그 수정 요청이 와서 지금 하던 작업을 잠깐 치워두고 다른 브랜치로 이동해야 할 때.

---

## 4. Tag

릴리즈 버전 등 특정 커밋에 이름을 붙여 영구적으로 표시할 때 사용. 브랜치와 달리 태그가 가리키는 커밋은 보통 바뀌지 않는다.

```bash
git tag                          # 태그 목록
git tag v1.0.0                   # 경량(lightweight) 태그 생성 - 현재 커밋에
git tag -a v1.0.0 -m "첫 정식 릴리즈"  # 주석(annotated) 태그 - 작성자/날짜/메시지 포함, 릴리즈용으로 권장

git push origin v1.0.0           # 특정 태그를 원격에 push
git push origin --tags           # 모든 태그를 원격에 push (기본 push는 태그를 안 보냄)

git checkout v1.0.0              # 해당 태그 시점으로 이동 (detached HEAD 상태)
git tag -d v1.0.0                # 로컬 태그 삭제
git push origin --delete v1.0.0  # 원격 태그 삭제
```

---

## 5. 커밋 메시지 컨벤션 (Conventional Commits)

팀/오픈소스에서 널리 쓰이는 커밋 메시지 규칙. 자동으로 CHANGELOG를 생성하거나 릴리즈 버전을 결정하는 도구와도 연동된다.

```
<타입>(<범위>): <요약>

<본문 (선택)>

<푸터 (선택)>
```

| 타입 | 의미 |
|---|---|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서만 변경 |
| `style` | 코드 동작에 영향 없는 포맷팅 (세미콜론, 들여쓰기 등) |
| `refactor` | 기능 변경 없는 코드 구조 개선 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 설정 등 기타 잡일 |

```
feat(auth): 소셜 로그인 기능 추가

카카오/구글 OAuth 로그인을 지원한다.

BREAKING CHANGE: 기존 로그인 API 응답 형식이 변경됨
```

---

## 6. Git hooks

특정 시점(커밋 전, push 전 등)에 스크립트를 자동으로 실행시키는 기능. `.git/hooks/` 폴더에 스크립트를 넣으면 동작한다 (파일명에서 `.sample` 제거 + 실행권한 부여).

| 훅 | 실행 시점 | 주 용도 |
|---|---|---|
| `pre-commit` | 커밋 생성 직전 | 린트, 포맷팅, 타입체크 |
| `commit-msg` | 커밋 메시지 작성 후 | 커밋 메시지 규칙 검사 |
| `pre-push` | push 직전 | 테스트 실행 |

`.git/hooks`는 저장소를 clone해도 공유되지 않기 때문에, 실무에서는 [Husky](https://typicode.github.io/husky/) 같은 도구로 hooks 설정 자체를 프로젝트에 커밋해서 팀 전체에 공유한다.

```bash
npm install husky --save-dev
npx husky init
echo "npm run lint" > .husky/pre-commit   # 커밋 전 lint 자동 실행
```

---

## 7. Reflog (복구용 안전망)

`reset --hard`나 브랜치 삭제로 "커밋이 사라진 것처럼" 보여도, Git은 로컬에서 HEAD가 가리켰던 위치를 한동안 기록해둔다.

```bash
git reflog                       # HEAD의 이동 이력 확인
git reset --hard HEAD@{2}        # 2번 전 상태로 복구
git branch 복구브랜치 <reflog에서_찾은_커밋해시>  # 사라진 커밋을 새 브랜치로 복구
```

> reflog는 기본적으로 로컬 저장소에만 존재하고(원격에는 없음), 기본 90일(도달 불가능한 커밋은 30일) 후 만료된다. "실수했다"고 당황하지 말고 먼저 `git reflog`부터 확인하는 습관을 들이자.

---

## 8. Bisect (버그 커밋 찾기)

이진 탐색으로 "언제부터 버그가 생겼는지"를 빠르게 찾는 도구.

```bash
git bisect start
git bisect bad                   # 현재 커밋은 버그 있음
git bisect good v1.0.0           # 이 커밋은 정상이었음

# Git이 중간 지점 커밋으로 자동 체크아웃 → 직접 테스트 후 결과 입력
git bisect good                  # 또는
git bisect bad

# 반복하면 Git이 "문제가 시작된 첫 커밋"을 찾아줌
git bisect reset                 # 종료하고 원래 브랜치로 복귀
```

---

## 9. 협업 워크플로

### 9-1. 브랜치 전략 비교

| 전략 | 특징 | 적합한 상황 |
|---|---|---|
| **GitHub Flow** | `main` + 짧은 수명의 `feature` 브랜치. PR로 바로 `main`에 병합, 병합되면 바로 배포 | 지속적 배포(CD)를 하는 웹 서비스, 대부분의 팀에 추천되는 기본값 |
| **Git Flow** | `main`(배포용) + `develop`(통합) + `feature`/`release`/`hotfix` 브랜치를 역할별로 분리 | 정식 버전 릴리즈 주기가 있는 소프트웨어 (앱, 패키지 등) |
| **Trunk-based Development** | 모두가 `main`(trunk) 하나에 아주 작은 단위로 자주 병합, feature flag로 미완성 기능 숨김 | 배포 자동화가 잘 갖춰진 대규모 팀 |

실무에서는 대부분 **GitHub Flow**로 시작해서 필요해지면 다른 전략을 섞어 쓴다.

### 9-2. Fork & PR 워크플로 (오픈소스/외부 기여자)

팀 내부 저장소는 보통 브랜치를 직접 만들지만, 쓰기 권한이 없는 저장소(오픈소스 등)에는 아래 방식을 쓴다.

```bash
# 1. GitHub에서 저장소를 내 계정으로 Fork
# 2. 내 Fork를 로컬로 clone
git clone https://github.com/내계정/repo.git
cd repo

# 3. 원본 저장소를 upstream으로 등록
git remote add upstream https://github.com/원본계정/repo.git

# 4. 작업 전 항상 upstream 최신 상태를 받아옴
git fetch upstream
git switch -c feature/fix-typo upstream/main

# 5. 작업 후 "내 Fork"로 push
git push -u origin feature/fix-typo

# 6. GitHub에서 "내 Fork → 원본 저장소"로 PR 생성
```

### 9-3. PR 병합 방식 3가지

GitHub 등에서 PR을 병합할 때 선택할 수 있는 방식. 팀 컨벤션에 맞춰 하나로 통일하는 것이 좋다.

| 방식 | 결과 | 특징 |
|---|---|---|
| **Merge commit** | 3-way merge 커밋 생성 | 브랜치의 모든 커밋 이력이 그대로 `main`에 남음 |
| **Squash and merge** | PR의 모든 커밋을 **하나로 합쳐서** 커밋 1개로 병합 | `main` 이력이 깔끔해짐 (PR 단위 = 커밋 1개). 작업 중 커밋을 세밀히 관리 안 해도 됨 |
| **Rebase and merge** | PR의 커밋들을 그대로 `main` 끝에 rebase | 이력은 일직선이면서 개별 커밋도 유지됨 |

- 커밋 이력을 깔끔하게 유지하고 싶고 PR 안의 커밋 단위가 크게 의미 없다면 → **Squash**
- 커밋 단위 자체가 의미 있게 잘 쪼개져 있다면 → **Rebase and merge**
- 브랜치가 어떻게 진행됐는지 그래프로 남기고 싶다면 → **Merge commit**

### 9-4. 코드 리뷰 관례

- PR은 작게 쪼갠다 (리뷰어가 한 번에 이해할 수 있는 크기, 대략 수백 줄 이내 권장)
- PR 설명에 **무엇을, 왜** 바꿨는지 적는다 (코드만 봐도 알 수 있는 "무엇"보다 "왜"가 더 중요)
- 리뷰 코멘트에 대한 대응(수정 or 논의)을 커밋으로 추가 → 리뷰 완료 후 필요하면 squash
- Draft PR: 아직 리뷰 준비가 안 됐지만 미리 공유하고 싶을 때 사용
- CI(테스트, 린트, 빌드)가 통과해야 병합 가능하도록 브랜치 보호 규칙(branch protection) 설정

### 9-5. 충돌을 줄이는 협업 습관

- 작업 시작 전 `git fetch` + `main` 기준으로 브랜치 생성 (오래된 브랜치에서 작업 시작하지 않기)
- 큰 기능은 작은 PR로 여러 번 나눠서 병합 (긴 수명의 브랜치일수록 충돌 커짐)
- 작업 중간에도 주기적으로 `main`을 내 브랜치에 반영 (`git merge main` 또는 `git rebase main`)
- 포맷팅 도구(Prettier 등)와 설정을 팀 전체가 통일 — 포맷 차이로 인한 불필요한 충돌 방지

---

## 다음에 공부할 것 (TODO)

- [ ] Git Flow를 실제 도구(`git-flow` CLI)로 실습해보기
- [ ] Monorepo에서의 Git 전략 (sparse-checkout, submodule vs subtree)
- [ ] GitHub Actions와 브랜치 보호 규칙 연계
- [ ] `git worktree` (여러 브랜치를 동시에 다른 폴더에서 작업)
- [ ] Semantic Release (Conventional Commits 기반 자동 버전 관리)
